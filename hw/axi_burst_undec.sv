// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Zexin Fu <zexifu@iis.ee.ethz.ch>
//
// To convert the c910 decrement mode to standard increment mode.
// [IDLE]             When receive a valid AW req,
//                    [IDLE.1] if its awburst == 3, it is in decrement mdoe, buffer it.
//                             state machine from IDLE to AW_RECEIVED. goto [AW_RECEIVED].
//                    [IDLE.2] if its awburst != 3, goto [bypass].
// [AW_RECEIVED]      When receive a valid W req, buffer it,
//                    remain in AW_RECEIVED until receive a W with wlast set,
//                    then switch to W_LAST_RECEIVED, go to [W_LAST_RECEIVED].
// [W_LAST_RECEIVED]  Modify the AW info: awaddr -> the lowest address, awburst -> BURST_INCR,
//                    send out the AW req to downstream until AW handshake,
//                    then switch to AW_SENT, go to [AW_SENT].
// [AW_SENT]          Send out the W req to downstream, maintain a counter to count the burst number,
//                    when sending the last burst, set the awlast high until the W handshake,
//                    then switch to IDEL, go to [IDLE]
// [bypass]           For AR and AW/W with non-decrement mode, directly go through the converter.
//                    If the state machine is not in IDLE, check RAW and WAW hazards for each,
//                    if found any address conflist, stall the incoming request.

