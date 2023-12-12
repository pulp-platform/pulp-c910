/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// &Depend("cpu_cfig.h"); @24
// &Depend("mp_top_golden_port.vp"); @25
// &Depend("plic_top.v"); @26
// &Depend("plic_hart_arb.v"); @27
// &Depend("plic_hreg_busif.v"); @28
// &Depend("plic_kid_busif.v"); @29
// &Depend("csky_apb_1tox_matrix.v"); @30
// &Depend("plic_arb_ctrl.v"); @31
// &Depend("plic_ctrl.v"); @32
// &Depend("plic_32to1_arb.v"); @33
// &Depend("plic_int_kid.v"); @34
// &Depend("plic_granu_arb.v"); @35
// &Depend("plic_granu2_arb.v"); @36
// &Depend("sync_level2level.v"); @37
// &Depend("plic_sec_busif.v"); @39
// &ModuleBeg; @41

`include "cpu_cfig.h"

module openC910(
  axim_clk_en,
  biu_pad_araddr,
  biu_pad_arburst,
  biu_pad_arcache,
  biu_pad_arid,
  biu_pad_arlen,
  biu_pad_arlock,
  biu_pad_arprot,
  biu_pad_arsize,
  biu_pad_arvalid,
  biu_pad_awaddr,
  biu_pad_awburst,
  biu_pad_awcache,
  biu_pad_awid,
  biu_pad_awlen,
  biu_pad_awlock,
  biu_pad_awprot,
  biu_pad_awsize,
  biu_pad_awvalid,
  biu_pad_bready,
  biu_pad_cactive,
  biu_pad_csysack,
  biu_pad_rready,
  biu_pad_wdata,
  biu_pad_wlast,
  biu_pad_wstrb,
  biu_pad_wvalid,
  core0_pad_jdb_pm,
  core0_pad_lpmd_b,
  core0_pad_mstatus,
  core0_pad_retire0,
  core0_pad_retire0_pc,
  core0_pad_retire1,
  core0_pad_retire1_pc,
  core0_pad_retire2,
  core0_pad_retire2_pc,
  core1_pad_jdb_pm,
  core1_pad_lpmd_b,
  core1_pad_mstatus,
  core1_pad_retire0,
  core1_pad_retire0_pc,
  core1_pad_retire1,
  core1_pad_retire1_pc,
  core1_pad_retire2,
  core1_pad_retire2_pc,
  cpu_debug_port,
  cpu_pad_l2cache_flush_done,
  cpu_pad_no_op,
  had_pad_jtg_tdo,
  had_pad_jtg_tdo_en,
  pad_biu_arready,
  pad_biu_awready,
  pad_biu_bid,
  pad_biu_bresp,
  pad_biu_bvalid,
  pad_biu_csysreq,
  pad_biu_rdata,
  pad_biu_rid,
  pad_biu_rlast,
  pad_biu_rresp,
  pad_biu_rvalid,
  pad_biu_wready,
  pad_core0_dbg_mask,
  pad_core0_dbgrq_b,
  pad_core0_hartid,
  pad_core0_rst_b,
  pad_core0_rvba,
  pad_core1_dbg_mask,
  pad_core1_dbgrq_b,
  pad_core1_hartid,
  pad_core1_rst_b,
  pad_core1_rvba,
  pad_cpu_apb_base,
  pad_cpu_l2cache_flush_req,
  pad_cpu_rst_b,
  pad_cpu_sys_cnt,
  pad_had_jtg_tclk,
  pad_had_jtg_tdi,
  pad_had_jtg_tms,
  pad_had_jtg_trst_b,
  pad_l2c_data_mbist_clk_ratio,
  pad_l2c_tag_mbist_clk_ratio,
  pad_plic_int_cfg,
  pad_plic_int_vld,
  pad_yy_dft_clk_rst_b,
  pad_yy_icg_scan_en,
  pad_yy_mbist_mode,
  pad_yy_scan_enable,
  pad_yy_scan_mode,
  pad_yy_scan_rst_b,
  pll_cpu_clk,
  // clint
  ipi_i,
  time_irq_i,
  // plic
  plic_hartx_mint_req_i,
  plic_hartx_sint_req_i
);

// &Ports("compare", "../../../gen_rtl/cpu/rtl/mp_top_golden_port.v"); @42
input            axim_clk_en;                   
input            pad_biu_arready;               
input            pad_biu_awready;               
input   [7  :0]  pad_biu_bid;                   
input   [1  :0]  pad_biu_bresp;                 
input            pad_biu_bvalid;                
input            pad_biu_csysreq;               
input   [127:0]  pad_biu_rdata;                 
input   [7  :0]  pad_biu_rid;                   
input            pad_biu_rlast;                 
input   [1  :0]  pad_biu_rresp;                 
input            pad_biu_rvalid;                
input            pad_biu_wready;                
input            pad_core0_dbg_mask;            
input            pad_core0_dbgrq_b;             
input   [2  :0]  pad_core0_hartid;              
input            pad_core0_rst_b;               
input   [39 :0]  pad_core0_rvba;                
input            pad_core1_dbg_mask;            
input            pad_core1_dbgrq_b;             
input   [2  :0]  pad_core1_hartid;              
input            pad_core1_rst_b;               
input   [39 :0]  pad_core1_rvba;                
input   [39 :0]  pad_cpu_apb_base;              
input            pad_cpu_l2cache_flush_req;     
input            pad_cpu_rst_b;                 
input   [63 :0]  pad_cpu_sys_cnt;               
input            pad_had_jtg_tclk;              
input            pad_had_jtg_tdi;               
input            pad_had_jtg_tms;               
input            pad_had_jtg_trst_b;            
input   [2  :0]  pad_l2c_data_mbist_clk_ratio;  
input   [2  :0]  pad_l2c_tag_mbist_clk_ratio;   
input   [143:0]  pad_plic_int_cfg;              
input   [143:0]  pad_plic_int_vld;              
input            pad_yy_dft_clk_rst_b;          
input            pad_yy_icg_scan_en;            
input            pad_yy_mbist_mode;             
input            pad_yy_scan_enable;            
input            pad_yy_scan_mode;              
input            pad_yy_scan_rst_b;             
input            pll_cpu_clk;                   
  // clint
input            ipi_i;
input            time_irq_i;
  // plic
input   [1  :0]  plic_hartx_mint_req_i;
input   [1  :0]  plic_hartx_sint_req_i;


output  [39 :0]  biu_pad_araddr;                
output  [1  :0]  biu_pad_arburst;               
output  [3  :0]  biu_pad_arcache;               
output  [7  :0]  biu_pad_arid;                  
output  [7  :0]  biu_pad_arlen;                 
output           biu_pad_arlock;                
output  [2  :0]  biu_pad_arprot;                
output  [2  :0]  biu_pad_arsize;                
output           biu_pad_arvalid;               
output  [39 :0]  biu_pad_awaddr;                
output  [1  :0]  biu_pad_awburst;               
output  [3  :0]  biu_pad_awcache;               
output  [7  :0]  biu_pad_awid;                  
output  [7  :0]  biu_pad_awlen;                 
output           biu_pad_awlock;                
output  [2  :0]  biu_pad_awprot;                
output  [2  :0]  biu_pad_awsize;                
output           biu_pad_awvalid;               
output           biu_pad_bready;                
output           biu_pad_cactive;               
output           biu_pad_csysack;               
output           biu_pad_rready;                
output  [127:0]  biu_pad_wdata;                 
output           biu_pad_wlast;                 
output  [15 :0]  biu_pad_wstrb;                 
output           biu_pad_wvalid;                
output  [1  :0]  core0_pad_jdb_pm;              
output  [1  :0]  core0_pad_lpmd_b;              
output  [63 :0]  core0_pad_mstatus;             
output           core0_pad_retire0;             
output  [39 :0]  core0_pad_retire0_pc;          
output           core0_pad_retire1;             
output  [39 :0]  core0_pad_retire1_pc;          
output           core0_pad_retire2;             
output  [39 :0]  core0_pad_retire2_pc;          
output  [1  :0]  core1_pad_jdb_pm;              
output  [1  :0]  core1_pad_lpmd_b;              
output  [63 :0]  core1_pad_mstatus;             
output           core1_pad_retire0;             
output  [39 :0]  core1_pad_retire0_pc;          
output           core1_pad_retire1;             
output  [39 :0]  core1_pad_retire1_pc;          
output           core1_pad_retire2;             
output  [39 :0]  core1_pad_retire2_pc;          
output           cpu_debug_port;                
output           cpu_pad_l2cache_flush_done;    
output           cpu_pad_no_op;                 
output           had_pad_jtg_tdo;               
output           had_pad_jtg_tdo_en;            

//&Ports;
// &Regs; @44

// &Wires; @45
wire             apb_clk;                       
wire             apb_clk_en;                    
wire             apbif_had_pctrace_inv;         
wire             apbrst_b;                      
wire             axim_clk_en;                   
wire             axim_clk_en_f;                 
wire    [39 :0]  biu_pad_araddr;                
wire    [1  :0]  biu_pad_arburst;               
wire    [3  :0]  biu_pad_arcache;               
wire    [7  :0]  biu_pad_arid;                  
wire    [7  :0]  biu_pad_arlen;                 
wire             biu_pad_arlock;                
wire    [2  :0]  biu_pad_arprot;                
wire    [2  :0]  biu_pad_arsize;                
wire             biu_pad_arvalid;               
wire    [39 :0]  biu_pad_awaddr;                
wire    [1  :0]  biu_pad_awburst;               
wire    [3  :0]  biu_pad_awcache;               
wire    [7  :0]  biu_pad_awid;                  
wire    [7  :0]  biu_pad_awlen;                 
wire             biu_pad_awlock;                
wire    [2  :0]  biu_pad_awprot;                
wire    [2  :0]  biu_pad_awsize;                
wire             biu_pad_awvalid;               
wire             biu_pad_bready;                
wire             biu_pad_cactive;               
wire             biu_pad_csysack;               
wire             biu_pad_rready;                
wire    [127:0]  biu_pad_wdata;                 
wire             biu_pad_wlast;                 
wire    [15 :0]  biu_pad_wstrb;                 
wire             biu_pad_wvalid;                
wire             ciu_clint_icg_en;              
wire    [292:0]  ciu_had_dbg_info;              
wire    [32 :0]  ciu_l2c_addr_bank_0;           
wire    [32 :0]  ciu_l2c_addr_bank_1;           
wire             ciu_l2c_addr_vld_bank_0;       
wire             ciu_l2c_addr_vld_bank_1;       
wire    [3  :0]  ciu_l2c_clr_cp_bank_0;         
wire    [3  :0]  ciu_l2c_clr_cp_bank_1;         
wire             ciu_l2c_ctcq_req_bank_0;       
wire             ciu_l2c_ctcq_req_bank_1;       
wire    [2  :0]  ciu_l2c_data_latency;          
wire             ciu_l2c_data_setup;            
wire             ciu_l2c_data_vld_bank_0;       
wire             ciu_l2c_data_vld_bank_1;       
wire    [32 :0]  ciu_l2c_dca_addr_bank_0;       
wire    [32 :0]  ciu_l2c_dca_addr_bank_1;       
wire             ciu_l2c_dca_req_bank_0;        
wire             ciu_l2c_dca_req_bank_1;        
wire    [2  :0]  ciu_l2c_hpcp_bus_bank_0;       
wire    [2  :0]  ciu_l2c_hpcp_bus_bank_1;       
wire    [2  :0]  ciu_l2c_icc_mid_bank_0;        
wire    [2  :0]  ciu_l2c_icc_mid_bank_1;        
wire    [1  :0]  ciu_l2c_icc_type_bank_0;       
wire    [1  :0]  ciu_l2c_icc_type_bank_1;       
wire    [1  :0]  ciu_l2c_iprf;                  
wire    [2  :0]  ciu_l2c_mid_bank_0;            
wire    [2  :0]  ciu_l2c_mid_bank_1;            
wire             ciu_l2c_prf_ready;             
wire             ciu_l2c_rdl_ready_bank_0;      
wire             ciu_l2c_rdl_ready_bank_1;      
wire             ciu_l2c_rst_req;               
wire    [3  :0]  ciu_l2c_set_cp_bank_0;         
wire    [3  :0]  ciu_l2c_set_cp_bank_1;         
wire    [4  :0]  ciu_l2c_sid_bank_0;            
wire    [4  :0]  ciu_l2c_sid_bank_1;            
wire             ciu_l2c_snpl2_ready_bank_0;    
wire             ciu_l2c_snpl2_ready_bank_1;    
wire    [1  :0]  ciu_l2c_src_bank_0;            
wire    [1  :0]  ciu_l2c_src_bank_1;            
wire    [2  :0]  ciu_l2c_tag_latency;           
wire             ciu_l2c_tag_setup;             
wire             ciu_l2c_tprf;                  
wire    [12 :0]  ciu_l2c_type_bank_0;           
wire    [12 :0]  ciu_l2c_type_bank_1;           
wire    [511:0]  ciu_l2c_wdata_bank_0;          
wire    [511:0]  ciu_l2c_wdata_bank_1;          
wire             ciu_plic_icg_en;               
wire             ciu_sysio_icg_en;              
wire             ciu_top_clk;                   
wire             ciu_xx_no_op;                  
wire             clint_core0_ms_int;            
wire             clint_core0_mt_int;            
wire             clint_core0_ss_int;            
wire             clint_core0_st_int;            
wire             clint_core1_ms_int;            
wire             clint_core1_mt_int;            
wire             clint_core1_ss_int;            
wire             clint_core1_st_int;            
wire             core0_cpu_no_retire;           
wire             core0_dbg_ack_pc;              
wire             core0_enter_dbg_req_i;         
wire             core0_enter_dbg_req_o;         
wire             core0_exit_dbg_req_i;          
wire             core0_exit_dbg_req_o;          
wire             core0_fifo_rst_b;              
wire             core0_had_dbg_mask;            
wire    [1  :0]  core0_pad_jdb_pm;              
wire    [1  :0]  core0_pad_lpmd_b;              
wire    [63 :0]  core0_pad_mstatus;             
wire             core0_pad_retire0;             
wire    [39 :0]  core0_pad_retire0_pc;          
wire             core0_pad_retire1;             
wire    [39 :0]  core0_pad_retire1_pc;          
wire             core0_pad_retire2;             
wire    [39 :0]  core0_pad_retire2_pc;          
wire    [63 :0]  core0_regs_serial_data;        
wire             core0_rst_b;                   
wire             core1_cpu_no_retire;           
wire             core1_dbg_ack_pc;              
wire             core1_enter_dbg_req_i;         
wire             core1_enter_dbg_req_o;         
wire             core1_exit_dbg_req_i;          
wire             core1_exit_dbg_req_o;          
wire             core1_fifo_rst_b;              
wire             core1_had_dbg_mask;            
wire    [1  :0]  core1_pad_jdb_pm;              
wire    [1  :0]  core1_pad_lpmd_b;              
wire    [63 :0]  core1_pad_mstatus;             
wire             core1_pad_retire0;             
wire    [39 :0]  core1_pad_retire0_pc;          
wire             core1_pad_retire1;             
wire    [39 :0]  core1_pad_retire1_pc;          
wire             core1_pad_retire2;             
wire    [39 :0]  core1_pad_retire2_pc;          
wire    [63 :0]  core1_regs_serial_data;        
wire             core1_rst_b;                   
wire             core2_cpu_no_retire;           
wire             core3_cpu_no_retire;           
wire             cpu_debug_port;                
wire             cpu_pad_l2cache_flush_done;    
wire             cpu_pad_no_op;                 
wire             cpurst_b;                      
wire             forever_core0_clk;             
wire             forever_core1_clk;             
wire             forever_cpuclk;                
wire             forever_jtgclk;                
wire             had_pad_jtg_tdo;               
wire             had_pad_jtg_tdo_en;            
wire             ibiu0_pad_acready;             
wire    [39 :0]  ibiu0_pad_araddr;              
wire    [1  :0]  ibiu0_pad_arbar;               
wire    [1  :0]  ibiu0_pad_arburst;             
wire    [3  :0]  ibiu0_pad_arcache;             
wire    [1  :0]  ibiu0_pad_ardomain;            
wire    [4  :0]  ibiu0_pad_arid;                
wire    [1  :0]  ibiu0_pad_arlen;               
wire             ibiu0_pad_arlock;              
wire    [2  :0]  ibiu0_pad_arprot;              
wire    [2  :0]  ibiu0_pad_arsize;              
wire    [3  :0]  ibiu0_pad_arsnoop;             
wire    [2  :0]  ibiu0_pad_aruser;              
wire             ibiu0_pad_arvalid;             
wire    [39 :0]  ibiu0_pad_awaddr;              
wire    [1  :0]  ibiu0_pad_awbar;               
wire    [1  :0]  ibiu0_pad_awburst;             
wire    [3  :0]  ibiu0_pad_awcache;             
wire    [1  :0]  ibiu0_pad_awdomain;            
wire    [4  :0]  ibiu0_pad_awid;                
wire    [1  :0]  ibiu0_pad_awlen;               
wire             ibiu0_pad_awlock;              
wire    [2  :0]  ibiu0_pad_awprot;              
wire    [2  :0]  ibiu0_pad_awsize;              
wire    [2  :0]  ibiu0_pad_awsnoop;             
wire             ibiu0_pad_awunique;            
wire             ibiu0_pad_awuser;              
wire             ibiu0_pad_awvalid;             
wire             ibiu0_pad_back;                
wire             ibiu0_pad_bready;              
wire    [127:0]  ibiu0_pad_cddata;              
wire             ibiu0_pad_cderr;               
wire             ibiu0_pad_cdlast;              
wire             ibiu0_pad_cdvalid;             
wire    [3  :0]  ibiu0_pad_cnt_en;              
wire    [4  :0]  ibiu0_pad_crresp;              
wire             ibiu0_pad_crvalid;             
wire             ibiu0_pad_csr_sel;             
wire    [79 :0]  ibiu0_pad_csr_wdata;           
wire             ibiu0_pad_jdb_pm;              
wire             ibiu0_pad_lpmd_b;              
wire             ibiu0_pad_rack;                
wire             ibiu0_pad_rready;              
wire    [127:0]  ibiu0_pad_wdata;               
wire             ibiu0_pad_werr;                
wire             ibiu0_pad_wlast;               
wire             ibiu0_pad_wns;                 
wire    [15 :0]  ibiu0_pad_wstrb;               
wire             ibiu0_pad_wvalid;              
wire             ibiu1_pad_acready;             
wire    [39 :0]  ibiu1_pad_araddr;              
wire    [1  :0]  ibiu1_pad_arbar;               
wire    [1  :0]  ibiu1_pad_arburst;             
wire    [3  :0]  ibiu1_pad_arcache;             
wire    [1  :0]  ibiu1_pad_ardomain;            
wire    [4  :0]  ibiu1_pad_arid;                
wire    [1  :0]  ibiu1_pad_arlen;               
wire             ibiu1_pad_arlock;              
wire    [2  :0]  ibiu1_pad_arprot;              
wire    [2  :0]  ibiu1_pad_arsize;              
wire    [3  :0]  ibiu1_pad_arsnoop;             
wire    [2  :0]  ibiu1_pad_aruser;              
wire             ibiu1_pad_arvalid;             
wire    [39 :0]  ibiu1_pad_awaddr;              
wire    [1  :0]  ibiu1_pad_awbar;               
wire    [1  :0]  ibiu1_pad_awburst;             
wire    [3  :0]  ibiu1_pad_awcache;             
wire    [1  :0]  ibiu1_pad_awdomain;            
wire    [4  :0]  ibiu1_pad_awid;                
wire    [1  :0]  ibiu1_pad_awlen;               
wire             ibiu1_pad_awlock;              
wire    [2  :0]  ibiu1_pad_awprot;              
wire    [2  :0]  ibiu1_pad_awsize;              
wire    [2  :0]  ibiu1_pad_awsnoop;             
wire             ibiu1_pad_awunique;            
wire             ibiu1_pad_awuser;              
wire             ibiu1_pad_awvalid;             
wire             ibiu1_pad_back;                
wire             ibiu1_pad_bready;              
wire    [127:0]  ibiu1_pad_cddata;              
wire             ibiu1_pad_cderr;               
wire             ibiu1_pad_cdlast;              
wire             ibiu1_pad_cdvalid;             
wire    [3  :0]  ibiu1_pad_cnt_en;              
wire    [4  :0]  ibiu1_pad_crresp;              
wire             ibiu1_pad_crvalid;             
wire             ibiu1_pad_csr_sel;             
wire    [79 :0]  ibiu1_pad_csr_wdata;           
wire             ibiu1_pad_jdb_pm;              
wire             ibiu1_pad_lpmd_b;              
wire             ibiu1_pad_rack;                
wire             ibiu1_pad_rready;              
wire    [127:0]  ibiu1_pad_wdata;               
wire             ibiu1_pad_werr;                
wire             ibiu1_pad_wlast;               
wire             ibiu1_pad_wns;                 
wire    [15 :0]  ibiu1_pad_wstrb;               
wire             ibiu1_pad_wvalid;              
wire    [63 :0]  ir_corex_wdata;                
wire             l2c_ciu_addr_ready_bank_0;     
wire             l2c_ciu_addr_ready_bank_1;     
wire             l2c_ciu_cmplt_bank_0;          
wire             l2c_ciu_cmplt_bank_1;          
wire    [3  :0]  l2c_ciu_cp_bank_0;             
wire    [3  :0]  l2c_ciu_cp_bank_1;             
wire             l2c_ciu_ctcq_cmplt_bank_0;     
wire             l2c_ciu_ctcq_cmplt_bank_1;     
wire             l2c_ciu_ctcq_ready_bank_0;     
wire             l2c_ciu_ctcq_ready_bank_1;     
wire    [511:0]  l2c_ciu_data_bank_0;           
wire    [511:0]  l2c_ciu_data_bank_1;           
wire             l2c_ciu_data_ready_bank_0;     
wire             l2c_ciu_data_ready_bank_1;     
wire             l2c_ciu_data_ready_gate_bank_0; 
wire             l2c_ciu_data_ready_gate_bank_1; 
wire    [43 :0]  l2c_ciu_dbg_info;              
wire             l2c_ciu_dca_cmplt_bank_0;      
wire             l2c_ciu_dca_cmplt_bank_1;      
wire    [127:0]  l2c_ciu_dca_data_bank_0;       
wire    [127:0]  l2c_ciu_dca_data_bank_1;       
wire             l2c_ciu_dca_ready_bank_0;      
wire             l2c_ciu_dca_ready_bank_1;      
wire    [1  :0]  l2c_ciu_hpcp_acc_inc_bank_0;   
wire    [1  :0]  l2c_ciu_hpcp_acc_inc_bank_1;   
wire    [2  :0]  l2c_ciu_hpcp_mid_bank_0;       
wire    [2  :0]  l2c_ciu_hpcp_mid_bank_1;       
wire    [1  :0]  l2c_ciu_hpcp_miss_inc_bank_0;  
wire    [1  :0]  l2c_ciu_hpcp_miss_inc_bank_1;  
wire    [33 :0]  l2c_ciu_prf_addr;              
wire    [2  :0]  l2c_ciu_prf_prot;              
wire             l2c_ciu_prf_vld;               
wire    [32 :0]  l2c_ciu_rdl_addr_bank_0;       
wire    [32 :0]  l2c_ciu_rdl_addr_bank_1;       
wire             l2c_ciu_rdl_dvld_bank_0;       
wire             l2c_ciu_rdl_dvld_bank_1;       
wire    [2  :0]  l2c_ciu_rdl_mid_bank_0;        
wire    [2  :0]  l2c_ciu_rdl_mid_bank_1;        
wire    [2  :0]  l2c_ciu_rdl_prot_bank_0;       
wire    [2  :0]  l2c_ciu_rdl_prot_bank_1;       
wire             l2c_ciu_rdl_rvld_bank_0;       
wire             l2c_ciu_rdl_rvld_bank_1;       
wire    [4  :0]  l2c_ciu_resp_bank_0;           
wire    [4  :0]  l2c_ciu_resp_bank_1;           
wire    [4  :0]  l2c_ciu_sid_bank_0;            
wire    [4  :0]  l2c_ciu_sid_bank_1;            
wire    [32 :0]  l2c_ciu_snpl2_addr_bank_0;     
wire    [32 :0]  l2c_ciu_snpl2_addr_bank_1;     
wire    [4  :0]  l2c_ciu_snpl2_ini_sid_bank_0;  
wire    [4  :0]  l2c_ciu_snpl2_ini_sid_bank_1;  
wire             l2c_ciu_snpl2_vld_bank_0;      
wire             l2c_ciu_snpl2_vld_bank_1;      
wire             l2c_data_clk_bank_0;           
wire             l2c_data_clk_bank_1;           
wire             l2c_data_ram_clk_en_bank_0;    
wire             l2c_data_ram_clk_en_bank_1;    
wire    [43 :0]  l2c_had_dbg_info;              
wire             l2c_icg_en;                    
wire             l2c_plic_ecc_int_vld;          
wire             l2c_sysio_flush_done;          
wire             l2c_sysio_flush_idle;          
wire             l2c_tag_clk_bank_0;            
wire             l2c_tag_clk_bank_1;            
wire             l2c_tag_ram_clk_en_bank_0;     
wire             l2c_tag_ram_clk_en_bank_1;     
wire             l2c_xx_no_op;                  
wire             pad_biu_arready;               
wire             pad_biu_awready;               
wire    [7  :0]  pad_biu_bid;                   
wire    [1  :0]  pad_biu_bresp;                 
wire             pad_biu_bvalid;                
wire             pad_biu_csysreq;               
wire    [127:0]  pad_biu_rdata;                 
wire    [7  :0]  pad_biu_rid;                   
wire             pad_biu_rlast;                 
wire    [1  :0]  pad_biu_rresp;                 
wire             pad_biu_rvalid;                
wire             pad_biu_wready;                
wire             pad_core0_dbg_mask;            
wire             pad_core0_dbgrq_b;             
wire    [2  :0]  pad_core0_hartid;              
wire             pad_core0_rst_b;               
wire    [39 :0]  pad_core0_rvba;                
wire             pad_core1_dbg_mask;            
wire             pad_core1_dbgrq_b;             
wire    [2  :0]  pad_core1_hartid;              
wire             pad_core1_rst_b;               
wire    [39 :0]  pad_core1_rvba;                
wire    [39 :0]  pad_cpu_apb_base;              
wire             pad_cpu_l2cache_flush_req;     
wire             pad_cpu_rst_b;                 
wire    [63 :0]  pad_cpu_sys_cnt;               
wire             pad_had_jtg_tclk;              
wire             pad_had_jtg_tdi;               
wire             pad_had_jtg_tms;               
wire             pad_had_jtg_trst_b;            
wire    [39 :0]  pad_ibiu0_acaddr;              
wire    [2  :0]  pad_ibiu0_acprot;              
wire    [3  :0]  pad_ibiu0_acsnoop;             
wire             pad_ibiu0_acvalid;             
wire             pad_ibiu0_arready;             
wire             pad_ibiu0_awready;             
wire    [4  :0]  pad_ibiu0_bid;                 
wire    [1  :0]  pad_ibiu0_bresp;               
wire             pad_ibiu0_bvalid;              
wire             pad_ibiu0_cdready;             
wire             pad_ibiu0_crready;             
wire             pad_ibiu0_csr_cmplt;           
wire    [127:0]  pad_ibiu0_csr_rdata;           
wire             pad_ibiu0_dbgrq_b;             
wire    [3  :0]  pad_ibiu0_hpcp_l2of_int;       
wire             pad_ibiu0_me_int;              
wire             pad_ibiu0_ms_int;              
wire             pad_ibiu0_mt_int;              
wire    [127:0]  pad_ibiu0_rdata;               
wire    [4  :0]  pad_ibiu0_rid;                 
wire             pad_ibiu0_rlast;               
wire    [3  :0]  pad_ibiu0_rresp;               
wire             pad_ibiu0_rvalid;              
wire             pad_ibiu0_se_int;              
wire             pad_ibiu0_ss_int;              
wire             pad_ibiu0_st_int;              
wire             pad_ibiu0_wns_awready;         
wire             pad_ibiu0_wns_wready;          
wire             pad_ibiu0_wready;              
wire             pad_ibiu0_ws_awready;          
wire             pad_ibiu0_ws_wready;           
wire    [39 :0]  pad_ibiu1_acaddr;              
wire    [2  :0]  pad_ibiu1_acprot;              
wire    [3  :0]  pad_ibiu1_acsnoop;             
wire             pad_ibiu1_acvalid;             
wire             pad_ibiu1_arready;             
wire             pad_ibiu1_awready;             
wire    [4  :0]  pad_ibiu1_bid;                 
wire    [1  :0]  pad_ibiu1_bresp;               
wire             pad_ibiu1_bvalid;              
wire             pad_ibiu1_cdready;             
wire             pad_ibiu1_crready;             
wire             pad_ibiu1_csr_cmplt;           
wire    [127:0]  pad_ibiu1_csr_rdata;           
wire             pad_ibiu1_dbgrq_b;             
wire    [3  :0]  pad_ibiu1_hpcp_l2of_int;       
wire             pad_ibiu1_me_int;              
wire             pad_ibiu1_ms_int;              
wire             pad_ibiu1_mt_int;              
wire    [127:0]  pad_ibiu1_rdata;               
wire    [4  :0]  pad_ibiu1_rid;                 
wire             pad_ibiu1_rlast;               
wire    [3  :0]  pad_ibiu1_rresp;               
wire             pad_ibiu1_rvalid;              
wire             pad_ibiu1_se_int;              
wire             pad_ibiu1_ss_int;              
wire             pad_ibiu1_st_int;              
wire             pad_ibiu1_wns_awready;         
wire             pad_ibiu1_wns_wready;          
wire             pad_ibiu1_wready;              
wire             pad_ibiu1_ws_awready;          
wire             pad_ibiu1_ws_wready;           
wire    [2  :0]  pad_l2c_data_mbist_clk_ratio;  
wire    [2  :0]  pad_l2c_tag_mbist_clk_ratio;   
wire    [143:0]  pad_plic_int_cfg;              
wire    [143:0]  pad_plic_int_vld;              
wire             pad_yy_dft_clk_rst_b;          
wire             pad_yy_icg_scan_en;            
wire             pad_yy_mbist_mode;             
wire             pad_yy_scan_mode;              
wire             pad_yy_scan_rst_b;             
wire    [31 :0]  paddr;                         
wire             penable;                       
wire             perr_clint;                    
wire             perr_had;                      
wire             perr_plic;                     
wire             perr_rmr;                      
wire             phl_rst_b;                     
wire    [1  :0]  piu0_sysio_jdb_pm;             
wire    [1  :0]  piu0_sysio_lpmd_b;             
wire    [1  :0]  piu1_sysio_jdb_pm;             
wire    [1  :0]  piu1_sysio_lpmd_b;             
wire             plic_core0_me_int;             
wire             plic_core0_se_int;             
wire             plic_core1_me_int;             
wire             plic_core1_se_int;             
wire    [1  :0]  plic_hartx_mint_req_i;
wire    [1  :0]  plic_hartx_sint_req_i;
wire    [159:0]  plic_int_cfg;                  
wire    [159:0]  plic_int_vld;                  
wire             pll_cpu_clk;                   
  // clint
wire             ipi_i;
wire             time_irq_i;

wire    [1  :0]  pprot;                         
wire    [31 :0]  prdata_clint;                  
wire    [31 :0]  prdata_had;                    
wire    [31 :0]  prdata_plic;                   
wire    [31 :0]  prdata_rmr;                    
wire             pready_clint;                  
wire             pready_had;                    
wire             pready_plic;                   
wire             pready_rmr;                    
wire             psel_clint;                    
wire             psel_had;                      
wire             psel_plic;                     
wire             psel_rmr;                      
wire    [31 :0]  pwdata;                        
wire             pwrite;                        
wire             sm_update_dr;                  
wire             sm_update_ir;                  
wire    [39 :0]  sysio_ciu_apb_base;            
wire    [63 :0]  sysio_clint_mtime;             
wire    [3  :0]  sysio_had_dbg_mask;            
wire             sysio_l2c_flush_req;           
wire             sysio_piu0_dbgrq_b;            
wire             sysio_piu0_me_int;             
wire             sysio_piu0_ms_int;             
wire             sysio_piu0_mt_int;             
wire             sysio_piu0_se_int;             
wire             sysio_piu0_ss_int;             
wire             sysio_piu0_st_int;             
wire             sysio_piu1_dbgrq_b;            
wire             sysio_piu1_me_int;             
wire             sysio_piu1_ms_int;             
wire             sysio_piu1_mt_int;             
wire             sysio_piu1_se_int;             
wire             sysio_piu1_ss_int;             
wire             sysio_piu1_st_int;             
wire    [39 :0]  sysio_xx_apb_base;             
wire    [63 :0]  sysio_xx_time;                 
wire             trst_b;                        

//==========================================================
//  Instance top module
//==========================================================
assign pad_ibiu0_ms_int = ipi_i;
assign pad_ibiu0_mt_int = time_irq_i;

assign pad_ibiu0_ss_int = 1'b0;
assign pad_ibiu0_st_int = 1'b0;

assign pad_ibiu0_me_int = plic_hartx_mint_req_i[0];
assign pad_ibiu0_se_int = plic_hartx_sint_req_i[0];
assign pad_ibiu1_me_int = plic_hartx_mint_req_i[1];
assign pad_ibiu1_se_int = plic_hartx_sint_req_i[1];

// core ace output
assign ibiu0_pad_acready = 1'b1;
assign ibiu0_pad_cddata  = 128'b0;
assign ibiu0_pad_cderr   = 1'b0;
assign ibiu0_pad_cdlast  = 1'b0;
assign ibiu0_pad_cdvalid = 1'b0;
assign ibiu0_pad_crresp  = 5'b0;
assign ibiu0_pad_crvalid = pad_ibiu0_acvalid;

// core axi output
wire awsnoop_evict;
wire [39 :0] awsnoop_evict_awaddr;
wire [7  :0] awsnoop_evict_awlen;
wire [2  :0] awsnoop_evict_awsize;

wire awsnoop_evict_w_valid;
wire awsnoop_evict_w_ready;
wire awsnoop_evict_w_last;
wire awsnoop_evict_aw_valid;
wire awsnoop_evict_aw_ready;

reg  wsnoop_en;

reg dummy_w_req_vld_d, dummy_w_req_vld_q;
reg dummy_w_req_vld_en;

  // record the number of handshaked aw but unsent w burst
wire [8-1:0] unsent_w_cnt_d;
reg  [8-1:0] unsent_w_cnt_q;
wire unsent_w_cnt_en;

wire in_aw_hsk;
wire out_w_hsk;

assign unsent_w_cnt_d  = unsent_w_cnt_q + (in_aw_hsk ? ((&biu_pad_awlen[1:0]) ? 4 : 1) : 0)
                                        - (out_w_hsk ? 1 : 0);
assign unsent_w_cnt_en = out_w_hsk | in_aw_hsk;

assign out_w_hsk = biu_pad_wvalid & pad_biu_wready;
assign in_aw_hsk = biu_pad_awvalid & pad_biu_awready;

  // evict snoop
assign awsnoop_evict = (ibiu0_pad_awsnoop[2  :0] == 3'h4);
assign awsnoop_evict_awaddr = 40'h40000;
assign awsnoop_evict_awlen  = 8'h0;
assign awsnoop_evict_awsize = 3'b0;

assign awsnoop_evict_w_valid  = 1'b1;
assign awsnoop_evict_w_ready  = 1'b0;
assign awsnoop_evict_w_last   = 1'b1;
assign awsnoop_evict_aw_valid = 1'b0;
assign awsnoop_evict_aw_ready = 1'b0;

always @(*) begin
  dummy_w_req_vld_d   = dummy_w_req_vld_q;
  dummy_w_req_vld_en  = 1'b0;
  wsnoop_en  = 1'b0;
  
  case (dummy_w_req_vld_q)
    1'b0: begin
      if(in_aw_hsk & awsnoop_evict) begin
        dummy_w_req_vld_d   = 1'b1;
        dummy_w_req_vld_en  = 1'b1;
      end
    end
    1'b1: begin
      if(unsent_w_cnt_q == 8'b1) begin // no inflight w transaction other than the fake w for evict snoop
        wsnoop_en = 1'b1;
        if(out_w_hsk) begin
          dummy_w_req_vld_d   = 1'b0;
          dummy_w_req_vld_en  = 1'b1;
        end
      end
    end
    default:;
  endcase
end

always @(posedge forever_core0_clk or negedge pad_cpu_rst_b) begin
  if(!pad_cpu_rst_b) begin
    dummy_w_req_vld_q <= 1'b0;
  end else begin
    if(dummy_w_req_vld_en) begin
      dummy_w_req_vld_q <= dummy_w_req_vld_d;
    end
  end
end

always @(posedge forever_core0_clk or negedge pad_cpu_rst_b) begin
  if(!pad_cpu_rst_b) begin
    unsent_w_cnt_q <= 8'b0;
  end else begin
    if(unsent_w_cnt_en) begin
      unsent_w_cnt_q <= unsent_w_cnt_d;
    end
  end
end

assign biu_pad_araddr     [39 :0] = ibiu0_pad_araddr  [39 :0];
assign biu_pad_arburst    [1  :0] = ibiu0_pad_arburst [1  :0];
assign biu_pad_arcache    [3  :0] = ibiu0_pad_arcache [3  :0];
assign biu_pad_arid       [7  :0] = {3'b0, ibiu0_pad_arid    [4  :0]};
assign biu_pad_arlen      [7  :0] = {6'b0, ibiu0_pad_arlen   [1  :0]};
assign biu_pad_arlock             = ibiu0_pad_arlock         ;
assign biu_pad_arprot     [2  :0] = ibiu0_pad_arprot  [2  :0];
assign biu_pad_arsize     [2  :0] = ibiu0_pad_arsize  [2  :0];
assign biu_pad_arvalid            = ibiu0_pad_arvalid        ;
assign biu_pad_awaddr     [39 :0] = awsnoop_evict ? awsnoop_evict_awaddr : ibiu0_pad_awaddr  [39 :0]; // redirect the Evict req to the ACE convert module
assign biu_pad_awburst    [1  :0] = ibiu0_pad_awburst [1  :0];
assign biu_pad_awcache    [3  :0] = ibiu0_pad_awcache [3  :0];
assign biu_pad_awid       [7  :0] = {3'b0, ibiu0_pad_awid    [4  :0]};
assign biu_pad_awlen      [7  :0] = awsnoop_evict ? awsnoop_evict_awlen : {6'b0, ibiu0_pad_awlen   [1  :0]};
assign biu_pad_awlock             = ibiu0_pad_awlock         ;
assign biu_pad_awprot     [2  :0] = ibiu0_pad_awprot  [2  :0];
assign biu_pad_awsize     [2  :0] = awsnoop_evict ? awsnoop_evict_awsize : ibiu0_pad_awsize  [2  :0];
assign biu_pad_awvalid            = dummy_w_req_vld_q ? awsnoop_evict_aw_valid : ibiu0_pad_awvalid        ;
assign biu_pad_bready             = ibiu0_pad_bready         ;
assign biu_pad_rready             = ibiu0_pad_rready         ;
assign biu_pad_wdata      [127:0] = ibiu0_pad_wdata   [127:0];
assign biu_pad_wlast              = wsnoop_en ? awsnoop_evict_w_last : ibiu0_pad_wlast          ;
assign biu_pad_wstrb      [15 :0] = ibiu0_pad_wstrb   [15 :0];
assign biu_pad_wvalid             = wsnoop_en ? awsnoop_evict_w_valid : ibiu0_pad_wvalid         ;

// core axi input
assign pad_ibiu0_arready          = pad_biu_arready          ;
assign pad_ibiu0_rdata    [127:0] = pad_biu_rdata     [127:0];
assign pad_ibiu0_rid      [4  :0] = pad_biu_rid       [4  :0];
assign pad_ibiu0_rlast            = pad_biu_rlast            ;
assign pad_ibiu0_rresp    [3  :0] = {2'b0, pad_biu_rresp     [1  :0]};
assign pad_ibiu0_rvalid           = pad_biu_rvalid           ;
assign pad_ibiu0_bid      [4  :0] = pad_biu_bid       [4  :0];
assign pad_ibiu0_bresp    [1  :0] = pad_biu_bresp     [1  :0];
assign pad_ibiu0_bvalid           = pad_biu_bvalid           ;

assign pad_ibiu0_awready            = dummy_w_req_vld_q ? awsnoop_evict_aw_ready : pad_biu_awready          ;
assign pad_ibiu0_wns_awready        = pad_ibiu0_awready        ;
assign pad_ibiu0_ws_awready         = pad_ibiu0_awready        ;

assign pad_ibiu0_wready             = wsnoop_en ? awsnoop_evict_w_ready : pad_biu_wready           ;
assign pad_ibiu0_wns_wready         = pad_ibiu0_wready         ;
assign pad_ibiu0_ws_wready          = pad_ibiu0_wready         ;

// &ConnRule(s/rtu_/core0_/); @93
// &ConnRule(s/idu_/core0_/); @94
// &ConnRule(s/cp0_/core0_/); @95
// &ConnRule(s/^x_/core0_/); @96
// &Instance("ct_top", "x_ct_top_0"); @97
ct_top  x_ct_top_0 (
  .biu_pad_acready         (      ),
  .biu_pad_araddr          (ibiu0_pad_araddr       ),
  .biu_pad_arbar           (ibiu0_pad_arbar        ),
  .biu_pad_arburst         (ibiu0_pad_arburst      ),
  .biu_pad_arcache         (ibiu0_pad_arcache      ),
  .biu_pad_ardomain        (ibiu0_pad_ardomain     ),
  .biu_pad_arid            (ibiu0_pad_arid         ),
  .biu_pad_arlen           (ibiu0_pad_arlen        ),
  .biu_pad_arlock          (ibiu0_pad_arlock       ),
  .biu_pad_arprot          (ibiu0_pad_arprot       ),
  .biu_pad_arsize          (ibiu0_pad_arsize       ),
  .biu_pad_arsnoop         (ibiu0_pad_arsnoop      ),
  .biu_pad_aruser          (ibiu0_pad_aruser       ),
  .biu_pad_arvalid         (ibiu0_pad_arvalid      ),
  .biu_pad_awaddr          (ibiu0_pad_awaddr       ),
  .biu_pad_awbar           (ibiu0_pad_awbar        ),
  .biu_pad_awburst         (ibiu0_pad_awburst      ),
  .biu_pad_awcache         (ibiu0_pad_awcache      ),
  .biu_pad_awdomain        (ibiu0_pad_awdomain     ),
  .biu_pad_awid            (ibiu0_pad_awid         ),
  .biu_pad_awlen           (ibiu0_pad_awlen        ),
  .biu_pad_awlock          (ibiu0_pad_awlock       ),
  .biu_pad_awprot          (ibiu0_pad_awprot       ),
  .biu_pad_awsize          (ibiu0_pad_awsize       ),
  .biu_pad_awsnoop         (ibiu0_pad_awsnoop      ),
  .biu_pad_awunique        (ibiu0_pad_awunique     ),
  .biu_pad_awuser          (ibiu0_pad_awuser       ),
  .biu_pad_awvalid         (ibiu0_pad_awvalid      ),
  .biu_pad_back            (ibiu0_pad_back         ),
  .biu_pad_bready          (ibiu0_pad_bready       ),
  .biu_pad_cddata          (        ),
  .biu_pad_cderr           (        ),
  .biu_pad_cdlast          (        ),
  .biu_pad_cdvalid         (        ),
  .biu_pad_cnt_en          (        ),
  .biu_pad_crresp          (        ),
  .biu_pad_crvalid         (        ),
  .biu_pad_csr_sel         (        ),
  .biu_pad_csr_wdata       (        ),
  .biu_pad_jdb_pm          (        ),
  .biu_pad_lpmd_b          (        ),
  .biu_pad_rack            (ibiu0_pad_rack         ),
  .biu_pad_rready          (ibiu0_pad_rready       ),
  .biu_pad_wdata           (ibiu0_pad_wdata        ),
  .biu_pad_werr            (ibiu0_pad_werr         ),
  .biu_pad_wlast           (ibiu0_pad_wlast        ),
  .biu_pad_wns             (ibiu0_pad_wns          ),
  .biu_pad_wstrb           (ibiu0_pad_wstrb        ),
  .biu_pad_wvalid          (ibiu0_pad_wvalid       ),
  .cp0_pad_mstatus         (core0_pad_mstatus      ),
  .ir_corex_wdata          (64'b0   ),
  .pad_biu_acaddr          (40'b0   ),
  .pad_biu_acprot          (3'b0    ),
  .pad_biu_acsnoop         (4'b0    ),
  .pad_biu_acvalid         (1'b0    ),
  .pad_biu_arready         (pad_ibiu0_arready      ),
  .pad_biu_awready         (pad_ibiu0_awready      ),
  .pad_biu_bid             (pad_ibiu0_bid          ),
  .pad_biu_bresp           (pad_ibiu0_bresp        ),
  .pad_biu_bvalid          (pad_ibiu0_bvalid       ),
  .pad_biu_cdready         (1'b1    ),
  .pad_biu_crready         (1'b1    ),
  .pad_biu_csr_cmplt       (1'b0    ),
  .pad_biu_csr_rdata       (128'b0  ),
  .pad_biu_dbgrq_b         (1'b1    ),
  .pad_biu_hpcp_l2of_int   (4'b0    ),
  .pad_biu_me_int          (pad_ibiu0_me_int       ),
  .pad_biu_ms_int          (pad_ibiu0_ms_int       ),
  .pad_biu_mt_int          (pad_ibiu0_mt_int       ),
  .pad_biu_rdata           (pad_ibiu0_rdata        ),
  .pad_biu_rid             (pad_ibiu0_rid          ),
  .pad_biu_rlast           (pad_ibiu0_rlast        ),
  .pad_biu_rresp           (pad_ibiu0_rresp        ),
  .pad_biu_rvalid          (pad_ibiu0_rvalid       ),
  .pad_biu_se_int          (pad_ibiu0_se_int       ),
  .pad_biu_ss_int          (pad_ibiu0_ss_int       ),
  .pad_biu_st_int          (pad_ibiu0_st_int       ),
  .pad_biu_wns_awready     (pad_ibiu0_wns_awready  ),
  .pad_biu_wns_wready      (pad_ibiu0_wns_wready   ),
  .pad_biu_wready          (pad_ibiu0_wready       ),
  .pad_biu_ws_awready      (pad_ibiu0_ws_awready   ),
  .pad_biu_ws_wready       (pad_ibiu0_ws_wready    ),
  .pad_core_hartid         (pad_core0_hartid       ),
  .pad_core_rst_b          (core0_rst_b            ),
  .pad_core_rvba           (pad_core0_rvba         ),
  .pad_cpu_rst_b           (cpurst_b               ),
  .pad_xx_apb_base         ({pad_cpu_apb_base[39:27], 27'b0} ),
  .pad_xx_time             (pad_cpu_sys_cnt        ),
  .pad_yy_icg_scan_en      (pad_yy_icg_scan_en     ),
  .pad_yy_mbist_mode       (pad_yy_mbist_mode      ),
  .pad_yy_scan_mode        (pad_yy_scan_mode       ),
  .pad_yy_scan_rst_b       (pad_yy_scan_rst_b      ),
  .pll_core_clk            (forever_core0_clk      ),
  .rtu_cpu_no_retire       (core0_cpu_no_retire    ),
  .rtu_pad_retire0         (core0_pad_retire0      ),
  .rtu_pad_retire0_pc      (core0_pad_retire0_pc   ),
  .rtu_pad_retire1         (core0_pad_retire1      ),
  .rtu_pad_retire1_pc      (core0_pad_retire1_pc   ),
  .rtu_pad_retire2         (core0_pad_retire2      ),
  .rtu_pad_retire2_pc      (core0_pad_retire2_pc   ),
  .sm_update_dr            (1'b0    ),
  .sm_update_ir            (1'b0    ),
  .x_dbg_ack_pc            (        ),
  .x_enter_dbg_req_i       (1'b0    ),
  .x_enter_dbg_req_o       (        ),
  .x_exit_dbg_req_i        (1'b0    ),
  .x_exit_dbg_req_o        (        ),
  .x_had_dbg_mask          (1'b0    ),
  .x_regs_serial_data      (        )
);






//==========================================================
//  Instance ct_reset_top sub module 
//==========================================================
// &Instance("ct_mp_rst_top"); @1504
ct_mp_rst_top  x_ct_mp_rst_top (
  .apbrst_b             (apbrst_b            ),
  .core0_fifo_rst_b     (core0_fifo_rst_b    ),
  .core0_rst_b          (core0_rst_b         ),
  .core1_fifo_rst_b     (core1_fifo_rst_b    ),
  .core1_rst_b          (core1_rst_b         ),
  .cpurst_b             (cpurst_b            ),
  .forever_cpuclk       (forever_cpuclk      ),
  .forever_jtgclk       (forever_jtgclk      ),
  .pad_core0_rst_b      (pad_core0_rst_b     ),
  .pad_core1_rst_b      (pad_core1_rst_b     ),
  .pad_cpu_rst_b        (pad_cpu_rst_b       ),
  .pad_had_jtg_trst_b   (pad_had_jtg_trst_b  ),
  .pad_yy_dft_clk_rst_b (pad_yy_dft_clk_rst_b),
  .pad_yy_mbist_mode    (pad_yy_mbist_mode   ),
  .pad_yy_scan_mode     (pad_yy_scan_mode    ),
  .pad_yy_scan_rst_b    (pad_yy_scan_rst_b   ),
  .phl_rst_b            (phl_rst_b           ),
  .trst_b               (trst_b              )
);

// &Connect(.forever_cpuclk  (forever_cpuclk   )); @1505

//==========================================================
//  Instance ct_clk_top sub module 
//==========================================================
// &Instance("ct_mp_clk_top"); @1510
ct_mp_clk_top  x_ct_mp_clk_top (
  .apb_clk                      (apb_clk                     ),
  .apb_clk_en                   (apb_clk_en                  ),
  .axim_clk_en                  (axim_clk_en                 ),
  .axim_clk_en_f                (axim_clk_en_f               ),
  .forever_core0_clk            (forever_core0_clk           ),
  .forever_core1_clk            (forever_core1_clk           ),
  .forever_cpuclk               (forever_cpuclk              ),
  .forever_jtgclk               (forever_jtgclk              ),
  .l2c_data_clk_bank_0          (l2c_data_clk_bank_0         ),
  .l2c_data_clk_bank_1          (l2c_data_clk_bank_1         ),
  .l2c_data_ram_clk_en_bank_0   (l2c_data_ram_clk_en_bank_0  ),
  .l2c_data_ram_clk_en_bank_1   (l2c_data_ram_clk_en_bank_1  ),
  .l2c_tag_clk_bank_0           (l2c_tag_clk_bank_0          ),
  .l2c_tag_clk_bank_1           (l2c_tag_clk_bank_1          ),
  .l2c_tag_ram_clk_en_bank_0    (l2c_tag_ram_clk_en_bank_0   ),
  .l2c_tag_ram_clk_en_bank_1    (l2c_tag_ram_clk_en_bank_1   ),
  .pad_had_jtg_tclk             (pad_had_jtg_tclk            ),
  .pad_l2c_data_mbist_clk_ratio (pad_l2c_data_mbist_clk_ratio),
  .pad_l2c_tag_mbist_clk_ratio  (pad_l2c_tag_mbist_clk_ratio ),
  .pad_yy_dft_clk_rst_b         (pad_yy_dft_clk_rst_b        ),
  .pad_yy_icg_scan_en           (pad_yy_icg_scan_en          ),
  .pad_yy_mbist_mode            (pad_yy_mbist_mode           ),
  .pad_yy_scan_mode             (pad_yy_scan_mode            ),
  .phl_rst_b                    (phl_rst_b                   ),
  .pll_cpu_clk                  (pll_cpu_clk                 )
);


//==========================================================
//         sysio
//==========================================================
// &Instance("ct_sysio_top"); @1515

assign core1_cpu_no_retire = 1'b0;
assign core2_cpu_no_retire = 1'b0;
assign core3_cpu_no_retire = 1'b0;
assign cpu_debug_port = core0_cpu_no_retire
                     || core1_cpu_no_retire
                     || core2_cpu_no_retire
                     || core3_cpu_no_retire;


// &ModuleEnd; @1597
endmodule



