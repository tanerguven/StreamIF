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
module axi4_read_write_merge #
  (
   parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h00000000,
   // Burst Length. Supports 4, 8, 16, 32, 64, 128, 256 burst lengths
   parameter integer C_M_AXI_BURST_LEN	= 4,
   parameter integer C_M_AXI_ID_WIDTH	= 1,
   parameter integer C_M_AXI_ADDR_WIDTH	= 32,
   parameter integer C_M_AXI_DATA_WIDTH	= 32,
   parameter integer C_M_AXI_AWUSER_WIDTH	= 1,
   parameter integer C_M_AXI_ARUSER_WIDTH	= 1,
   parameter integer C_M_AXI_WUSER_WIDTH	= 1,
   parameter integer C_M_AXI_RUSER_WIDTH	= 1,
   parameter integer C_M_AXI_BUSER_WIDTH	= 1
   )
  (

   // output wire 								S_AXI_READ_ACLK,
   // output wire 								S_AXI_READ_ARESETN,
   input wire [C_M_AXI_ID_WIDTH-1 : 0] 		S_AXI_READ_AWID,
   input wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	S_AXI_READ_AWADDR,
   input wire [7 : 0] 						S_AXI_READ_AWLEN,
   input wire [2 : 0] 						S_AXI_READ_AWSIZE,
   input wire [1 : 0] 						S_AXI_READ_AWBURST,
   input wire 								S_AXI_READ_AWLOCK,
   input wire [3 : 0] 						S_AXI_READ_AWCACHE,
   input wire [2 : 0] 						S_AXI_READ_AWPROT,
   input wire [3 : 0] 						S_AXI_READ_AWQOS,
   input wire [C_M_AXI_AWUSER_WIDTH-1 : 0] 	S_AXI_READ_AWUSER,
   input wire 								S_AXI_READ_AWVALID,
   output wire 								S_AXI_READ_AWREADY,
   input wire [C_M_AXI_DATA_WIDTH-1 : 0] 	S_AXI_READ_WDATA,
   input wire [C_M_AXI_DATA_WIDTH/8-1 : 0] 	S_AXI_READ_WSTRB,
   input wire 								S_AXI_READ_WLAST,
   input wire [C_M_AXI_WUSER_WIDTH-1 : 0] 	S_AXI_READ_WUSER,
   input wire 								S_AXI_READ_WVALID,
   output wire 								S_AXI_READ_WREADY,
   output wire [C_M_AXI_ID_WIDTH-1 : 0] 	S_AXI_READ_BID,
   output wire [1 : 0] 						S_AXI_READ_BRESP,
   output wire [C_M_AXI_BUSER_WIDTH-1 : 0] 	S_AXI_READ_BUSER,
   output wire 								S_AXI_READ_BVALID,
   input wire 								S_AXI_READ_BREADY,
   input wire [C_M_AXI_ID_WIDTH-1 : 0] 		S_AXI_READ_ARID,
   input wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	S_AXI_READ_ARADDR,
   input wire [7 : 0] 						S_AXI_READ_ARLEN,
   input wire [2 : 0] 						S_AXI_READ_ARSIZE,
   input wire [1 : 0] 						S_AXI_READ_ARBURST,
   input wire 								S_AXI_READ_ARLOCK,
   input wire [3 : 0] 						S_AXI_READ_ARCACHE,
   input wire [2 : 0] 						S_AXI_READ_ARPROT,
   input wire [3 : 0] 						S_AXI_READ_ARQOS,
   input wire [C_M_AXI_ARUSER_WIDTH-1 : 0] 	S_AXI_READ_ARUSER,
   input wire 								S_AXI_READ_ARVALID,
   output wire 								S_AXI_READ_ARREADY,
   output wire [C_M_AXI_ID_WIDTH-1 : 0] 	S_AXI_READ_RID,
   output wire [C_M_AXI_DATA_WIDTH-1 : 0] 	S_AXI_READ_RDATA,
   output wire [1 : 0] 						S_AXI_READ_RRESP,
   output wire 								S_AXI_READ_RLAST,
   output wire [C_M_AXI_RUSER_WIDTH-1 : 0] 	S_AXI_READ_RUSER,
   output wire 								S_AXI_READ_RVALID,
   input wire 								S_AXI_READ_RREADY,

   /* */
   // output wire 								S_AXI_WRITE_ACLK,
   // output wire 								S_AXI_WRITE_ARESETN,
   input wire [C_M_AXI_ID_WIDTH-1 : 0] 		S_AXI_WRITE_AWID,
   input wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	S_AXI_WRITE_AWADDR,
   input wire [7 : 0] 						S_AXI_WRITE_AWLEN,
   input wire [2 : 0] 						S_AXI_WRITE_AWSIZE,
   input wire [1 : 0] 						S_AXI_WRITE_AWBURST,
   input wire 								S_AXI_WRITE_AWLOCK,
   input wire [3 : 0] 						S_AXI_WRITE_AWCACHE,
   input wire [2 : 0] 						S_AXI_WRITE_AWPROT,
   input wire [3 : 0] 						S_AXI_WRITE_AWQOS,
   input wire [C_M_AXI_AWUSER_WIDTH-1 : 0] 	S_AXI_WRITE_AWUSER,
   input wire 								S_AXI_WRITE_AWVALID,
   output wire 								S_AXI_WRITE_AWREADY,
   input wire [C_M_AXI_DATA_WIDTH-1 : 0] 	S_AXI_WRITE_WDATA,
   input wire [C_M_AXI_DATA_WIDTH/8-1 : 0] 	S_AXI_WRITE_WSTRB,
   input wire 								S_AXI_WRITE_WLAST,
   input wire [C_M_AXI_WUSER_WIDTH-1 : 0] 	S_AXI_WRITE_WUSER,
   input wire 								S_AXI_WRITE_WVALID,
   output wire 								S_AXI_WRITE_WREADY,
   output wire [C_M_AXI_ID_WIDTH-1 : 0] 	S_AXI_WRITE_BID,
   output wire [1 : 0] 						S_AXI_WRITE_BRESP,
   output wire [C_M_AXI_BUSER_WIDTH-1 : 0] 	S_AXI_WRITE_BUSER,
   output wire 								S_AXI_WRITE_BVALID,
   input wire 								S_AXI_WRITE_BREADY,
   input wire [C_M_AXI_ID_WIDTH-1 : 0] 		S_AXI_WRITE_ARID,
   input wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	S_AXI_WRITE_ARADDR,
   input wire [7 : 0] 						S_AXI_WRITE_ARLEN,
   input wire [2 : 0] 						S_AXI_WRITE_ARSIZE,
   input wire [1 : 0] 						S_AXI_WRITE_ARBURST,
   input wire 								S_AXI_WRITE_ARLOCK,
   input wire [3 : 0] 						S_AXI_WRITE_ARCACHE,
   input wire [2 : 0] 						S_AXI_WRITE_ARPROT,
   input wire [3 : 0] 						S_AXI_WRITE_ARQOS,
   input wire [C_M_AXI_ARUSER_WIDTH-1 : 0] 	S_AXI_WRITE_ARUSER,
   input wire 								S_AXI_WRITE_ARVALID,
   output wire 								S_AXI_WRITE_ARREADY,
   output wire [C_M_AXI_ID_WIDTH-1 : 0] 	S_AXI_WRITE_RID,
   output wire [C_M_AXI_DATA_WIDTH-1 : 0] 	S_AXI_WRITE_RDATA,
   output wire [1 : 0] 						S_AXI_WRITE_RRESP,
   output wire 								S_AXI_WRITE_RLAST,
   output wire [C_M_AXI_RUSER_WIDTH-1 : 0] 	S_AXI_WRITE_RUSER,
   output wire 								S_AXI_WRITE_RVALID,
   input wire 								S_AXI_WRITE_RREADY,

   /* */
   input wire 								M_AXI_ACLK,
   input wire 								M_AXI_ARESETN,
   output wire [C_M_AXI_ID_WIDTH-1 : 0] 	M_AXI_AWID,
   output wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	M_AXI_AWADDR,
   output wire [7 : 0] 						M_AXI_AWLEN,
   output wire [2 : 0] 						M_AXI_AWSIZE,
   output wire [1 : 0] 						M_AXI_AWBURST,
   output wire 								M_AXI_AWLOCK,
   output wire [3 : 0] 						M_AXI_AWCACHE,
   output wire [2 : 0] 						M_AXI_AWPROT,
   output wire [3 : 0] 						M_AXI_AWQOS,
   output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
   output wire 								M_AXI_AWVALID,
   input wire 								M_AXI_AWREADY,
   output wire [C_M_AXI_DATA_WIDTH-1 : 0] 	M_AXI_WDATA,
   output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
   output wire 								M_AXI_WLAST,
   output wire [C_M_AXI_WUSER_WIDTH-1 : 0] 	M_AXI_WUSER,
   output wire 								M_AXI_WVALID,
   input wire 								M_AXI_WREADY,
   input wire [C_M_AXI_ID_WIDTH-1 : 0] 		M_AXI_BID,
   input wire [1 : 0] 						M_AXI_BRESP,
   input wire [C_M_AXI_BUSER_WIDTH-1 : 0] 	M_AXI_BUSER,
   input wire 								M_AXI_BVALID,
   output wire 								M_AXI_BREADY,
   output wire [C_M_AXI_ID_WIDTH-1 : 0] 	M_AXI_ARID,
   output wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	M_AXI_ARADDR,
   output wire [7 : 0] 						M_AXI_ARLEN,
   output wire [2 : 0] 						M_AXI_ARSIZE,
   output wire [1 : 0] 						M_AXI_ARBURST,
   output wire 								M_AXI_ARLOCK,
   output wire [3 : 0] 						M_AXI_ARCACHE,
   output wire [2 : 0] 						M_AXI_ARPROT,
   output wire [3 : 0] 						M_AXI_ARQOS,
   output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
   output wire 								M_AXI_ARVALID,
   input wire 								M_AXI_ARREADY,
   input wire [C_M_AXI_ID_WIDTH-1 : 0] 		M_AXI_RID,
   input wire [C_M_AXI_DATA_WIDTH-1 : 0] 	M_AXI_RDATA,
   input wire [1 : 0] 						M_AXI_RRESP,
   input wire 								M_AXI_RLAST,
   input wire [C_M_AXI_RUSER_WIDTH-1 : 0] 	M_AXI_RUSER,
   input wire 								M_AXI_RVALID,
   output wire 								M_AXI_RREADY
   );

  // assign S_AXI_READ_ACLK = M_AXI_ACLK;
  // assign S_AXI_READ_ARESETN = M_AXI_ARESETN;

  // assign S_AXI_WRITE_ACLK = M_AXI_ACLK;
  // assign S_AXI_WRITE_ARESETN = M_AXI_ARESETN;

  // S_AXI_WRITE write channel
  assign M_AXI_AWID = S_AXI_WRITE_AWID;
  assign M_AXI_AWADDR = S_AXI_WRITE_AWADDR;
  assign M_AXI_AWLEN = S_AXI_WRITE_AWLEN;
  assign M_AXI_AWSIZE = S_AXI_WRITE_AWSIZE;
  assign M_AXI_AWBURST = S_AXI_WRITE_AWBURST;
  assign M_AXI_AWLOCK = S_AXI_WRITE_AWLOCK;
  assign M_AXI_AWCACHE = S_AXI_WRITE_AWCACHE;
  assign M_AXI_AWPROT = S_AXI_WRITE_AWPROT;
  assign M_AXI_AWQOS = S_AXI_WRITE_AWQOS;
  assign M_AXI_AWUSER = S_AXI_WRITE_AWUSER;
  assign M_AXI_AWVALID = S_AXI_WRITE_AWVALID;
  assign S_AXI_WRITE_AWREADY = M_AXI_AWREADY;
  assign M_AXI_WDATA = S_AXI_WRITE_WDATA;
  assign M_AXI_WSTRB = S_AXI_WRITE_WSTRB;
  assign M_AXI_WLAST = S_AXI_WRITE_WLAST;
  assign M_AXI_WUSER = S_AXI_WRITE_WUSER;
  assign M_AXI_WVALID = S_AXI_WRITE_WVALID;
  assign S_AXI_WRITE_WREADY = M_AXI_WREADY;
  assign S_AXI_WRITE_BID = M_AXI_BID;
  assign S_AXI_WRITE_BRESP = M_AXI_BRESP;
  assign S_AXI_WRITE_BUSER = M_AXI_BUSER;
  assign S_AXI_WRITE_BVALID = M_AXI_BVALID;
  assign M_AXI_BREADY = S_AXI_WRITE_BREADY;

  // S_AXI_WRITE read channel
  assign S_AXI_WRITE_ARREADY = 0;
  assign S_AXI_WRITE_RID = 0;
  assign S_AXI_WRITE_RDATA = 0;
  assign S_AXI_WRITE_RRESP = 0;
  assign S_AXI_WRITE_RLAST = 0;
  assign S_AXI_WRITE_RUSER = 0;
  assign S_AXI_WRITE_RVALID = 0;

  // S_AXI_READ write channel
  assign S_AXI_READ_AWREADY = 0;
  assign S_AXI_READ_WREADY = 0;
  assign S_AXI_READ_BID = 0;
  assign S_AXI_READ_BRESP = 0;
  assign S_AXI_READ_BUSER = 0;
  assign S_AXI_READ_BVALID = 0;

  // S_AXI_READ read channel
  assign M_AXI_ARID = S_AXI_READ_ARID;
  assign M_AXI_ARADDR = S_AXI_READ_ARADDR;
  assign M_AXI_ARLEN = S_AXI_READ_ARLEN;
  assign M_AXI_ARSIZE = S_AXI_READ_ARSIZE;
  assign M_AXI_ARBURST = S_AXI_READ_ARBURST;
  assign M_AXI_ARLOCK = S_AXI_READ_ARLOCK;
  assign M_AXI_ARCACHE = S_AXI_READ_ARCACHE;
  assign M_AXI_ARPROT = S_AXI_READ_ARPROT;
  assign M_AXI_ARQOS = S_AXI_READ_ARQOS;
  assign M_AXI_ARUSER = S_AXI_READ_ARUSER;
  assign M_AXI_ARVALID = S_AXI_READ_ARVALID;
  assign S_AXI_READ_ARREADY = M_AXI_ARREADY;
  assign S_AXI_READ_RID = M_AXI_RID;
  assign S_AXI_READ_RDATA = M_AXI_RDATA;
  assign S_AXI_READ_RRESP = M_AXI_RRESP;
  assign S_AXI_READ_RLAST = M_AXI_RLAST;
  assign S_AXI_READ_RUSER = M_AXI_RUSER;
  assign S_AXI_READ_RVALID = M_AXI_RVALID;
  assign M_AXI_RREADY = S_AXI_READ_RREADY;



endmodule