module axi_burst_undec #(
  // the whole burst length in bit
  parameter int unsigned TotalBurstLength = 512,
  // AXI channel structs
  parameter type  aw_chan_t = logic,
  parameter type   w_chan_t = logic,
  parameter type   b_chan_t = logic,
  parameter type  ar_chan_t = logic,
  parameter type   r_chan_t = logic,
  // AXI request & response structs
  parameter type  axi_req_t = logic,
  parameter type axi_resp_t = logic
) (
  input logic       clk_i,
  input logic       rst_ni,
  // slave port
  input  axi_req_t  slv_req_i,
  output axi_resp_t slv_resp_o,
  // master port
  output axi_req_t  mst_req_o,
  input  axi_resp_t mst_resp_i
);

  /// In a fixed burst:
  /// - The address is the same for every transfer in the burst.
  /// - The byte lanes that are valid are constant for all beats in the burst.  However, within
  ///   those byte lanes, the actual bytes that have `wstrb` asserted can differ for each beat in
  ///   the burst.
  /// This burst type is used for repeated accesses to the same location such as when loading or
  /// emptying a FIFO.
  localparam logic [1:0] BURST_FIXED = 2'b00;
  /// In an incrementing burst, the address for each transfer in the burst is an increment of the
  /// address for the previous transfer.  The increment value depends on the size of the transfer.
  /// For example, the address for each transfer in a burst with a size of 4 bytes is the previous
  /// address plus four.
  /// This burst type is used for accesses to normal sequential memory.
  localparam logic [1:0] BURST_INCR  = 2'b01;
  /// A wrapping burst is similar to an incrementing burst, except that the address wraps around to
  /// a lower address if an upper address limit is reached.
  /// The following restrictions apply to wrapping bursts:
  /// - The start address must be aligned to the size of each transfer.
  /// - The length of the burst must be 2, 4, 8, or 16 transfers.
  localparam logic [1:0] BURST_WRAP  = 2'b10;
  /// C910 specific:
  /// In an decrementing burst, the address for each transfer in the burst is an decrement of the
  /// address for the previous transfer.  The decrement value depends on the size of the transfer.
  /// For example, the address for each transfer in a burst with a size of 4 bytes is the previous
  /// address minus four.
  /// From c910 rtl code ciu/rtl/ct_piu_top.v, the decrement mode will provide the starting
  /// address for the burst beat (in c910 is 128bit) with the most significant address.
  /// This burst type is used for accesses to normal sequential memory.
  localparam logic [1:0] BURST_DECR  = 2'b11;

  typedef enum logic [2:0] {
    IDLE            ,
    AW_RECEIVED     ,
    W_LAST_RECEIVED ,
    AW_SENT
  } undec_state_e;

  undec_state_e state_d;
  undec_state_e state_q;
  logic state_en;

  aw_chan_t aw_d, aw_q;
  logic aw_en;

  w_chan_t [TotalBurstLength/$bits(slv_req_i.w.data)-1:0] w_d, w_q;
  logic [TotalBurstLength/$bits(slv_req_i.w.data)-1:0] w_en;
  logic [$clog2(TotalBurstLength/$bits(slv_req_i.w.data))-1:0] w_burst_rec_cnt_d;
  logic [$clog2(TotalBurstLength/$bits(slv_req_i.w.data))-1:0] w_burst_rec_cnt_q;
  logic w_burst_rec_cnt_en;

  logic [$clog2(TotalBurstLength/$bits(slv_req_i.w.data))-1:0] w_burst_snd_cnt_d;
  logic [$clog2(TotalBurstLength/$bits(slv_req_i.w.data))-1:0] w_burst_snd_cnt_q;
  logic w_burst_snd_cnt_en;

  // record the number of handshaked aw but unsent w burst
  logic [8-1:0] unsent_w_cnt_d;
  logic [8-1:0] unsent_w_cnt_q;
  logic unsent_w_cnt_en;

  logic in_aw_hsk;
  logic out_w_hsk;

  logic [$bits(slv_req_i.aw.addr)-1:0] begnning_addr;

  assign begnning_addr = aw_q.addr - ((1 << aw_q.size) << ((&aw_q.len[1:0]) ? 2 : 0))
                                   + (1 << aw_q.size);

  assign w_burst_rec_cnt_d = w_burst_rec_cnt_q + 1;
  assign w_burst_snd_cnt_d = w_burst_snd_cnt_q - 1;

  // in case the w transactions for the last aw haven't finished and
  // the new aw with burst 3 comes, which will interrupt the last
  // unfinished aw+w transaction
  assign unsent_w_cnt_d  = unsent_w_cnt_q + (in_aw_hsk ? ((&slv_req_i.aw.len[1:0]) ? 4 : 1) : 0)
                                          - (out_w_hsk ? 1 : 0);
  assign unsent_w_cnt_en = out_w_hsk | in_aw_hsk;

  assign out_w_hsk = mst_req_o.w_valid & mst_resp_i.w_ready;
  assign in_aw_hsk = slv_req_i.aw_valid & slv_resp_o.aw_ready;

  // state machine
  always_comb begin
    mst_req_o.aw_valid  = 1'b0;
    mst_req_o.aw        = aw_q;
    mst_req_o.w_valid   = 1'b0;
    mst_req_o.w         = w_q[0];
    mst_req_o.w.last    = 1'b0;

    slv_resp_o.aw_ready = 1'b0;
    slv_resp_o.w_ready  = 1'b0;

    state_d             = state_q;
    state_en            = 1'b0;
    aw_d                = aw_q;
    aw_en               = 1'b0;
    w_d                 = w_q;
    w_en                = '0;
    w_burst_rec_cnt_en  = 1'b0;
    w_burst_snd_cnt_en  = 1'b0;
    case (state_q)
      IDLE: begin
        state_d   = AW_RECEIVED;
        aw_d      = slv_req_i.aw;
        if(slv_req_i.aw_valid && (slv_req_i.aw.burst == BURST_DECR)) begin
          if(unsent_w_cnt_q == '0) begin // no w burst for last aw req left, start undec fsm
            slv_resp_o.aw_ready = 1'b1;
            state_en  = 1'b1;
            aw_en     = 1'b1;
          end else begin // has unfinished w bursts from last aw req, wait them finish first
            mst_req_o.w_valid   = slv_req_i.w_valid;
            mst_req_o.w         = slv_req_i.w;

            slv_resp_o.w_ready  = mst_resp_i.w_ready;
          end
        end else begin // fall through
          mst_req_o.aw_valid  = slv_req_i.aw_valid;
          mst_req_o.aw        = slv_req_i.aw;
          mst_req_o.w_valid   = slv_req_i.w_valid;
          mst_req_o.w         = slv_req_i.w;

          slv_resp_o.aw_ready = mst_resp_i.aw_ready;
          slv_resp_o.w_ready  = mst_resp_i.w_ready;
        end
      end
      AW_RECEIVED: begin
        slv_resp_o.w_ready  = 1'b1;
        if(slv_req_i.w_valid) begin
          w_d [w_burst_rec_cnt_q] = slv_req_i.w;
          w_en[w_burst_rec_cnt_q] = 1'b1;
          w_burst_rec_cnt_en      = 1'b1;
          if(slv_req_i.w.last) begin
            state_d = W_LAST_RECEIVED;
            state_en  = 1'b1;
            `ifndef SYNTHESIS
            assert(&w_burst_rec_cnt_q) else begin
              $fatal("receive w last but the counter is not full");
            end
            `endif
          end
        end
      end
      W_LAST_RECEIVED: begin
        mst_req_o.aw_valid  = 1'b1;
        mst_req_o.aw.addr   = begnning_addr;
        mst_req_o.aw.burst  = BURST_INCR;
        if(mst_resp_i.aw_ready) begin
          state_d   = AW_SENT;
          state_en  = 1'b1;
        end
      end
      AW_SENT: begin
        mst_req_o.w_valid   = 1'b1;
        mst_req_o.w.data    = w_q[w_burst_snd_cnt_q].data;
        mst_req_o.w.last    = ~(|w_burst_snd_cnt_q);
        if(mst_resp_i.w_ready) begin
          w_burst_snd_cnt_en  = 1'b1;
          if(~(|w_burst_snd_cnt_q)) begin
            state_d   = IDLE;
            state_en  = 1'b1;
          end
        end
      end
      default:;
    endcase
  end

  // registers
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      state_q <= IDLE;
    end else begin
      if(state_en) begin
        state_q <= state_d;
      end
    end
  end

  always_ff @(posedge clk_i) begin
    if(aw_en) begin
      aw_q <= aw_d;
    end
  end

  always_ff @(posedge clk_i) begin
    for(int i = 0; i < TotalBurstLength/$bits(slv_req_i.w.data); i++) begin
      if(w_en[i]) begin
        w_q[i] <= w_d[i];
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      w_burst_rec_cnt_q <= '0;
    end else begin
      if(w_burst_rec_cnt_en) begin
        w_burst_rec_cnt_q <= w_burst_rec_cnt_d;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      w_burst_snd_cnt_q <= '1;
    end else begin
      if(w_burst_snd_cnt_en) begin
        w_burst_snd_cnt_q <= w_burst_snd_cnt_d;
      end
    end
  end

  always_ff@(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
      unsent_w_cnt_q <= '0;
    end else begin
      if(unsent_w_cnt_en) begin
        unsent_w_cnt_q <= unsent_w_cnt_d;
      end
    end
  end


  // other AXI channel output and hazard check
  logic ar_addr_comp;
  assign ar_addr_comp = (aw_q.addr[$bits(aw_q.addr)-1:12] ==
                         slv_req_i.ar.addr[$bits(aw_q.addr)-1:12]) &
                        slv_req_i.ar_valid;

  logic ar_aw_addr_comp;
  assign ar_aw_addr_comp = (slv_req_i.aw.addr[$bits(aw_q.addr)-1:12] ==
                            slv_req_i.ar.addr[$bits(aw_q.addr)-1:12]) &
                           slv_req_i.aw_valid &
                           slv_req_i.ar_valid;


  always_comb begin
    // by default, bypass the module
    mst_req_o.ar_valid  = slv_req_i.ar_valid;
    mst_req_o.ar        = slv_req_i.ar;
    mst_req_o.b_ready   = slv_req_i.b_ready;
    mst_req_o.r_ready   = slv_req_i.r_ready;

    slv_resp_o.ar_ready = mst_resp_i.ar_ready;
    slv_resp_o.b_valid  = mst_resp_i.b_valid;
    slv_resp_o.b        = mst_resp_i.b;
    slv_resp_o.r_valid  = mst_resp_i.r_valid;
    slv_resp_o.r        = mst_resp_i.r;
    if(state_q != IDLE) begin // there is a AW/W transaction active, need to check hazard
      // the AXI burst cannot go across 4K boundary
      if(ar_addr_comp) begin
        slv_resp_o.ar_ready = 1'b0;
        mst_req_o.ar_valid  = 1'b0;
      end
    end
  end

endmodule
