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
`timescale 1 ns / 1 ps

module axi4_full_to_stream #
  (
   parameter integer C_AXI_DATA_WIDTH = 32,
   /* AXI_MM */
   parameter C_M_TARGET_SLAVE_BASE_ADDR = 32'h00000000,
   // Burst Length. Supports 4, 8, 16, 32, 64, 128, 256 burst lengths
   parameter integer C_M_AXI_BURST_LEN = 256,
   parameter integer C_M_AXI_ID_WIDTH = 1,
   parameter integer C_M_AXI_ADDR_WIDTH = 32,
   parameter integer C_M_AXI_AWUSER_WIDTH = 0,
   parameter integer C_M_AXI_ARUSER_WIDTH = 0,
   parameter integer C_M_AXI_WUSER_WIDTH = 0,
   parameter integer C_M_AXI_RUSER_WIDTH = 0,
   parameter integer C_M_AXI_BUSER_WIDTH = 0
   )
  (
   input wire 								ACLK,
   input wire 								ARESETN,
   input wire 								sw_reset,
   output reg 								sw_reset_ok,
   /* control ports */
   input wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	read_address,
   input wire 								start_read,
   output wire 								output_idle,
   /* axi4-stream ports */
   input wire 								M_AXIS_TREADY,
   output wire [C_AXI_DATA_WIDTH-1 : 0] 	M_AXIS_TDATA,
   output wire [(C_AXI_DATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
   output wire 								M_AXIS_TLAST,
   output wire 								M_AXIS_TVALID,
   /* axi4-mm ports */
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
   output wire [C_AXI_DATA_WIDTH-1 : 0] 	M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1 : 0] 	M_AXI_WSTRB,
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
   input wire [C_AXI_DATA_WIDTH-1 : 0] 		M_AXI_RDATA,
   input wire [1 : 0] 						M_AXI_RRESP,
   input wire 								M_AXI_RLAST,
   input wire [C_M_AXI_RUSER_WIDTH-1 : 0] 	M_AXI_RUSER,
   input wire 								M_AXI_RVALID,
   output wire 								M_AXI_RREADY
   );

  function integer clogb2 (input integer bit_depth);
	begin
	  for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	    bit_depth = bit_depth >> 1;
	end
  endfunction



  /* axi_stream_writer signals */
  reg 								   stream_writer_enabled = 0;
  wire [C_AXI_DATA_WIDTH-1:0]		   stream_writer_data;
  wire 								   stream_writer_data_valid;
  wire 								   stream_writer_data_last;
  wire 								   stream_writer_ready;

  axi_stream_writer #
	(
	 .C_M_AXIS_TDATA_WIDTH(32)
	 )
  axi_stream_writer_i
	(
	 .M_AXIS_ACLK(ACLK),
	 .M_AXIS_ARESETN(ARESETN),
	 /* */
	 .start(stream_writer_enabled),
	 .data(stream_writer_data),
	 .data_valid(stream_writer_data_valid),
	 .data_last(stream_writer_data_last),
	 .ready(stream_writer_ready),
	 /* */
	 .M_AXIS_TVALID(M_AXIS_TVALID),
	 .M_AXIS_TDATA(M_AXIS_TDATA),
	 .M_AXIS_TSTRB(M_AXIS_TSTRB),
	 .M_AXIS_TLAST(M_AXIS_TLAST),
	 .M_AXIS_TREADY(M_AXIS_TREADY)
	 );


  /* axi4_full_master_rw signals */

  reg [C_M_AXI_ADDR_WIDTH-1:0] 				axi_mm_write_address = 0;
  reg [C_AXI_DATA_WIDTH-1:0] 				axi_mm_write_data = 0;
  reg 										axi_mm_write_data_valid = 0;
  reg 										axi_mm_write_start = 0;
  wire 										axi_mm_write_ready;
  wire 										axi_mm_write_end;

  reg [C_M_AXI_ADDR_WIDTH-1:0] 				axi_mm_read_address = 0;
  reg 										axi_mm_read_start = 0;
  wire [C_AXI_DATA_WIDTH-1:0] 				axi_mm_read_data;
  wire 										axi_mm_read_data_valid;
  wire 										axi_mm_read_data_last;
  wire 										axi_mm_read_ready;
  wire 										axi_mm_read_end;

  wire 										axi_mm_output_idle;
  wire 										axi_mm_output_error;

  axi4_full_master_rw #
	(
	 .C_M_TARGET_SLAVE_BASE_ADDR(C_M_TARGET_SLAVE_BASE_ADDR),
	 .C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
	 .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
	 .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
	 .C_M_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
	 .C_M_AXI_AWUSER_WIDTH(C_M_AXI_AWUSER_WIDTH),
	 .C_M_AXI_ARUSER_WIDTH(C_M_AXI_ARUSER_WIDTH),
	 .C_M_AXI_WUSER_WIDTH(C_M_AXI_WUSER_WIDTH),
	 .C_M_AXI_RUSER_WIDTH(C_M_AXI_RUSER_WIDTH),
	 .C_M_AXI_BUSER_WIDTH(C_M_AXI_BUSER_WIDTH)
	 )
  axi_mm_i
	(
	 .write_address(axi_mm_write_address),
	 .write_data(axi_mm_write_data),
	 .write_data_valid(axi_mm_write_data_valid),
	 .write_data_last(), // FIXME: --
	 .write_start(axi_mm_write_start),
	 .write_ready(axi_mm_write_ready),
	 .write_end(axi_mm_write_end),

	 .read_address(axi_mm_read_address),
	 .read_start(axi_mm_read_start),
	 .read_data(axi_mm_read_data),
	 .read_data_valid(axi_mm_read_data_valid),
	 .read_data_last(axi_mm_read_data_last), // FIXME: --
	 .read_ready(axi_mm_read_ready),
	 .read_end(axi_mm_read_end),

	 .output_idle(axi_mm_output_idle),
	 .output_error(axi_mm_output_error),
	 /* */
	 .M_AXI_ACLK(ACLK),
	 .M_AXI_ARESETN(ARESETN),
	 /* */
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
	 .M_AXI_RREADY(M_AXI_RREADY)
	 );

  reg [3:0] state;

  assign stream_writer_data = axi_mm_read_data;
  assign stream_writer_data_valid = !sw_reset && axi_mm_read_data_valid && (state == 1);
  assign axi_mm_read_ready = stream_writer_ready || sw_reset;
  assign stream_writer_data_last = axi_mm_read_data_last;

  assign output_idle = (state == 0);
  always @(posedge ACLK) begin
    // $display("axi_stream_writer_ready: %x", axi_stream_writer_ready);
	if (ARESETN == 0) begin
	  state <= 0;
	  state <= sw_reset;
	  sw_reset_ok <= 0;
	end else if (sw_reset) begin
	  // axi-mm'e read_ready veriyoruz
	  // stream_writer_data_valid = 0
	  if (axi_mm_output_idle) begin
		sw_reset_ok <= 1;
	  end
	end else begin
	  sw_reset_ok <= 0;

	  case (state)
		0: begin // idle
		  if (start_read) begin
			axi_mm_read_address <= read_address;
			axi_mm_read_start <= 1;

			stream_writer_enabled <= 1;
			state <= 1;
			$display("axi4_mm2s state <= 1");
		  end
		end
		1: begin // write
		  axi_mm_read_start <= 0;

		  if (axi_mm_read_end) begin
			stream_writer_enabled <= 0;
			state <= 2;
			$display("axi4_mm2s state <= 2");
		  end

		  // $display("stream_writer_ready : %x", stream_writer_ready);

		end
		2: begin // end
		  state <= 0;
		  $display("axi4_mm2s state <= 0");
        end
 	  endcase
	end
  end


endmodule
