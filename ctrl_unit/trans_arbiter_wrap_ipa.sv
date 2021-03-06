////////////////////////////////////////////////////////////////////////////////
// Company:        Multitherman Laboratory @ DEIS - University of Bologna     //
//                    Viale Risorgimento 2 40136                              //
//                    Bologna - fax 0512093785 -                              //
//                                                                            //
// Engineer:       Davide Rossi - davide.rossi@unibo.it                       //
//                                                                            //
// Additional contributions by:                                               //
//                  Igor Loi - igor.loi@unibo.it                              //
//                                                                            //
//                                                                            //
// Create Date:    01/06/2015                                                 //
// Design Name:    ULPSoC                                                     //
// Module Name:    mchan_arbiter                                              //
// Project Name:   ULPSoC                                                     //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    MINI DMA CHANNEL                                           //
//                                                                            //
//                                                                            //
// Revision:                                                                  //
// Revision v0.1 - File Created                                               //
// Revision v0.2 - the CORE id is propagated in the mchan arbiter and now     //
//                 is parametric (25/08/2015)                                 //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "mchan_ipa_defines.sv"

module trans_arbiter_wrap_ipa
  #(
    parameter DATA_WIDTH          = 32,
    parameter NB_CORES            = 2,
    parameter MCHAN_LEN_WIDTH     = 5,
    parameter TCDM_ADD_WIDTH      = 16,
    parameter EXT_ADD_WIDTH       = 32,
    parameter MCHAN_OPC_WIDTH     = 1,
    parameter TWD_QUEUE_ADD_WIDTH = 1,
    parameter TRANS_SID_WIDTH     = 1,
    parameter TRANS_CID_WIDTH     = $clog2(NB_CORES)
    )
   (
    input  logic                                         clk_i,
    input  logic                                         rst_ni,
    
    // ---------------- REQ_SIDE --------------------------
    input  logic [NB_CORES-1:0]                          req_i,
    output logic [NB_CORES-1:0]                          gnt_o,
    input  logic [NB_CORES-1:0][EXT_ADD_WIDTH-1:0]       ext_add_i,
    input  logic [NB_CORES-1:0][TCDM_ADD_WIDTH-1:0]      tcdm_add_i,
    input  logic [NB_CORES-1:0][MCHAN_LEN_WIDTH-1:0]     len_i,
    input  logic [NB_CORES-1:0][MCHAN_OPC_WIDTH-1:0]     opc_i,
    input  logic [NB_CORES-1:0]                          inc_i,
    input  logic [NB_CORES-1:0]                          twd_i,
    input  logic [NB_CORES-1:0]                          ele_i,
    input  logic [NB_CORES-1:0]                          ile_i,
    input  logic [NB_CORES-1:0]                          ble_i,
    input  logic [NB_CORES-1:0][TWD_QUEUE_ADD_WIDTH-1:0] twd_add_i,
    input  logic [NB_CORES-1:0][TRANS_SID_WIDTH-1:0]     sid_i,
    
    // Outputs
    output logic                                         req_o,
    input  logic                                         gnt_i,
    output logic  [EXT_ADD_WIDTH-1:0]                    ext_add_o,
    output logic  [TCDM_ADD_WIDTH-1:0]                   tcdm_add_o,
    output logic  [MCHAN_LEN_WIDTH-1:0]                  len_o,
    output logic  [MCHAN_OPC_WIDTH-1:0]                  opc_o,
    output logic                                         inc_o,
    output logic                                         twd_o,
    output logic                                         ele_o,
    output logic                                         ile_o,
    output logic                                         ble_o,
    output logic  [TWD_QUEUE_ADD_WIDTH-1:0]              twd_add_o,
    output logic  [TRANS_SID_WIDTH-1:0]                  sid_o,
    
    output logic  [TRANS_CID_WIDTH-1:0]                  cid_o
    );
   
   logic [NB_CORES-1:0][DATA_WIDTH-1:0] 		 s_dat;
   genvar 						 i;
   
   generate
      for (i =0; i<NB_CORES; i++)
	begin
	   assign s_dat[i] = {sid_i[i],twd_add_i[i],ble_i[i],ile_i[i],ele_i[i],twd_i[i],inc_i[i],opc_i[i],len_i[i],tcdm_add_i[i],ext_add_i[i]};
	end
   endgenerate
   
   mchan_arbiter_ipa
     #(
       .DATA_WIDTH(DATA_WIDTH),
       .N_MASTER(NB_CORES),
       .LOG_MASTER(TRANS_CID_WIDTH)
       )
   arbiter_ipa_i
     (
      
      .clk     ( clk_i  ),
      .rst_n   ( rst_ni ),
      
      .data_i  ( s_dat  ),
      .req_i   ( req_i  ),
      .gnt_o   ( gnt_o  ),
      
      .req_o   ( req_o  ),
      .gnt_i   ( gnt_i  ),
      .id_o    ( cid_o  ),
      .data_o  ( {sid_o,twd_add_o,ble_o,ile_o,ele_o,twd_o,inc_o,opc_o,len_o,tcdm_add_o,ext_add_o} )
      
      );
   
endmodule
