// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nils Wistoff <nwistoff@iis.ee.ethz.ch>

module c910_axi_wrap #(
  // Make AXI transactions modifiable. Caution: This might backfire if transactions get downsized!
  parameter bit          AxiSetModifiable = 1'b0,
  // Convert wrapping to incrementing bursts. Set this if downstream IPs do not support wrapping
  // bursts.
  parameter bit          AxiUnwrapBursts = 1'b1,
  // AXI Bus Types
  parameter int unsigned AddrWidth = 32'd0,
  parameter int unsigned DataWidth = 32'd0,
  parameter int unsigned IdWidth = 32'd0,
  parameter int unsigned UserWidth = 32'd0,
  parameter type         axi_req_t = logic,
  parameter type         axi_rsp_t = logic
)(
  input  logic        clk_i,
  input  logic        rst_ni,
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
    .biu_pad_lpmd_b       (                             )
  );

  assign c910_axi_req.aw.qos    = '0;
  assign c910_axi_req.aw.region = '0;
  assign c910_axi_req.aw.atop   = '0;
  assign c910_axi_req.aw.user   = '0;
  assign c910_axi_req.w.user    = '0;
  assign c910_axi_req.ar.qos    = '0;
  assign c910_axi_req.ar.region = '0;
  assign c910_axi_req.ar.user   = '0;

  if (AxiUnwrapBursts) begin : gen_burst_unwrap
    axi_burst_unwrap #(
      .MaxReadTxns  ( 32'd16    ),
      .MaxWriteTxns ( 32'd16    ),
      .AddrWidth    ( AddrWidth ),
      .DataWidth    ( DataWidth ),
      .IdWidth      ( IdWidth   ),
      .UserWidth    ( UserWidth ),
      .axi_req_t    ( axi_req_t ),
      .axi_resp_t   ( axi_rsp_t )
    ) i_axi_burst_unwrap (
      .clk_i      ( clk_i        ),
      .rst_ni     ( rst_ni       ),
      .slv_req_i  ( c910_axi_req ),
      .slv_resp_o ( c910_axi_rsp ),
      .mst_req_o  ( axi_req_o    ),
      .mst_resp_i ( axi_rsp_i    )
    );
  end else begin : gen_burst_feedthrough // if (AxiUnwrap)
    assign axi_req_o    = c910_axi_req;
    assign c910_axi_rsp = axi_rsp_i;
  end // else: !if(AxiUnwrap)

endmodule
