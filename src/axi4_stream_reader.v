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

module axi4_stream_reader #
  (
   parameter integer C_S_AXIS_TDATA_WIDTH = 32
   )
  (
   /* axi4-stream ports */
   input wire 								   S_AXIS_ACLK,
   input wire 								   S_AXIS_ARESETN,
   output wire 								   S_AXIS_TREADY,
   input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] 	   S_AXIS_TDATA,
   input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
   input wire 								   S_AXIS_TLAST,
   input wire 								   S_AXIS_TVALID,
   /* control signals */
   input wire 								   ready,
   output wire 								   data_valid,
   output wire [C_S_AXIS_TDATA_WIDTH-1:0] 	   data
   // FIXME: data_last
   );

  /* io connections */
  assign S_AXIS_TREADY = ready;
  assign data_valid = S_AXIS_TVALID;
  assign data = S_AXIS_TDATA;

endmodule
