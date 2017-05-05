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
module dualport_ram  #
  (
   parameter integer C_DATA_WIDTH = 64,
   parameter integer C_ADDR_SIZE = 9
   )
  (
   input 						 clk,
   input 						 wea,
   input 						 reb,
   input [C_ADDR_SIZE-1:0] 		 addra,
   input [C_ADDR_SIZE-1:0] 		 addrb,
   input [C_DATA_WIDTH-1:0] 	 dia,
   output reg [C_DATA_WIDTH-1:0] dob
   );

  localparam C_COUNT = (1<<C_ADDR_SIZE);

  reg [C_DATA_WIDTH-1:0] 	 ram [C_COUNT-1:0] /* synthesis syn_ramstyle = "block_ram" syn_ramstyle = "no_rw_check" */;

  always @ (posedge clk) begin
    if (wea)
      ram[addra] <= dia;
	if (reb) begin
      dob <= ram[addrb];
	  // $display("ram out: %d %x", addrb, ram[addrb]);
	end
  end

endmodule  // dualport_ram
