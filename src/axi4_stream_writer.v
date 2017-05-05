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

module axi_stream_writer #
  (
   parameter integer C_M_AXIS_TDATA_WIDTH = 32
  )
  (
   input wire 									start, // FIXME: sil
   input wire [C_M_AXIS_TDATA_WIDTH-1:0] 		data,
   input wire 									data_valid,
   input wire 									data_last,
   output wire 									ready,
   /* axi4-stream ports */
   input wire 									M_AXIS_ACLK,
   input wire 									M_AXIS_ARESETN,
   output wire 									M_AXIS_TVALID,
   output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] 	M_AXIS_TDATA,
   output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
   output wire 									M_AXIS_TLAST,
   input wire 									M_AXIS_TREADY
   );


  /* I/O connections */
  assign M_AXIS_TVALID	= data_valid;
  assign M_AXIS_TDATA	= data;
  assign M_AXIS_TLAST	= data_last;
  assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};

  assign ready = M_AXIS_TREADY;

endmodule
