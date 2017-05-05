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
`timescale 1ns / 1ps

// bram oldugu icin out 1 clock sonra gelir
module fifo_v2 #
  (
   parameter integer C_DATA_WIDTH = 64,
   parameter integer C_DATA_2_WIDTH = 1,
   // C_FIFO_ADDR_SIZE >= 2
   parameter integer C_FIFO_ADDR_SIZE = 9
   )
  (
   input                                clk,
   input                                resetn,
   output                               in_ready,
   input                                in_valid,
   input [C_DATA_WIDTH-1:0]             in_data,
   input [C_DATA_2_WIDTH-1:0]           in_data_2,
   output [C_FIFO_ADDR_SIZE-1:0]        in_addr,
   input                                out_ready,
   output reg                           out_valid,
   output [C_DATA_WIDTH-1:0]            out_data,
   output [C_DATA_2_WIDTH-1:0]          out_data_2,
   output [C_FIFO_ADDR_SIZE-1:0]        out_addr,
   output wire [C_FIFO_ADDR_SIZE*2-1:0] debug
   );

  localparam RAM_DATA_WIDTH = C_DATA_WIDTH + C_DATA_2_WIDTH;

  parameter [1:0] STATE_EMPTY = 2'b00, STATE_FULL = 2'b01, STATE_NORMAL = 2'b10;

  // in_1 == in-1, out_1 == out-1
  reg [C_FIFO_ADDR_SIZE-1:0]            in, in_1;
  reg [C_FIFO_ADDR_SIZE-1:0]            out, out_next;
  reg [1:0]                             state;

  assign in_addr = in;
  assign out_addr = out;

  assign debug = { out[C_FIFO_ADDR_SIZE-1:0], in[C_FIFO_ADDR_SIZE-1:0] };

  reg                                   fifo_mem_wen;

  wire                                  dualport_ram_wea;
  wire                                  dualport_ram_reb;
  assign dualport_ram_wea = fifo_mem_wen && in_valid;
  assign dualport_ram_reb = (state != STATE_EMPTY) & out_ready;

  wire [RAM_DATA_WIDTH-1:0]             ram_dia;
  assign ram_dia = {in_data_2, in_data};
  wire [RAM_DATA_WIDTH-1:0]             ram_dob;

  dualport_ram #
    (
     .C_DATA_WIDTH(RAM_DATA_WIDTH)
     )
  dualport_ram_i
    (
     .clk(clk),
     .wea(dualport_ram_wea),
     .reb(dualport_ram_reb),
     .addra(in),
     .addrb(out_next),
     .dia(ram_dia),
     .dob(ram_dob)
     );


  assign out_data_2 = ram_dob[RAM_DATA_WIDTH-1:C_DATA_WIDTH];
  assign out_data = ram_dob[C_DATA_WIDTH-1:0];
  assign in_ready = (state != STATE_FULL);

  always @(posedge clk) begin
    if (resetn == 0) begin
      out_valid <= 0;
    end else begin
      out_valid <= (state != STATE_EMPTY);
    end
  end

  always @(posedge clk) begin
    if (resetn == 0) begin
      in <= 0;
      in_1 <= -1;
      out <= -1;
      out_next <= 0;
      fifo_mem_wen <= 1;
      state <= STATE_EMPTY;
    end else begin
      case (state)
        STATE_EMPTY: begin
          if (in_valid) begin
            in_1 <= in;
            in <= in + 1;

            // $display("[fifo_v2] in_data : %x %x", in_data_2, in_data);
            state <= STATE_NORMAL;
          end
        end
        STATE_NORMAL: begin
          if (out_ready) begin
            // out <= out + 1;
            out <= out_next;
            out_next <= out_next + 1;
          end
          if (in_valid) begin
            in_1 <= in;
            in <= in + 1;
            // $display("[fifo_v2] in_data : %x %x", in_data_2, in_data);
          end

          if (~out_ready && in_valid && in == out) begin
            // fifo dolmak uzere ve sadece yazma yapliyor
            fifo_mem_wen <= 0;
            state <= STATE_FULL;
          end else if (out_ready && ~in_valid && out_next == in_1) begin
            // fifo bosalmak uzere ve sadece okuma yapliyor
            // $display("[fifo_v2] state <= STATE_EMPTY");
            state <= STATE_EMPTY;
          end
        end
        STATE_FULL: begin
          if (out_ready) begin
            // out <= out + 1;
            out <= out_next;
            out_next <= out_next + 1;

            fifo_mem_wen <= 1;
            state <= STATE_NORMAL;
          end
        end
      endcase
    end

  end

endmodule
