// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nils Wistoff <nwistoff@iis.ee.ethz.ch>
// Zexin Fu <zexifu@iis.ee.ethz.ch>

`include "common_cells/assertions.svh"

module c910_axi_wrap #(
  // Make AXI transactions modifiable. Caution: This might backfire if transactions get downsized!
  parameter bit          AxiSetModifiable = 1'b0,
  // Convert wrapping to incrementing bursts. Set this if downstream IPs do not support wrapping
  // bursts.
  parameter bit          AxiUnwrapBursts = 1'b1,
  // Convert the c910 AXI decrementing mode to standard increment mode. Set this if downstream
  // IPs do not support decrementing bursts.
  parameter bit          AxiUndecrementBurst = 1'b1,
  // Handle ACE evict snoop by directing it to the zero memory.
  parameter bit          AxiZeroMem = 1'b1,
  // AXI Bus Types
  parameter int unsigned AddrWidth = 32'd0,
  parameter int unsigned DataWidth = 32'd0,
  parameter int unsigned IdWidth = 32'd0,
  parameter int unsigned UserWidth = 32'd0,
  // AXI channel structs
  parameter type         aw_chan_t = logic,
  parameter type          w_chan_t = logic,
  parameter type          b_chan_t = logic,
  parameter type         ar_chan_t = logic,
  parameter type          r_chan_t = logic,
  // AXI request and response types
  parameter type         axi_req_t = logic,
  parameter type         axi_rsp_t = logic
)(
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        rtc_i,
  // clint
  input  logic        ipi_i,
  input  logic        time_irq_i,
  // plic
  input  logic [1:0]  plic_hartx_mint_req_i,
  input  logic [1:0]  plic_hartx_sint_req_i,
  // debug request (async)
  input  logic        debug_req_i,
  // External interrupts
  input  logic [39:0] ext_int_i,
  // JTAG
  input  logic        jtag_tck_i,
  input  logic        jtag_tdi_i,
  input  logic        jtag_tms_i,
  output logic        jtag_tdo_o,
  output logic        jtag_tdo_en_o,
  input  logic        jtag_trst_ni,
  // AXI interface
  output axi_req_t    axi_req_o,
  input  axi_rsp_t    axi_rsp_i
);

  axi_req_t c910_axi_req;
  axi_rsp_t c910_axi_rsp;
  axi_req_t c910_axi_req_cut;
  axi_rsp_t c910_axi_rsp_cut;
  axi_req_t axi_req_unwrap;
  axi_rsp_t axi_rsp_unwrap;
  axi_req_t axi_req_undec;
  axi_rsp_t axi_rsp_undec;
  axi_req_t axi_req_zeromem;
  axi_rsp_t axi_rsp_zeromem;
  logic mst_req_aw_snp;

  // If enabled, set ax.cache.modifiable
  axi_pkg::cache_t c910_axi_ar_cache, c910_axi_aw_cache;
  if (AxiSetModifiable) begin : gen_set_cache_modifiable
    assign c910_axi_req.ar.cache = c910_axi_ar_cache | axi_pkg::CACHE_MODIFIABLE;
    assign c910_axi_req.aw.cache = c910_axi_aw_cache | axi_pkg::CACHE_MODIFIABLE;
  end else begin : gen_cache_feedthrough
    assign c910_axi_req.ar.cache = c910_axi_ar_cache;
    assign c910_axi_req.aw.cache = c910_axi_ar_cache;
  end

  cpu_sub_system_axi cpu_sub_system_axi_i (
    .axim_clk_en          ( '1                          ),
    .pad_biu_arready      ( c910_axi_rsp.ar_ready       ),
    .pad_biu_awready      ( c910_axi_rsp.aw_ready       ),
    .pad_biu_bid          ( c910_axi_rsp.b.id           ),
    .pad_biu_bresp        ( c910_axi_rsp.b.resp         ),
    .pad_biu_bvalid       ( c910_axi_rsp.b_valid        ),
    .pad_biu_rdata        ( c910_axi_rsp.r.data         ),
    .pad_biu_rid          ( c910_axi_rsp.r.id           ),
    .pad_biu_rlast        ( c910_axi_rsp.r.last         ),
    .pad_biu_rresp        ( {2'b0, c910_axi_rsp.r.resp} ),
    .pad_biu_rvalid       ( c910_axi_rsp.r_valid        ),
    .pad_biu_wready       ( c910_axi_rsp.w_ready        ),
    .pad_cpu_rst_b        ( rst_ni                      ),
    .pad_had_jtg_tclk     ( jtag_tck_i                  ),
    .pad_had_jtg_tdi      ( jtag_tdi_i                  ),
    .pad_had_jtg_trst_b   ( jtag_trst_ni                ),
    .pad_yy_dft_clk_rst_b ( rst_ni                      ),
    .pll_cpu_clk          ( clk_i                       ),
    .rtc_cpu_clk          ( rtc_i                       ),
    .biu_pad_araddr       ( c910_axi_req.ar.addr        ),
    .biu_pad_arburst      ( c910_axi_req.ar.burst       ),
    .biu_pad_arcache      ( c910_axi_ar_cache           ),
    .biu_pad_arid         ( c910_axi_req.ar.id          ),
    .biu_pad_arlen        ( c910_axi_req.ar.len         ),
    .biu_pad_arlock       ( c910_axi_req.ar.lock        ),
    .biu_pad_arprot       ( c910_axi_req.ar.prot        ),
    .biu_pad_arsize       ( c910_axi_req.ar.size        ),
    .biu_pad_arvalid      ( c910_axi_req.ar_valid       ),
    .biu_pad_awaddr       ( c910_axi_req.aw.addr        ),
    .biu_pad_awburst      ( c910_axi_req.aw.burst       ),
    .biu_pad_awcache      ( c910_axi_aw_cache           ),
    .biu_pad_awid         ( c910_axi_req.aw.id          ),
    .biu_pad_awlen        ( c910_axi_req.aw.len         ),
    .biu_pad_awlock       ( c910_axi_req.aw.lock        ),
    .biu_pad_awprot       ( c910_axi_req.aw.prot        ),
    .biu_pad_awsize       ( c910_axi_req.aw.size        ),
    .biu_pad_awvalid      ( c910_axi_req.aw_valid       ),
    .biu_pad_bready       ( c910_axi_req.b_ready        ),
    .biu_pad_rready       ( c910_axi_req.r_ready        ),
    .biu_pad_wdata        ( c910_axi_req.w.data         ),
    .biu_pad_wlast        ( c910_axi_req.w.last         ),
    .biu_pad_wstrb        ( c910_axi_req.w.strb         ),
    .biu_pad_wvalid       ( c910_axi_req.w_valid        ),
    .had_pad_jtg_tdo      ( jtag_tdo_o                  ),
    .had_pad_jtg_tdo_en   ( jtag_tdo_en_o               ),
    .xx_intc_vld          ( ext_int_i                   ),
    .per_clk              ( clk_i                       ),
    .i_pad_jtg_tms        ( jtag_tms_i                  ),
    .biu_pad_wid          (                             ),
    .biu_pad_lpmd_b       (                             ),
    // clint
    .ipi_i                ( ipi_i                       ),
    .time_irq_i           ( time_irq_i                  ),
    // plic
    .plic_hartx_mint_req_i( plic_hartx_mint_req_i       ),
    .plic_hartx_sint_req_i( plic_hartx_sint_req_i       )
  );

  assign c910_axi_req.aw.qos    = '0;
  assign c910_axi_req.aw.region = '0;
  assign c910_axi_req.aw.atop   = '0;
  assign c910_axi_req.aw.user   = '0;
  assign c910_axi_req.w.user    = '0;
  assign c910_axi_req.ar.qos    = '0;
  assign c910_axi_req.ar.region = '0;
  assign c910_axi_req.ar.user   = '0;

  // axi fifo to close timing
  axi_cut #(
    .Bypass       ( 0 ),
    .aw_chan_t    ( aw_chan_t ),
    .w_chan_t     ( w_chan_t  ),
    .b_chan_t     ( b_chan_t  ),
    .ar_chan_t    ( ar_chan_t ),
    .r_chan_t     ( r_chan_t  ),
    .axi_req_t    ( axi_req_t ),
    .axi_resp_t   ( axi_rsp_t )
  ) i_c910_axi_cut (
    .clk_i,
    .rst_ni,
    // slave port
    .slv_req_i    (c910_axi_req    ),
    .slv_resp_o   (c910_axi_rsp    ),
    // master port
    .mst_req_o    (c910_axi_req_cut),
    .mst_resp_i   (c910_axi_rsp_cut)
  );

  if (AxiUnwrapBursts) begin : gen_burst_unwrap
    axi_burst_unwrap #(
      .MaxReadTxns  ( 32'd8     ),
      .MaxWriteTxns ( 32'd8     ),
      .AddrWidth    ( AddrWidth ),
      .DataWidth    ( DataWidth ),
      .IdWidth      ( IdWidth   ),
      .UserWidth    ( UserWidth ),
      .axi_req_t    ( axi_req_t ),
      .axi_resp_t   ( axi_rsp_t )
    ) i_axi_burst_unwrap (
      .clk_i      ( clk_i            ),
      .rst_ni     ( rst_ni           ),
      .slv_req_i  ( c910_axi_req_cut ),
      .slv_resp_o ( c910_axi_rsp_cut ),
      .mst_req_o  ( axi_req_unwrap   ),
      .mst_resp_i ( axi_rsp_unwrap   )
    );
  end else begin : gen_burst_feedthrough
    assign axi_req_unwrap   = c910_axi_req_cut;
    assign c910_axi_rsp_cut = axi_rsp_unwrap;
  end

  if (AxiUndecrementBurst) begin : gen_decrement_undec
    axi_burst_undec #(
    // the whole burst length in bit
      .TotalBurstLength ( 512 ),
    // AXI channel structs
      .aw_chan_t    ( aw_chan_t ),
      .w_chan_t     ( w_chan_t  ),
      .b_chan_t     ( b_chan_t  ),
      .ar_chan_t    ( ar_chan_t ),
      .r_chan_t     ( r_chan_t  ),
    // AXI request & response structs
      .axi_req_t    ( axi_req_t ),
      .axi_resp_t   ( axi_rsp_t )
    ) i_axi_decrement_undec (
      .clk_i,
      .rst_ni,
      .slv_req_i   ( axi_req_unwrap ),
      .slv_resp_o  ( axi_rsp_unwrap ),
      .mst_req_o   ( axi_req_undec  ),
      .mst_resp_i  ( axi_rsp_undec  )
    );
  end else begin : gen_decrement_feedthrough
    assign axi_req_undec = axi_req_unwrap;
    assign axi_rsp_unwrap = axi_rsp_undec;
  end


  if (AxiZeroMem) begin : gen_zero_mem
    localparam logic [AddrWidth-1:0] SnpAddr = 'h40000;
    assign mst_req_aw_snp = axi_req_undec.aw_valid
                          && (axi_req_undec.aw.addr == SnpAddr);
    axi_demux #(
      .AxiIdWidth  ( IdWidth   ),
      .AxiLookBits ( IdWidth   ),
      .aw_chan_t   ( aw_chan_t ),
      .w_chan_t    ( w_chan_t  ),
      .b_chan_t    ( b_chan_t  ),
      .ar_chan_t   ( ar_chan_t ),
      .r_chan_t    ( r_chan_t  ),
      .axi_req_t   ( axi_req_t ),
      .axi_resp_t  ( axi_rsp_t ),
      .NoMstPorts  ( 2         ),
      .MaxTrans    ( 8         ),
      .SpillAw     ( 1'b1      )  // Required to break dependency between AW and W channels
    ) i_axi_demux (
      .clk_i,
      .rst_ni,
      .test_i          ( 1'b0                         ),
      .mst_reqs_o      ( {axi_req_zeromem, axi_req_o} ),
      .mst_resps_i     ( {axi_rsp_zeromem, axi_rsp_i} ),
      .slv_ar_select_i ( 1'b0                         ), // No snp req on AR chan
      .slv_aw_select_i ( mst_req_aw_snp               ),
      .slv_req_i       ( axi_req_undec                ),
      .slv_resp_o      ( axi_rsp_undec                )
    );

    axi_zero_mem #(
      .axi_req_t   ( axi_req_t  ),
      .axi_resp_t  ( axi_rsp_t  ),
      .AddrWidth   ( AddrWidth  ),
      .DataWidth   ( DataWidth  ),
      .IdWidth     ( IdWidth    ),
      .NumBanks    ( 32'd1      ),
      .BufDepth    ( 32'd1      )
    ) i_axi_zero_mem (
      .clk_i,
      .rst_ni,
      .busy_o        ( /* Not used */   ),
      .axi_req_i     ( axi_req_zeromem  ),
      .axi_resp_o    ( axi_rsp_zeromem  )
    );

    `ASSERT(no_snp_ar, axi_req_undec.ar_valid |-> axi_req_undec.ar.addr != SnpAddr, clk_i, rst_ni,
        "No snoop evict requests on AR channel!")
  end else begin : gen_zero_mem_feedthrough
    assign axi_req_o        = axi_req_undec;
    assign axi_rsp_undec    = axi_rsp_i;
    assign axi_req_zeromem  = '0;
    assign axi_rsp_zeromem  = '0;
    assign mst_req_aw_snp   = 1'b0;
  end
endmodule
