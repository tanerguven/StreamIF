/*
 * StreamIF - AXI4 Memory Mapped to AXI4 Stream Interface Library
 * Copyright (C) 2017 Taner Guven <tanerguven@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of GNU Lesser General Public License
 * along with this library. If not, see <http://www.gnu.org/licenses/>.
 */
module streamif_s2mem #
  (
   // use DATA_WIDTH=32,BURST_LEN=256 || DATA_WIDTH=64,BURST_LEN=128
   parameter integer C_M_AXI_DATA_WIDTH = 32,
   parameter integer C_M_AXI_BURST_LEN = 256,
   parameter C_M_TARGET_SLAVE_BASE_ADDR = 32'h00000000,
   parameter integer C_M_AXI_ID_WIDTH = 1,
   parameter integer C_M_AXI_ADDR_WIDTH = 32,
   parameter integer C_M_AXI_AWUSER_WIDTH = 1,
   parameter integer C_M_AXI_ARUSER_WIDTH = 1,
   parameter integer C_M_AXI_WUSER_WIDTH = 1,
   parameter integer C_M_AXI_RUSER_WIDTH = 1,
   parameter integer C_M_AXI_BUSER_WIDTH = 1
   )
  (
   input wire                               M_AXI_ACLK,
   input wire                               M_AXI_ARESETN,

   input wire [31:0]                        MM2S_CTRL_Addr,
   input wire                               MM2S_CTRL_Start,
   input wire                               MM2S_CTRL_Enabled,
   output wire                              MM2S_CTRL_Idle,
   output wire                              MM2S_CTRL_Last,
   input wire [31:0]                        STREAMIF_CTRL_mm2s_Addr,
   input wire                               STREAMIF_CTRL_mm2s_AddrValid,
   input wire                               STREAMIF_CTRL_mm2s_Start,
   output wire                              STREAMIF_CTRL_mm2s_Idle,
   input wire                               STREAMIF_CTRL_mm2s_Reset,
   output wire                              STREAMIF_CTRL_mm2s_ResetOK,
   input wire                               MM2S_AXIS_TREADY,
   output wire [31 : 0]                     MM2S_AXIS_TDATA,
   output wire [(32/8)-1 : 0]               MM2S_AXIS_TSTRB,
   output wire                              MM2S_AXIS_TLAST,
   output wire                              MM2S_AXIS_TVALID,

   input wire [31:0]                        S2MM_CTRL_Addr,
   input wire                               S2MM_CTRL_Start,
   input wire                               S2MM_CTRL_Enabled,
   output wire                              S2MM_CTRL_Idle,
   output wire                              S2MM_CTRL_Last,
   input wire [31:0]                        STREAMIF_CTRL_s2mm_Addr,
   input wire                               STREAMIF_CTRL_s2mm_AddrValid,
   input wire                               STREAMIF_CTRL_s2mm_Start,
   output wire                              STREAMIF_CTRL_s2mm_Idle,
   input wire                               STREAMIF_CTRL_s2mm_Reset,
   output wire                              STREAMIF_CTRL_s2mm_ResetOK,
   output wire                              S2MM_AXIS_TREADY,
   input wire [31 : 0]                      S2MM_AXIS_TDATA,
   input wire [(32/8)-1 : 0]                S2MM_AXIS_TSTRB,
   input wire                               S2MM_AXIS_TLAST,
   input wire                               S2MM_AXIS_TVALID,


   /* axi4-mm ports */
   output wire [C_M_AXI_ID_WIDTH-1 : 0]     M_AXI_AWID,
   output wire [C_M_AXI_ADDR_WIDTH-1 : 0]   M_AXI_AWADDR,
   output wire [7 : 0]                      M_AXI_AWLEN,
   output wire [2 : 0]                      M_AXI_AWSIZE,
   output wire [1 : 0]                      M_AXI_AWBURST,
   output wire                              M_AXI_AWLOCK,
   output wire [3 : 0]                      M_AXI_AWCACHE,
   output wire [2 : 0]                      M_AXI_AWPROT,
   output wire [3 : 0]                      M_AXI_AWQOS,
   output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
   output wire                              M_AXI_AWVALID,
   input wire                               M_AXI_AWREADY,
   output wire [C_M_AXI_DATA_WIDTH-1 : 0]   M_AXI_WDATA,
   output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
   output wire                              M_AXI_WLAST,
   output wire [C_M_AXI_WUSER_WIDTH-1 : 0]  M_AXI_WUSER,
   output wire                              M_AXI_WVALID,
   input wire                               M_AXI_WREADY,
   input wire [C_M_AXI_ID_WIDTH-1 : 0]      M_AXI_BID,
   input wire [1 : 0]                       M_AXI_BRESP,
   input wire [C_M_AXI_BUSER_WIDTH-1 : 0]   M_AXI_BUSER,
   input wire                               M_AXI_BVALID,
   output wire                              M_AXI_BREADY,
   output wire [C_M_AXI_ID_WIDTH-1 : 0]     M_AXI_ARID,
   output wire [C_M_AXI_ADDR_WIDTH-1 : 0]   M_AXI_ARADDR,
   output wire [7 : 0]                      M_AXI_ARLEN,
   output wire [2 : 0]                      M_AXI_ARSIZE,
   output wire [1 : 0]                      M_AXI_ARBURST,
   output wire                              M_AXI_ARLOCK,
   output wire [3 : 0]                      M_AXI_ARCACHE,
   output wire [2 : 0]                      M_AXI_ARPROT,
   output wire [3 : 0]                      M_AXI_ARQOS,
   output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
   output wire                              M_AXI_ARVALID,
   input wire                               M_AXI_ARREADY,
   input wire [C_M_AXI_ID_WIDTH-1 : 0]      M_AXI_RID,
   input wire [C_M_AXI_DATA_WIDTH-1 : 0]    M_AXI_RDATA,
   input wire [1 : 0]                       M_AXI_RRESP,
   input wire                               M_AXI_RLAST,
   input wire [C_M_AXI_RUSER_WIDTH-1 : 0]   M_AXI_RUSER,
   input wire                               M_AXI_RVALID,
   output wire                              M_AXI_RREADY
   );

  wire                                      ACLK, ARESETN;
  assign ACLK = M_AXI_ACLK;
  assign ARESETN = M_AXI_ARESETN;

  localparam C_MM2S_DATA_WIDTH = 32;
  localparam C_MM2S_BURST_LEN = 256;

  localparam C_S2MM_DATA_WIDTH = 32;
  localparam C_S2MM_BURST_LEN = 256;

  wire [C_M_AXI_ID_WIDTH-1 : 0]             MM2S_AXI_AWID;
  wire [C_M_AXI_ADDR_WIDTH-1 : 0]           MM2S_AXI_AWADDR;
  wire [7 : 0]                              MM2S_AXI_AWLEN;
  wire [2 : 0]                              MM2S_AXI_AWSIZE;
  wire [1 : 0]                              MM2S_AXI_AWBURST;
  wire                                      MM2S_AXI_AWLOCK;
  wire [3 : 0]                              MM2S_AXI_AWCACHE;
  wire [2 : 0]                              MM2S_AXI_AWPROT;
  wire [3 : 0]                              MM2S_AXI_AWQOS;
  wire [C_M_AXI_AWUSER_WIDTH-1 : 0]         MM2S_AXI_AWUSER;
  wire                                      MM2S_AXI_AWVALID;
  wire                                      MM2S_AXI_AWREADY;
  wire [C_MM2S_DATA_WIDTH-1 : 0]            MM2S_AXI_WDATA;
  wire [C_MM2S_DATA_WIDTH/8-1 : 0]          MM2S_AXI_WSTRB;
  wire                                      MM2S_AXI_WLAST;
  wire [C_M_AXI_WUSER_WIDTH-1 : 0]          MM2S_AXI_WUSER;
  wire                                      MM2S_AXI_WVALID;
  wire                                      MM2S_AXI_WREADY;
  wire [C_M_AXI_ID_WIDTH-1 : 0]             MM2S_AXI_BID;
  wire [1 : 0]                              MM2S_AXI_BRESP;
  wire [C_M_AXI_BUSER_WIDTH-1 : 0]          MM2S_AXI_BUSER;
  wire                                      MM2S_AXI_BVALID;
  wire                                      MM2S_AXI_BREADY;
  wire [C_M_AXI_ID_WIDTH-1 : 0]             MM2S_AXI_ARID;
  wire [C_M_AXI_ADDR_WIDTH-1 : 0]           MM2S_AXI_ARADDR;
  wire [7 : 0]                              MM2S_AXI_ARLEN;
  wire [2 : 0]                              MM2S_AXI_ARSIZE;
  wire [1 : 0]                              MM2S_AXI_ARBURST;
  wire                                      MM2S_AXI_ARLOCK;
  wire [3 : 0]                              MM2S_AXI_ARCACHE;
  wire [2 : 0]                              MM2S_AXI_ARPROT;
  wire [3 : 0]                              MM2S_AXI_ARQOS;
  wire [C_M_AXI_ARUSER_WIDTH-1 : 0]         MM2S_AXI_ARUSER;
  wire                                      MM2S_AXI_ARVALID;
  wire                                      MM2S_AXI_ARREADY;
  wire [C_M_AXI_ID_WIDTH-1 : 0]             MM2S_AXI_RID;
  wire [C_MM2S_DATA_WIDTH-1 : 0]            MM2S_AXI_RDATA;
  wire [1 : 0]                              MM2S_AXI_RRESP;
  wire                                      MM2S_AXI_RLAST;
  wire [C_M_AXI_RUSER_WIDTH-1 : 0]          MM2S_AXI_RUSER;
  wire                                      MM2S_AXI_RVALID;
  wire                                      MM2S_AXI_RREADY;

  wire [C_M_AXI_ID_WIDTH-1 : 0]             S2MM_AXI_AWID;
  wire [C_M_AXI_ADDR_WIDTH-1 : 0]           S2MM_AXI_AWADDR;
  wire [7 : 0]                              S2MM_AXI_AWLEN;
  wire [2 : 0]                              S2MM_AXI_AWSIZE;
  wire [1 : 0]                              S2MM_AXI_AWBURST;
  wire                                      S2MM_AXI_AWLOCK;
  wire [3 : 0]                              S2MM_AXI_AWCACHE;
  wire [2 : 0]                              S2MM_AXI_AWPROT;
  wire [3 : 0]                              S2MM_AXI_AWQOS;
  wire [C_M_AXI_AWUSER_WIDTH-1 : 0]         S2MM_AXI_AWUSER;
  wire                                      S2MM_AXI_AWVALID;
  wire                                      S2MM_AXI_AWREADY;
  wire [C_S2MM_DATA_WIDTH-1 : 0]            S2MM_AXI_WDATA;
  wire [C_S2MM_DATA_WIDTH/8-1 : 0]          S2MM_AXI_WSTRB;
  wire                                      S2MM_AXI_WLAST;
  wire [C_M_AXI_WUSER_WIDTH-1 : 0]          S2MM_AXI_WUSER;
  wire                                      S2MM_AXI_WVALID;
  wire                                      S2MM_AXI_WREADY;
  wire [C_M_AXI_ID_WIDTH-1 : 0]             S2MM_AXI_BID;
  wire [1 : 0]                              S2MM_AXI_BRESP;
  wire [C_M_AXI_BUSER_WIDTH-1 : 0]          S2MM_AXI_BUSER;
  wire                                      S2MM_AXI_BVALID;
  wire                                      S2MM_AXI_BREADY;
  wire [C_M_AXI_ID_WIDTH-1 : 0]             S2MM_AXI_ARID;
  wire [C_M_AXI_ADDR_WIDTH-1 : 0]           S2MM_AXI_ARADDR;
  wire [7 : 0]                              S2MM_AXI_ARLEN;
  wire [2 : 0]                              S2MM_AXI_ARSIZE;
  wire [1 : 0]                              S2MM_AXI_ARBURST;
  wire                                      S2MM_AXI_ARLOCK;
  wire [3 : 0]                              S2MM_AXI_ARCACHE;
  wire [2 : 0]                              S2MM_AXI_ARPROT;
  wire [3 : 0]                              S2MM_AXI_ARQOS;
  wire [C_M_AXI_ARUSER_WIDTH-1 : 0]         S2MM_AXI_ARUSER;
  wire                                      S2MM_AXI_ARVALID;
  wire                                      S2MM_AXI_ARREADY;
  wire [C_M_AXI_ID_WIDTH-1 : 0]             S2MM_AXI_RID;
  wire [C_S2MM_DATA_WIDTH-1 : 0]            S2MM_AXI_RDATA;
  wire [1 : 0]                              S2MM_AXI_RRESP;
  wire                                      S2MM_AXI_RLAST;
  wire [C_M_AXI_RUSER_WIDTH-1 : 0]          S2MM_AXI_RUSER;
  wire                                      S2MM_AXI_RVALID;
  wire                                      S2MM_AXI_RREADY;

  wire [C_M_AXI_ID_WIDTH-1 : 0]             M_AXI_MERGE_AWID;
  wire [C_M_AXI_ADDR_WIDTH-1 : 0]           M_AXI_MERGE_AWADDR;
  wire [7 : 0]                              M_AXI_MERGE_AWLEN;
  wire [2 : 0]                              M_AXI_MERGE_AWSIZE;
  wire [1 : 0]                              M_AXI_MERGE_AWBURST;
  wire                                      M_AXI_MERGE_AWLOCK;
  wire [3 : 0]                              M_AXI_MERGE_AWCACHE;
  wire [2 : 0]                              M_AXI_MERGE_AWPROT;
  wire [3 : 0]                              M_AXI_MERGE_AWQOS;
  wire [C_M_AXI_AWUSER_WIDTH-1 : 0]         M_AXI_MERGE_AWUSER;
  wire                                      M_AXI_MERGE_AWVALID;
  wire                                      M_AXI_MERGE_AWREADY;
  wire [C_S2MM_DATA_WIDTH-1 : 0]            M_AXI_MERGE_WDATA;
  wire [C_S2MM_DATA_WIDTH/8-1 : 0]          M_AXI_MERGE_WSTRB;
  wire                                      M_AXI_MERGE_WLAST;
  wire [C_M_AXI_WUSER_WIDTH-1 : 0]          M_AXI_MERGE_WUSER;
  wire                                      M_AXI_MERGE_WVALID;
  wire                                      M_AXI_MERGE_WREADY;
  wire [C_M_AXI_ID_WIDTH-1 : 0]             M_AXI_MERGE_BID;
  wire [1 : 0]                              M_AXI_MERGE_BRESP;
  wire [C_M_AXI_BUSER_WIDTH-1 : 0]          M_AXI_MERGE_BUSER;
  wire                                      M_AXI_MERGE_BVALID;
  wire                                      M_AXI_MERGE_BREADY;
  wire [C_M_AXI_ID_WIDTH-1 : 0]             M_AXI_MERGE_ARID;
  wire [C_M_AXI_ADDR_WIDTH-1 : 0]           M_AXI_MERGE_ARADDR;
  wire [7 : 0]                              M_AXI_MERGE_ARLEN;
  wire [2 : 0]                              M_AXI_MERGE_ARSIZE;
  wire [1 : 0]                              M_AXI_MERGE_ARBURST;
  wire                                      M_AXI_MERGE_ARLOCK;
  wire [3 : 0]                              M_AXI_MERGE_ARCACHE;
  wire [2 : 0]                              M_AXI_MERGE_ARPROT;
  wire [3 : 0]                              M_AXI_MERGE_ARQOS;
  wire [C_M_AXI_ARUSER_WIDTH-1 : 0]         M_AXI_MERGE_ARUSER;
  wire                                      M_AXI_MERGE_ARVALID;
  wire                                      M_AXI_MERGE_ARREADY;
  wire [C_M_AXI_ID_WIDTH-1 : 0]             M_AXI_MERGE_RID;
  wire [C_S2MM_DATA_WIDTH-1 : 0]            M_AXI_MERGE_RDATA;
  wire [1 : 0]                              M_AXI_MERGE_RRESP;
  wire                                      M_AXI_MERGE_RLAST;
  wire [C_M_AXI_RUSER_WIDTH-1 : 0]          M_AXI_MERGE_RUSER;
  wire                                      M_AXI_MERGE_RVALID;
  wire                                      M_AXI_MERGE_RREADY;


  /* ================================== */
  /* ==========    MM2S    ============ */
  /* ================================== */

  assign MM2S_CTRL_Last = MM2S_AXI_RLAST && MM2S_AXI_RVALID;

  /* mm2s_read_address */
  reg [31:0]                                mm2s_read_address;
  always @(posedge ACLK) begin
    if (ARESETN == 0) begin
      mm2s_read_address <= 0;
    end else begin
      if (MM2S_CTRL_Enabled)
        mm2s_read_address <= MM2S_CTRL_Addr;
      else if (STREAMIF_CTRL_mm2s_AddrValid)
        mm2s_read_address <= STREAMIF_CTRL_mm2s_Addr;
      else
        mm2s_read_address <= mm2s_read_address;
    end
  end

  /* mm2s_idle signal */
  wire           mm2s_idle;
  assign STREAMIF_CTRL_mm2s_Idle = mm2s_idle;
  assign MM2S_CTRL_Idle = mm2s_idle;


  /* mm2s_start_signal logic */
  wire           mm2s_start_input;
  assign mm2s_start_input = (MM2S_CTRL_Enabled) ? MM2S_CTRL_Start : STREAMIF_CTRL_mm2s_Start;
  reg            mm2s_start_input_old;
  wire           mm2s_start_signal;
  always @(posedge ACLK) begin
    if (ARESETN == 0) begin
      mm2s_start_input_old <= 0; // FIXME: 1 ile baslarsa daha iyi olur
    end else begin
      mm2s_start_input_old <= mm2s_start_input;
    end
  end
  assign mm2s_start_signal = (~mm2s_start_input_old & mm2s_start_input);

  reg mm2s_start_signal_d;
  always @(posedge ACLK) begin
    if (ARESETN == 0)
      mm2s_start_signal_d <= 0;
    else
      mm2s_start_signal_d <= mm2s_start_signal;
  end

  axi4_full_to_stream #
    (
     .C_M_AXI_BURST_LEN(C_MM2S_BURST_LEN),
     .C_AXI_DATA_WIDTH(C_MM2S_DATA_WIDTH),
     .C_M_TARGET_SLAVE_BASE_ADDR(C_M_TARGET_SLAVE_BASE_ADDR),
     .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
     .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
     .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
     .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
     .C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
     .C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
     .C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
     )
  mm2s
    (
     .ACLK(ACLK),
     .ARESETN(ARESETN),
     .sw_reset(STREAMIF_CTRL_mm2s_Reset),
     .sw_reset_ok(STREAMIF_CTRL_mm2s_ResetOK),
     /* */
     .read_address(mm2s_read_address),
     .start_read(mm2s_start_signal_d),
     .output_idle(mm2s_idle),
     /* */
     .M_AXI_AWID(MM2S_AXI_AWID),
     .M_AXI_AWADDR(MM2S_AXI_AWADDR),
     .M_AXI_AWLEN(MM2S_AXI_AWLEN),
     .M_AXI_AWSIZE(MM2S_AXI_AWSIZE),
     .M_AXI_AWBURST(MM2S_AXI_AWBURST),
     .M_AXI_AWLOCK(MM2S_AXI_AWLOCK),
     .M_AXI_AWCACHE(MM2S_AXI_AWCACHE),
     .M_AXI_AWPROT(MM2S_AXI_AWPROT),
     .M_AXI_AWQOS(MM2S_AXI_AWQOS),
     .M_AXI_AWUSER(MM2S_AXI_AWUSER),
     .M_AXI_AWVALID(MM2S_AXI_AWVALID),
     .M_AXI_AWREADY(MM2S_AXI_AWREADY),
     .M_AXI_WDATA(MM2S_AXI_WDATA),
     .M_AXI_WSTRB(MM2S_AXI_WSTRB),
     .M_AXI_WLAST(MM2S_AXI_WLAST),
     .M_AXI_WUSER(MM2S_AXI_WUSER),
     .M_AXI_WVALID(MM2S_AXI_WVALID),
     .M_AXI_WREADY(MM2S_AXI_WREADY),
     .M_AXI_BID(MM2S_AXI_BID),
     .M_AXI_BRESP(MM2S_AXI_BRESP),
     .M_AXI_BUSER(MM2S_AXI_BUSER),
     .M_AXI_BVALID(MM2S_AXI_BVALID),
     .M_AXI_BREADY(MM2S_AXI_BREADY),
     .M_AXI_ARID(MM2S_AXI_ARID),
     .M_AXI_ARADDR(MM2S_AXI_ARADDR),
     .M_AXI_ARLEN(MM2S_AXI_ARLEN),
     .M_AXI_ARSIZE(MM2S_AXI_ARSIZE),
     .M_AXI_ARBURST(MM2S_AXI_ARBURST),
     .M_AXI_ARLOCK(MM2S_AXI_ARLOCK),
     .M_AXI_ARCACHE(MM2S_AXI_ARCACHE),
     .M_AXI_ARPROT(MM2S_AXI_ARPROT),
     .M_AXI_ARQOS(MM2S_AXI_ARQOS),
     .M_AXI_ARUSER(MM2S_AXI_ARUSER),
     .M_AXI_ARVALID(MM2S_AXI_ARVALID),
     .M_AXI_ARREADY(MM2S_AXI_ARREADY),
     .M_AXI_RID(MM2S_AXI_RID),
     .M_AXI_RDATA(MM2S_AXI_RDATA),
     .M_AXI_RRESP(MM2S_AXI_RRESP),
     .M_AXI_RLAST(MM2S_AXI_RLAST),
     .M_AXI_RUSER(MM2S_AXI_RUSER),
     .M_AXI_RVALID(MM2S_AXI_RVALID),
     .M_AXI_RREADY(MM2S_AXI_RREADY),
     /* */
     .M_AXIS_TVALID(MM2S_AXIS_TVALID),
     .M_AXIS_TDATA(MM2S_AXIS_TDATA),
     .M_AXIS_TSTRB(MM2S_AXIS_TSTRB),
     .M_AXIS_TLAST(MM2S_AXIS_TLAST),
     .M_AXIS_TREADY(MM2S_AXIS_TREADY)
     );



  /* ================================== */
  /* ==========    S2MM    ============ */
  /* ================================== */

  assign S2MM_CTRL_Last = S2MM_AXI_WLAST && S2MM_AXI_WVALID;

  /* s2mm_write_address */
  reg [31:0]         s2mm_write_address;
  always @(posedge ACLK) begin
    if (ARESETN == 0) begin
      s2mm_write_address <= 0;
    end else begin
      if (S2MM_CTRL_Enabled)
        s2mm_write_address <= S2MM_CTRL_Addr;
      else if (STREAMIF_CTRL_s2mm_AddrValid)
        s2mm_write_address <= STREAMIF_CTRL_s2mm_Addr;
      else
        s2mm_write_address <= s2mm_write_address;
    end
  end

  /* idle signal */
  wire           s2mm_idle;
  assign STREAMIF_CTRL_s2mm_Idle = s2mm_idle;
  assign S2MM_CTRL_Idle = s2mm_idle;


  /* s2mm_start_signal logic */
  wire           s2mm_start_input;
  assign s2mm_start_input = (S2MM_CTRL_Enabled) ? S2MM_CTRL_Start : STREAMIF_CTRL_s2mm_Start;
  reg            s2mm_start_input_old;
  wire           s2mm_start_signal;
  always @(posedge ACLK) begin
    if (ARESETN == 0) begin
      s2mm_start_input_old <= 0;
    end else begin
      s2mm_start_input_old <= s2mm_start_input;
    end
  end
  assign s2mm_start_signal = (~s2mm_start_input_old & s2mm_start_input);

  reg s2mm_start_signal_d;
  always @(posedge ACLK) begin
    if (ARESETN == 0)
      s2mm_start_signal_d <= 0;
    else
      s2mm_start_signal_d <= s2mm_start_signal;
  end

  axi4_stream_to_full #
    (
     .C_AXI_DATA_WIDTH(C_S2MM_DATA_WIDTH),
     .C_M_TARGET_SLAVE_BASE_ADDR(C_M_TARGET_SLAVE_BASE_ADDR),
     .C_M_AXI_BURST_LEN(C_S2MM_BURST_LEN),
     .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
     .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
     .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
     .C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
     .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
     .C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
     .C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
     )
  s2mm
    (
     .ACLK(ACLK),
     .ARESETN(ARESETN),
     .sw_reset(STREAMIF_CTRL_s2mm_Reset),
     .sw_reset_ok(STREAMIF_CTRL_s2mm_ResetOK),
     /* control ports */
     .write_address(s2mm_write_address),
     .write_start(s2mm_start_signal_d),
     .output_idle(s2mm_idle),
     .debug_data_sum(),
     /* axi4-stream ports */
     .S_AXIS_TREADY(S2MM_AXIS_TREADY),
     .S_AXIS_TDATA(S2MM_AXIS_TDATA),
     .S_AXIS_TSTRB(S2MM_AXIS_TSTRB),
     .S_AXIS_TLAST(S2MM_AXIS_TLAST),
     .S_AXIS_TVALID(S2MM_AXIS_TVALID),
     /* axi4-mm ports */
     .M_AXI_AWID(S2MM_AXI_AWID),
     .M_AXI_AWADDR(S2MM_AXI_AWADDR),
     .M_AXI_AWLEN(S2MM_AXI_AWLEN),
     .M_AXI_AWSIZE(S2MM_AXI_AWSIZE),
     .M_AXI_AWBURST(S2MM_AXI_AWBURST),
     .M_AXI_AWLOCK(S2MM_AXI_AWLOCK),
     .M_AXI_AWCACHE(S2MM_AXI_AWCACHE),
     .M_AXI_AWPROT(S2MM_AXI_AWPROT),
     .M_AXI_AWQOS(S2MM_AXI_AWQOS),
     .M_AXI_AWUSER(S2MM_AXI_AWUSER),
     .M_AXI_AWVALID(S2MM_AXI_AWVALID),
     .M_AXI_AWREADY(S2MM_AXI_AWREADY),
     .M_AXI_WDATA(S2MM_AXI_WDATA),
     .M_AXI_WSTRB(S2MM_AXI_WSTRB),
     .M_AXI_WLAST(S2MM_AXI_WLAST),
     .M_AXI_WUSER(S2MM_AXI_WUSER),
     .M_AXI_WVALID(S2MM_AXI_WVALID),
     .M_AXI_WREADY(S2MM_AXI_WREADY),
     .M_AXI_BID(S2MM_AXI_BID),
     .M_AXI_BRESP(S2MM_AXI_BRESP),
     .M_AXI_BUSER(S2MM_AXI_BUSER),
     .M_AXI_BVALID(S2MM_AXI_BVALID),
     .M_AXI_BREADY(S2MM_AXI_BREADY),
     .M_AXI_ARID(S2MM_AXI_ARID),
     .M_AXI_ARADDR(S2MM_AXI_ARADDR),
     .M_AXI_ARLEN(S2MM_AXI_ARLEN),
     .M_AXI_ARSIZE(S2MM_AXI_ARSIZE),
     .M_AXI_ARBURST(S2MM_AXI_ARBURST),
     .M_AXI_ARLOCK(S2MM_AXI_ARLOCK),
     .M_AXI_ARCACHE(S2MM_AXI_ARCACHE),
     .M_AXI_ARPROT(S2MM_AXI_ARPROT),
     .M_AXI_ARQOS(S2MM_AXI_ARQOS),
     .M_AXI_ARUSER(S2MM_AXI_ARUSER),
     .M_AXI_ARVALID(S2MM_AXI_ARVALID),
     .M_AXI_ARREADY(S2MM_AXI_ARREADY),
     .M_AXI_RID(S2MM_AXI_RID),
     .M_AXI_RDATA(S2MM_AXI_RDATA),
     .M_AXI_RRESP(S2MM_AXI_RRESP),
     .M_AXI_RLAST(S2MM_AXI_RLAST),
     .M_AXI_RUSER(S2MM_AXI_RUSER),
     .M_AXI_RVALID(S2MM_AXI_RVALID),
     .M_AXI_RREADY(S2MM_AXI_RREADY)
     );



  /* ================================== */
  /* ==========    Merge   ============ */
  /* ================================== */

  axi4_read_write_merge #
    (
     .C_M_AXI_BURST_LEN(C_S2MM_BURST_LEN),
     .C_M_AXI_DATA_WIDTH(C_S2MM_DATA_WIDTH),
     .C_M_TARGET_SLAVE_BASE_ADDR(C_M_TARGET_SLAVE_BASE_ADDR),
     .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
     .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
     .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
     .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
     .C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
     .C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
     .C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
     )
  merge
    (
     .S_AXI_READ_AWID(MM2S_AXI_AWID),
     .S_AXI_READ_AWADDR(MM2S_AXI_AWADDR),
     .S_AXI_READ_AWLEN(MM2S_AXI_AWLEN),
     .S_AXI_READ_AWSIZE(MM2S_AXI_AWSIZE),
     .S_AXI_READ_AWBURST(MM2S_AXI_AWBURST),
     .S_AXI_READ_AWLOCK(MM2S_AXI_AWLOCK),
     .S_AXI_READ_AWCACHE(MM2S_AXI_AWCACHE),
     .S_AXI_READ_AWPROT(MM2S_AXI_AWPROT),
     .S_AXI_READ_AWQOS(MM2S_AXI_AWQOS),
     .S_AXI_READ_AWUSER(MM2S_AXI_AWUSER),
     .S_AXI_READ_AWVALID(MM2S_AXI_AWVALID),
     .S_AXI_READ_AWREADY(MM2S_AXI_AWREADY),
     .S_AXI_READ_WDATA(MM2S_AXI_WDATA),
     .S_AXI_READ_WSTRB(MM2S_AXI_WSTRB),
     .S_AXI_READ_WLAST(MM2S_AXI_WLAST),
     .S_AXI_READ_WUSER(MM2S_AXI_WUSER),
     .S_AXI_READ_WVALID(MM2S_AXI_WVALID),
     .S_AXI_READ_WREADY(MM2S_AXI_WREADY),
     .S_AXI_READ_BID(MM2S_AXI_BID),
     .S_AXI_READ_BRESP(MM2S_AXI_BRESP),
     .S_AXI_READ_BUSER(MM2S_AXI_BUSER),
     .S_AXI_READ_BVALID(MM2S_AXI_BVALID),
     .S_AXI_READ_BREADY(MM2S_AXI_BREADY),
     .S_AXI_READ_ARID(MM2S_AXI_ARID),
     .S_AXI_READ_ARADDR(MM2S_AXI_ARADDR),
     .S_AXI_READ_ARLEN(MM2S_AXI_ARLEN),
     .S_AXI_READ_ARSIZE(MM2S_AXI_ARSIZE),
     .S_AXI_READ_ARBURST(MM2S_AXI_ARBURST),
     .S_AXI_READ_ARLOCK(MM2S_AXI_ARLOCK),
     .S_AXI_READ_ARCACHE(MM2S_AXI_ARCACHE),
     .S_AXI_READ_ARPROT(MM2S_AXI_ARPROT),
     .S_AXI_READ_ARQOS(MM2S_AXI_ARQOS),
     .S_AXI_READ_ARUSER(MM2S_AXI_ARUSER),
     .S_AXI_READ_ARVALID(MM2S_AXI_ARVALID),
     .S_AXI_READ_ARREADY(MM2S_AXI_ARREADY),
     .S_AXI_READ_RID(MM2S_AXI_RID),
     .S_AXI_READ_RDATA(MM2S_AXI_RDATA),
     .S_AXI_READ_RRESP(MM2S_AXI_RRESP),
     .S_AXI_READ_RLAST(MM2S_AXI_RLAST),
     .S_AXI_READ_RUSER(MM2S_AXI_RUSER),
     .S_AXI_READ_RVALID(MM2S_AXI_RVALID),
     .S_AXI_READ_RREADY(MM2S_AXI_RREADY),

     .S_AXI_WRITE_AWID(S2MM_AXI_AWID),
     .S_AXI_WRITE_AWADDR(S2MM_AXI_AWADDR),
     .S_AXI_WRITE_AWLEN(S2MM_AXI_AWLEN),
     .S_AXI_WRITE_AWSIZE(S2MM_AXI_AWSIZE),
     .S_AXI_WRITE_AWBURST(S2MM_AXI_AWBURST),
     .S_AXI_WRITE_AWLOCK(S2MM_AXI_AWLOCK),
     .S_AXI_WRITE_AWCACHE(S2MM_AXI_AWCACHE),
     .S_AXI_WRITE_AWPROT(S2MM_AXI_AWPROT),
     .S_AXI_WRITE_AWQOS(S2MM_AXI_AWQOS),
     .S_AXI_WRITE_AWUSER(S2MM_AXI_AWUSER),
     .S_AXI_WRITE_AWVALID(S2MM_AXI_AWVALID),
     .S_AXI_WRITE_AWREADY(S2MM_AXI_AWREADY),
     .S_AXI_WRITE_WDATA(S2MM_AXI_WDATA),
     .S_AXI_WRITE_WSTRB(S2MM_AXI_WSTRB),
     .S_AXI_WRITE_WLAST(S2MM_AXI_WLAST),
     .S_AXI_WRITE_WUSER(S2MM_AXI_WUSER),
     .S_AXI_WRITE_WVALID(S2MM_AXI_WVALID),
     .S_AXI_WRITE_WREADY(S2MM_AXI_WREADY),
     .S_AXI_WRITE_BID(S2MM_AXI_BID),
     .S_AXI_WRITE_BRESP(S2MM_AXI_BRESP),
     .S_AXI_WRITE_BUSER(S2MM_AXI_BUSER),
     .S_AXI_WRITE_BVALID(S2MM_AXI_BVALID),
     .S_AXI_WRITE_BREADY(S2MM_AXI_BREADY),
     .S_AXI_WRITE_ARID(S2MM_AXI_ARID),
     .S_AXI_WRITE_ARADDR(S2MM_AXI_ARADDR),
     .S_AXI_WRITE_ARLEN(S2MM_AXI_ARLEN),
     .S_AXI_WRITE_ARSIZE(S2MM_AXI_ARSIZE),
     .S_AXI_WRITE_ARBURST(S2MM_AXI_ARBURST),
     .S_AXI_WRITE_ARLOCK(S2MM_AXI_ARLOCK),
     .S_AXI_WRITE_ARCACHE(S2MM_AXI_ARCACHE),
     .S_AXI_WRITE_ARPROT(S2MM_AXI_ARPROT),
     .S_AXI_WRITE_ARQOS(S2MM_AXI_ARQOS),
     .S_AXI_WRITE_ARUSER(S2MM_AXI_ARUSER),
     .S_AXI_WRITE_ARVALID(S2MM_AXI_ARVALID),
     .S_AXI_WRITE_ARREADY(S2MM_AXI_ARREADY),
     .S_AXI_WRITE_RID(S2MM_AXI_RID),
     .S_AXI_WRITE_RDATA(S2MM_AXI_RDATA),
     .S_AXI_WRITE_RRESP(S2MM_AXI_RRESP),
     .S_AXI_WRITE_RLAST(S2MM_AXI_RLAST),
     .S_AXI_WRITE_RUSER(S2MM_AXI_RUSER),
     .S_AXI_WRITE_RVALID(S2MM_AXI_RVALID),
     .S_AXI_WRITE_RREADY(S2MM_AXI_RREADY),

     .M_AXI_ACLK(ACLK),
     .M_AXI_ARESETN(ARESETN),
     .M_AXI_AWID(M_AXI_MERGE_AWID),
     .M_AXI_AWADDR(M_AXI_MERGE_AWADDR),
     .M_AXI_AWLEN(M_AXI_MERGE_AWLEN),
     .M_AXI_AWSIZE(M_AXI_MERGE_AWSIZE),
     .M_AXI_AWBURST(M_AXI_MERGE_AWBURST),
     .M_AXI_AWLOCK(M_AXI_MERGE_AWLOCK),
     .M_AXI_AWCACHE(M_AXI_MERGE_AWCACHE),
     .M_AXI_AWPROT(M_AXI_MERGE_AWPROT),
     .M_AXI_AWQOS(M_AXI_MERGE_AWQOS),
     .M_AXI_AWUSER(M_AXI_MERGE_AWUSER),
     .M_AXI_AWVALID(M_AXI_MERGE_AWVALID),
     .M_AXI_AWREADY(M_AXI_MERGE_AWREADY),
     .M_AXI_WDATA(M_AXI_MERGE_WDATA),
     .M_AXI_WSTRB(M_AXI_MERGE_WSTRB),
     .M_AXI_WLAST(M_AXI_MERGE_WLAST),
     .M_AXI_WUSER(M_AXI_MERGE_WUSER),
     .M_AXI_WVALID(M_AXI_MERGE_WVALID),
     .M_AXI_WREADY(M_AXI_MERGE_WREADY),
     .M_AXI_BID(M_AXI_MERGE_BID),
     .M_AXI_BRESP(M_AXI_MERGE_BRESP),
     .M_AXI_BUSER(M_AXI_MERGE_BUSER),
     .M_AXI_BVALID(M_AXI_MERGE_BVALID),
     .M_AXI_BREADY(M_AXI_MERGE_BREADY),
     .M_AXI_ARID(M_AXI_MERGE_ARID),
     .M_AXI_ARADDR(M_AXI_MERGE_ARADDR),
     .M_AXI_ARLEN(M_AXI_MERGE_ARLEN),
     .M_AXI_ARSIZE(M_AXI_MERGE_ARSIZE),
     .M_AXI_ARBURST(M_AXI_MERGE_ARBURST),
     .M_AXI_ARLOCK(M_AXI_MERGE_ARLOCK),
     .M_AXI_ARCACHE(M_AXI_MERGE_ARCACHE),
     .M_AXI_ARPROT(M_AXI_MERGE_ARPROT),
     .M_AXI_ARQOS(M_AXI_MERGE_ARQOS),
     .M_AXI_ARUSER(M_AXI_MERGE_ARUSER),
     .M_AXI_ARVALID(M_AXI_MERGE_ARVALID),
     .M_AXI_ARREADY(M_AXI_MERGE_ARREADY),
     .M_AXI_RID(M_AXI_MERGE_RID),
     .M_AXI_RDATA(M_AXI_MERGE_RDATA),
     .M_AXI_RRESP(M_AXI_MERGE_RRESP),
     .M_AXI_RLAST(M_AXI_MERGE_RLAST),
     .M_AXI_RUSER(M_AXI_MERGE_RUSER),
     .M_AXI_RVALID(M_AXI_MERGE_RVALID),
     .M_AXI_RREADY(M_AXI_MERGE_RREADY)
     );

  /* ================================== */
  /* ====== Datawidth Converter ======= */
  /* ================================== */

  generate

    if (C_M_AXI_DATA_WIDTH == 64 && C_M_AXI_BURST_LEN == 128)
      begin
        axi4_32bit_to_64bit #
          (
           .C_S_AXI_BURST_LEN(256),
           .C_S_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
           .C_S_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
           .C_S_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
           .C_S_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
           .C_S_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
           .C_S_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
           .C_S_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH),

           .C_M_AXI_BURST_LEN(128),
           .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
           .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
           .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
           .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
           .C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
           .C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
           .C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
           )
        datawidth_converter
          (
           .debug_read(),
           .debug_write(),
           /* */
           .M_AXI_ACLK(ACLK),
           .M_AXI_ARESETN(ARESETN),
           .M_AXI_AWID(M_AXI_AWID),
           .M_AXI_AWADDR(M_AXI_AWADDR),
           .M_AXI_AWLEN(M_AXI_AWLEN),
           .M_AXI_AWSIZE(M_AXI_AWSIZE),
           .M_AXI_AWBURST(M_AXI_AWBURST),
           .M_AXI_AWLOCK(M_AXI_AWLOCK),
           .M_AXI_AWCACHE(M_AXI_AWCACHE),
           .M_AXI_AWPROT(M_AXI_AWPROT),
           .M_AXI_AWQOS(M_AXI_AWQOS),
           .M_AXI_AWUSER(M_AXI_AWUSER),
           .M_AXI_AWVALID(M_AXI_AWVALID),
           .M_AXI_AWREADY(M_AXI_AWREADY),
           .M_AXI_WDATA(M_AXI_WDATA),
           .M_AXI_WSTRB(M_AXI_WSTRB),
           .M_AXI_WLAST(M_AXI_WLAST),
           .M_AXI_WUSER(M_AXI_WUSER),
           .M_AXI_WVALID(M_AXI_WVALID),
           .M_AXI_WREADY(M_AXI_WREADY),
           .M_AXI_BID(M_AXI_BID),
           .M_AXI_BRESP(M_AXI_BRESP),
           .M_AXI_BUSER(M_AXI_BUSER),
           .M_AXI_BVALID(M_AXI_BVALID),
           .M_AXI_BREADY(M_AXI_BREADY),
           .M_AXI_ARID(M_AXI_ARID),
           .M_AXI_ARADDR(M_AXI_ARADDR),
           .M_AXI_ARLEN(M_AXI_ARLEN),
           .M_AXI_ARSIZE(M_AXI_ARSIZE),
           .M_AXI_ARBURST(M_AXI_ARBURST),
           .M_AXI_ARLOCK(M_AXI_ARLOCK),
           .M_AXI_ARCACHE(M_AXI_ARCACHE),
           .M_AXI_ARPROT(M_AXI_ARPROT),
           .M_AXI_ARQOS(M_AXI_ARQOS),
           .M_AXI_ARUSER(M_AXI_ARUSER),
           .M_AXI_ARVALID(M_AXI_ARVALID),
           .M_AXI_ARREADY(M_AXI_ARREADY),
           .M_AXI_RID(M_AXI_RID),
           .M_AXI_RDATA(M_AXI_RDATA),
           .M_AXI_RRESP(M_AXI_RRESP),
           .M_AXI_RLAST(M_AXI_RLAST),
           .M_AXI_RUSER(M_AXI_RUSER),
           .M_AXI_RVALID(M_AXI_RVALID),
           .M_AXI_RREADY(M_AXI_RREADY),

           .S_AXI_ACLK(ACLK),
           .S_AXI_ARESETN(ARESETN),
           .S_AXI_AWID(M_AXI_MERGE_AWID),
           .S_AXI_AWADDR(M_AXI_MERGE_AWADDR),
           .S_AXI_AWLEN(M_AXI_MERGE_AWLEN),
           .S_AXI_AWSIZE(M_AXI_MERGE_AWSIZE),
           .S_AXI_AWBURST(M_AXI_MERGE_AWBURST),
           .S_AXI_AWLOCK(M_AXI_MERGE_AWLOCK),
           .S_AXI_AWCACHE(M_AXI_MERGE_AWCACHE),
           .S_AXI_AWPROT(M_AXI_MERGE_AWPROT),
           .S_AXI_AWQOS(M_AXI_MERGE_AWQOS),
           .S_AXI_AWUSER(M_AXI_MERGE_AWUSER),
           .S_AXI_AWVALID(M_AXI_MERGE_AWVALID),
           .S_AXI_AWREADY(M_AXI_MERGE_AWREADY),
           .S_AXI_WDATA(M_AXI_MERGE_WDATA),
           .S_AXI_WSTRB(M_AXI_MERGE_WSTRB),
           .S_AXI_WLAST(M_AXI_MERGE_WLAST),
           .S_AXI_WUSER(M_AXI_MERGE_WUSER),
           .S_AXI_WVALID(M_AXI_MERGE_WVALID),
           .S_AXI_WREADY(M_AXI_MERGE_WREADY),
           .S_AXI_BID(M_AXI_MERGE_BID),
           .S_AXI_BRESP(M_AXI_MERGE_BRESP),
           .S_AXI_BUSER(M_AXI_MERGE_BUSER),
           .S_AXI_BVALID(M_AXI_MERGE_BVALID),
           .S_AXI_BREADY(M_AXI_MERGE_BREADY),
           .S_AXI_ARID(M_AXI_MERGE_ARID),
           .S_AXI_ARADDR(M_AXI_MERGE_ARADDR),
           .S_AXI_ARLEN(M_AXI_MERGE_ARLEN),
           .S_AXI_ARSIZE(M_AXI_MERGE_ARSIZE),
           .S_AXI_ARBURST(M_AXI_MERGE_ARBURST),
           .S_AXI_ARLOCK(M_AXI_MERGE_ARLOCK),
           .S_AXI_ARCACHE(M_AXI_MERGE_ARCACHE),
           .S_AXI_ARPROT(M_AXI_MERGE_ARPROT),
           .S_AXI_ARQOS(M_AXI_MERGE_ARQOS),
           .S_AXI_ARUSER(M_AXI_MERGE_ARUSER),
           .S_AXI_ARVALID(M_AXI_MERGE_ARVALID),
           .S_AXI_ARREADY(M_AXI_MERGE_ARREADY),
           .S_AXI_RID(M_AXI_MERGE_RID),
           .S_AXI_RDATA(M_AXI_MERGE_RDATA),
           .S_AXI_RRESP(M_AXI_MERGE_RRESP),
           .S_AXI_RLAST(M_AXI_MERGE_RLAST),
           .S_AXI_RUSER(M_AXI_MERGE_RUSER),
           .S_AXI_RVALID(M_AXI_MERGE_RVALID),
           .S_AXI_RREADY(M_AXI_MERGE_RREADY)
           );
      end

    if (C_M_AXI_DATA_WIDTH == 32 && C_M_AXI_BURST_LEN == 256) begin
      assign M_AXI_AWID = M_AXI_MERGE_AWID;
      assign M_AXI_AWADDR = M_AXI_MERGE_AWADDR;
      assign M_AXI_AWLEN = M_AXI_MERGE_AWLEN;
      assign M_AXI_AWSIZE = M_AXI_MERGE_AWSIZE;
      assign M_AXI_AWBURST = M_AXI_MERGE_AWBURST;
      assign M_AXI_AWLOCK = M_AXI_MERGE_AWLOCK;
      assign M_AXI_AWCACHE = M_AXI_MERGE_AWCACHE;
      assign M_AXI_AWPROT = M_AXI_MERGE_AWPROT;
      assign M_AXI_AWQOS = M_AXI_MERGE_AWQOS;
      assign M_AXI_AWUSER = M_AXI_MERGE_AWUSER;
      assign M_AXI_AWVALID = M_AXI_MERGE_AWVALID;
      assign M_AXI_AWREADY = M_AXI_MERGE_AWREADY;
      assign M_AXI_WDATA = M_AXI_MERGE_WDATA;
      assign M_AXI_WSTRB = M_AXI_MERGE_WSTRB;
      assign M_AXI_WLAST = M_AXI_MERGE_WLAST;
      assign M_AXI_WUSER = M_AXI_MERGE_WUSER;
      assign M_AXI_WVALID = M_AXI_MERGE_WVALID;
      assign M_AXI_WREADY = M_AXI_MERGE_WREADY;
      assign M_AXI_BID = M_AXI_MERGE_BID;
      assign M_AXI_BRESP = M_AXI_MERGE_BRESP;
      assign M_AXI_BUSER = M_AXI_MERGE_BUSER;
      assign M_AXI_BVALID = M_AXI_MERGE_BVALID;
      assign M_AXI_BREADY = M_AXI_MERGE_BREADY;
      assign M_AXI_ARID = M_AXI_MERGE_ARID;
      assign M_AXI_ARADDR = M_AXI_MERGE_ARADDR;
      assign M_AXI_ARLEN = M_AXI_MERGE_ARLEN;
      assign M_AXI_ARSIZE = M_AXI_MERGE_ARSIZE;
      assign M_AXI_ARBURST = M_AXI_MERGE_ARBURST;
      assign M_AXI_ARLOCK = M_AXI_MERGE_ARLOCK;
      assign M_AXI_ARCACHE = M_AXI_MERGE_ARCACHE;
      assign M_AXI_ARPROT = M_AXI_MERGE_ARPROT;
      assign M_AXI_ARQOS = M_AXI_MERGE_ARQOS;
      assign M_AXI_ARUSER = M_AXI_MERGE_ARUSER;
      assign M_AXI_ARVALID = M_AXI_MERGE_ARVALID;
      assign M_AXI_ARREADY = M_AXI_MERGE_ARREADY;
      assign M_AXI_RID = M_AXI_MERGE_RID;
      assign M_AXI_RDATA = M_AXI_MERGE_RDATA;
      assign M_AXI_RRESP = M_AXI_MERGE_RRESP;
      assign M_AXI_RLAST = M_AXI_MERGE_RLAST;
      assign M_AXI_RUSER = M_AXI_MERGE_RUSER;
      assign M_AXI_RVALID = M_AXI_MERGE_RVALID;
      assign M_AXI_RREADY = M_AXI_MERGE_RREADY;
    end

  endgenerate



endmodule
