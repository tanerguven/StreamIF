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

module axi4_32bit_to_64bit #
  (
   parameter integer C_M_AXI_BURST_LEN = 128,
   parameter integer C_M_AXI_ID_WIDTH = 1,
   parameter integer C_M_AXI_ADDR_WIDTH = 32,
   parameter integer C_M_AXI_AWUSER_WIDTH = 0,
   parameter integer C_M_AXI_ARUSER_WIDTH = 0,
   parameter integer C_M_AXI_WUSER_WIDTH = 0,
   parameter integer C_M_AXI_RUSER_WIDTH = 0,
   parameter integer C_M_AXI_BUSER_WIDTH = 0,

   parameter integer C_S_AXI_BURST_LEN = 256,
   parameter integer C_S_AXI_ID_WIDTH = 1,
   parameter integer C_S_AXI_ADDR_WIDTH = 32,
   parameter integer C_S_AXI_AWUSER_WIDTH = 0,
   parameter integer C_S_AXI_ARUSER_WIDTH = 0,
   parameter integer C_S_AXI_WUSER_WIDTH = 0,
   parameter integer C_S_AXI_RUSER_WIDTH = 0,
   parameter integer C_S_AXI_BUSER_WIDTH = 0,

   parameter integer LOG_ENABLED = 0

   )
  (
   output wire [31:0]                       debug_read,
   output wire [31:0]                       debug_write,

   input wire                               S_AXI_ACLK,
   input wire                               S_AXI_ARESETN,
   input wire [C_S_AXI_ID_WIDTH-1 : 0]      S_AXI_AWID,
   input wire [C_S_AXI_ADDR_WIDTH-1 : 0]    S_AXI_AWADDR,
   input wire [7 : 0]                       S_AXI_AWLEN,
   input wire [2 : 0]                       S_AXI_AWSIZE,
   input wire [1 : 0]                       S_AXI_AWBURST,
   input wire                               S_AXI_AWLOCK,
   input wire [3 : 0]                       S_AXI_AWCACHE,
   input wire [2 : 0]                       S_AXI_AWPROT,
   input wire [3 : 0]                       S_AXI_AWQOS,
   input wire [3 : 0]                       S_AXI_AWREGION,
   input wire [C_S_AXI_AWUSER_WIDTH-1 : 0]  S_AXI_AWUSER,
   input wire                               S_AXI_AWVALID,
   output wire                              S_AXI_AWREADY,
   input wire [32-1 : 0]                    S_AXI_WDATA,
   input wire [(32/8)-1 : 0]                S_AXI_WSTRB,
   input wire                               S_AXI_WLAST,
   input wire [C_S_AXI_WUSER_WIDTH-1 : 0]   S_AXI_WUSER,
   input wire                               S_AXI_WVALID,
   output wire                              S_AXI_WREADY,
   output wire [C_S_AXI_ID_WIDTH-1 : 0]     S_AXI_BID,
   output wire [1 : 0]                      S_AXI_BRESP,
   output wire [C_S_AXI_BUSER_WIDTH-1 : 0]  S_AXI_BUSER,
   output wire                              S_AXI_BVALID,
   input wire                               S_AXI_BREADY,
   input wire [C_S_AXI_ID_WIDTH-1 : 0]      S_AXI_ARID,
   input wire [C_S_AXI_ADDR_WIDTH-1 : 0]    S_AXI_ARADDR,
   input wire [7 : 0]                       S_AXI_ARLEN,
   input wire [2 : 0]                       S_AXI_ARSIZE,
   input wire [1 : 0]                       S_AXI_ARBURST,
   input wire                               S_AXI_ARLOCK,
   input wire [3 : 0]                       S_AXI_ARCACHE,
   input wire [2 : 0]                       S_AXI_ARPROT,
   input wire [3 : 0]                       S_AXI_ARQOS,
   input wire [3 : 0]                       S_AXI_ARREGION,
   input wire [C_S_AXI_ARUSER_WIDTH-1 : 0]  S_AXI_ARUSER,
   input wire                               S_AXI_ARVALID,
   output wire                              S_AXI_ARREADY,
   output wire [C_S_AXI_ID_WIDTH-1 : 0]     S_AXI_RID,
   output wire [32-1 : 0]                   S_AXI_RDATA,
   output wire [1 : 0]                      S_AXI_RRESP,
   output wire                              S_AXI_RLAST,
   output wire [C_S_AXI_RUSER_WIDTH-1 : 0]  S_AXI_RUSER,
   output wire                              S_AXI_RVALID,
   input wire                               S_AXI_RREADY,

   /* */
   input wire                               M_AXI_ACLK,
   input wire                               M_AXI_ARESETN,
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
   output wire [64-1 : 0]                   M_AXI_WDATA,
   output wire [64/8-1 : 0]                 M_AXI_WSTRB,
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
   input wire [64-1 : 0]                    M_AXI_RDATA,
   input wire [1 : 0]                       M_AXI_RRESP,
   input wire                               M_AXI_RLAST,
   input wire [C_M_AXI_RUSER_WIDTH-1 : 0]   M_AXI_RUSER,
   input wire                               M_AXI_RVALID,
   output wire                              M_AXI_RREADY
   );

  function integer clogb2 (input integer bit_depth);
    begin
      for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
        bit_depth = bit_depth >> 1;
    end
  endfunction


  //
  assign M_AXI_AWID = S_AXI_AWID;
  assign M_AXI_AWADDR = S_AXI_AWADDR;
  // assign M_AXI_AWLEN = S_AXI_AWLEN;
  // assign M_AXI_AWSIZE = S_AXI_AWSIZE;
  assign M_AXI_AWBURST = S_AXI_AWBURST;
  assign M_AXI_AWLOCK = S_AXI_AWLOCK;
  assign M_AXI_AWCACHE = S_AXI_AWCACHE;
  assign M_AXI_AWPROT = S_AXI_AWPROT;
  assign M_AXI_AWQOS = S_AXI_AWQOS;
  assign M_AXI_AWUSER = S_AXI_AWUSER;
  assign M_AXI_AWVALID = S_AXI_AWVALID;
  // assign M_AXI_WDATA = S_AXI_WDATA;
  // assign M_AXI_WSTRB = S_AXI_WSTRB;
  assign M_AXI_WSTRB = {(64/8){1'b1}};
  // assign M_AXI_WLAST = S_AXI_WLAST;
  assign M_AXI_WUSER = S_AXI_WUSER;
  // assign M_AXI_WVALID = S_AXI_WVALID;
  assign M_AXI_BREADY = S_AXI_BREADY;

  //
  assign M_AXI_ARID = S_AXI_ARID;
  assign M_AXI_ARADDR = S_AXI_ARADDR;
  // assign M_AXI_ARLEN = S_AXI_ARLEN;
  // assign M_AXI_ARSIZE = S_AXI_ARSIZE;
  assign M_AXI_ARBURST = S_AXI_ARBURST;
  assign M_AXI_ARLOCK = S_AXI_ARLOCK;
  assign M_AXI_ARCACHE = S_AXI_ARCACHE;
  assign M_AXI_ARPROT = S_AXI_ARPROT;
  assign M_AXI_ARQOS = S_AXI_ARQOS;
  assign M_AXI_ARUSER = S_AXI_ARUSER;
  assign M_AXI_ARVALID = S_AXI_ARVALID;


  assign S_AXI_AWREADY = M_AXI_AWREADY;
  // assign S_AXI_WREADY = M_AXI_WREADY;
  assign S_AXI_BRESP = M_AXI_BRESP;
  // assign S_AXI_BUSER = M_AXI_BUSER;
  assign S_AXI_BVALID = M_AXI_BVALID;
  // assign S_AXI_ARREADY = axi_arready;
  // assign S_AXI_RDATA = axi_rdata;
  // assign S_AXI_RRESP = axi_rresp;
  // assign S_AXI_RLAST = axi_rlast;
  assign S_AXI_RUSER = M_AXI_RUSER;
  // assign S_AXI_RVALID = axi_rvalid;
  assign S_AXI_BID = S_AXI_AWID; //
  assign S_AXI_RID = S_AXI_ARID; //
  assign S_AXI_BUSER = 0; //

  reg [2:0]   read_in_state;

  wire        fifo_r_in_ready;
  wire        fifo_r_in_valid;
  wire [63:0] fifo_r_in_data;
  wire        fifo_r_in_data_last;

  wire        fifo_r_out_ready;
  wire        fifo_r_out_valid;
  wire [63:0] fifo_r_out_data;
  wire        fifo_r_out_data_last;


  assign fifo_r_in_valid = (read_in_state == 1) & M_AXI_RVALID;
  assign fifo_r_in_data = M_AXI_RDATA;
  assign fifo_r_in_data_last = M_AXI_RLAST;

  assign M_AXI_RREADY = (read_in_state == 1) & fifo_r_in_ready;
  assign M_AXI_ARSIZE = clogb2((64/8)-1);
  assign M_AXI_ARLEN = (C_S_AXI_BURST_LEN/2) - 1;

  // AXI Master Read FSM
  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0) begin
      read_in_state <= 0;
    end else begin
      case (read_in_state)
        0: begin
          if (S_AXI_ARREADY & M_AXI_ARVALID) begin
            read_in_state <= 1;
            if (LOG_ENABLED)
              $display("[axi4_32bit_to_64bit] read_in_state <= 1");
          end
        end
        1: begin
          if (M_AXI_RVALID & fifo_r_in_ready) begin
            if (LOG_ENABLED)
              $display("[axi4_32bit_to_64bit] M_AXI_RDATA : %x", M_AXI_RDATA);
            if (M_AXI_RLAST) begin
              read_in_state <= 2;
              if (LOG_ENABLED)
                $display("[axi4_32bit_to_64bit] read_in_state <= 2");
            end
          end
        end
        2: begin
          read_in_state <= 0;
        end
      endcase
    end
  end



  reg [2:0] read_out_state;
  wire      read_out_ready;
  // assign read_out_ready = (read_in_state == 2);
  assign read_out_ready = (read_in_state == 1);

  assign S_AXI_ARREADY = M_AXI_ARREADY;
  assign S_AXI_RDATA = (read_out_state == 2) ? fifo_r_out_data[31:0] : fifo_r_out_data[63:32];
  assign S_AXI_RRESP = 0;
  assign S_AXI_RVALID = ((read_out_state == 2) & fifo_r_out_valid) | (read_out_state == 3);
  assign S_AXI_RLAST = (read_out_state == 3) & fifo_r_out_data_last;



  assign fifo_r_out_ready = (read_out_state == 1) | ((read_out_state == 3) & S_AXI_RREADY & !fifo_r_out_data_last);

  // FIXME: fifo_r_out_valid kullanimi yanlis olabir, fifo hicbir zaman bosalmadigi icin problem olmuyor fakat incelenmeli

  // AXI Slave Read FSM
  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0) begin
      read_out_state <= 0;
    end else begin
      case (read_out_state)
        0: begin // idle
          if (read_out_ready) begin // FIXME: ...
            read_out_state <= 1;
            if (LOG_ENABLED)
              $display("[axi4_32bit_to_64bit] read_out_state <= 1");
          end
        end
        1: begin // wait fifo bram read
          read_out_state <= 2;
          if (LOG_ENABLED)
            $display("[axi4_32bit_to_64bit] read_out_state <= 2");
        end
        2: begin // burst
          if (!fifo_r_out_valid) begin
            read_out_state <= 1;
            if (LOG_ENABLED)
              $display("[axi4_32bit_to_64bit] read_out_state <= 1");
          end else if (S_AXI_RREADY) begin
            read_out_state <= 3;
            if (LOG_ENABLED)
              $display("[axi4_32bit_to_64bit] read_out_state <= 3  %x", S_AXI_RDATA);
          end
        end
        3: begin // burst 2
          if (S_AXI_RREADY) begin
            if (fifo_r_out_data_last) begin
              read_out_state <= 4;
              if (LOG_ENABLED)
                $display("[axi4_32bit_to_64bit] read_out_state <= 4  %x", S_AXI_RDATA);
            end else begin
              read_out_state <= 2;
              if (LOG_ENABLED)
                $display("[axi4_32bit_to_64bit] read_out_state <= 2  %x", S_AXI_RDATA);
            end
          end
        end
        4: begin // last
          if (LOG_ENABLED)
            $display("[axi4_32bit_to_64bit] read_out_state <= 0");
          read_out_state <= 0;
        end
      endcase
    end
  end


  wire [17:0] fifo_read_debug;

  fifo_v2 fifo_read_i
    (
     .debug(fifo_read_debug),
     .clk(M_AXI_ACLK),
     .resetn(M_AXI_ARESETN),
     .in_ready(fifo_r_in_ready),
     .in_valid(fifo_r_in_valid),
     .in_data(fifo_r_in_data),
     .in_data_2(fifo_r_in_data_last),
     .in_addr(),
     .out_ready(fifo_r_out_ready),
     .out_valid(fifo_r_out_valid),
     .out_data(fifo_r_out_data),
     .out_data_2(fifo_r_out_data_last),
     .out_addr()
     );


  assign debug_read = { 3'b0, fifo_r_out_data_last, S_AXI_ARREADY, M_AXI_ARVALID, S_AXI_RREADY, fifo_r_out_valid, fifo_read_debug[17:0], read_in_state[2:0], read_out_state[2:0] };

  // ------------------- write -------------------


  wire [63:0] fifo_w_in_data;
  wire        fifo_w_in_ready;
  wire        fifo_w_in_valid;
  wire        fifo_w_in_data_last;
  wire [8:0]  fifo_w_in_addr;

  wire [63:0] fifo_w_out_data;
  wire        fifo_w_out_data_last;
  wire        fifo_w_out_ready;
  wire        fifo_w_out_valid;
  wire [8:0]  fifo_w_out_addr;



  reg [2:0]   write_in_state;

  reg [31:0]  write_in_tmp;

  // assign S_AXI_WREADY = (write_in_state == 1) | (write_in_state == 2);

  assign S_AXI_WREADY = (write_in_state == 1) | (write_in_state == 2);


  assign fifo_w_in_data = { S_AXI_WDATA, write_in_tmp };
  assign fifo_w_in_valid = (write_in_state == 2) & S_AXI_WVALID;
  assign fifo_w_in_data_last = (write_in_state == 2) & S_AXI_WLAST;

  // AXI Slave Write FSM
  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0) begin
      write_in_state <= 0;
      write_in_tmp <= 0;
    end else begin
      case (write_in_state)
        0: begin // idle
          if (S_AXI_AWREADY & M_AXI_AWVALID) begin
            write_in_state <= 1;
            $display("[axi4_32bit_to_64bit] write_in_state <= 1");
          end
        end
        1: begin // burst
          if (S_AXI_WVALID) begin
            write_in_tmp <= S_AXI_WDATA;
            if (LOG_ENABLED)
              $display("[axi4_32bit_to_64bit] write_in_state <= 2");
            write_in_state <= 2;
          end
        end
        2: begin // burst 2
          if (S_AXI_WVALID) begin
            if (S_AXI_WLAST) begin
              if (LOG_ENABLED)
                $display("[axi4_32bit_to_64bit] write_in_state <= 3");
              write_in_state <= 3;
            end else begin
              if (LOG_ENABLED)
                $display("[axi4_32bit_to_64bit] write_in_state <= 1");
              write_in_state <= 1;
            end
          end
        end
        3: begin // end
          if (LOG_ENABLED)
            $display("[axi4_32bit_to_64bit] write_in_state <= 0");
          write_in_state <= 0;
        end
      endcase
    end
  end


  wire write_in_half_bit;
  reg  write_in_half_bit_d;
  assign write_in_half_bit = fifo_w_in_addr[clogb2(C_M_AXI_BURST_LEN)-2];

  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0)
      write_in_half_bit_d <= 0;
    else
      write_in_half_bit_d <= write_in_half_bit;
  end

  wire write_in_half;
  assign write_in_half = (write_in_half_bit_d != write_in_half_bit);



  wire write_out_ready;
  // assign write_out_ready = (write_in_state == 3);
  assign write_out_ready = write_in_half;


  reg [2:0] write_out_state;
  reg [63:0] wdata;

  assign M_AXI_AWSIZE = clogb2((64/8)-1);
  assign M_AXI_AWLEN = C_M_AXI_BURST_LEN - 1;

  assign M_AXI_WDATA = fifo_w_out_data;

  assign M_AXI_WVALID = ((write_out_state == 2) & fifo_w_out_valid);
  assign M_AXI_WLAST = (M_AXI_WVALID & fifo_w_out_data_last);


  assign fifo_w_out_ready = (write_out_state == 1) | ((write_out_state == 2) & M_AXI_WREADY & !fifo_w_out_data_last);


  // AXI Master Write FSM
  always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0) begin
      write_out_state <= 0;
      wdata <= 0;
    end else begin
      case (write_out_state)
        0: begin
          if (write_out_ready) begin
            write_out_state <= 1;
            if (LOG_ENABLED)
              $display("[axi4_32bit_to_64bit] write_out_state <= 1  fifo_w_in_addr:%d", fifo_w_in_addr);
          end
        end
        1: begin // wait fifo bram read
          write_out_state <= 2;
          if (LOG_ENABLED)
            $display("[axi4_32bit_to_64bit] write_out_state <= 2");
        end
        2: begin
          if (!fifo_w_out_valid) begin
            write_out_state <= 1;
            if (LOG_ENABLED)
              $display("[axi4_32bit_to_64bit] write_out_state <= 1");
          end else if (M_AXI_WREADY) begin
            if (LOG_ENABLED)
              $display("[axi4_32bit_to_64bit] M_AXI_WDATA : %x", M_AXI_WDATA);
            if (fifo_w_out_data_last) begin
              write_out_state <= 3;
              if (LOG_ENABLED)
                $display("[axi4_32bit_to_64bit] write_out_state <= 3");
            end
          end
        end
        3: begin
          write_out_state <= 0;
        end
      endcase
    end
  end

  wire [17:0] fifo_write_debug;

  fifo_v2 fifo_write_i
    (
     .debug(fifo_write_debug),

     .clk(M_AXI_ACLK),
     .resetn(M_AXI_ARESETN),
     .in_ready(fifo_w_in_ready),
     .in_valid(fifo_w_in_valid),
     .in_data(fifo_w_in_data),
     .in_data_2(fifo_w_in_data_last),
     .in_addr(fifo_w_in_addr),
     .out_ready(fifo_w_out_ready),
     .out_valid(fifo_w_out_valid),
     .out_data(fifo_w_out_data),
     .out_data_2(fifo_w_out_data_last),
     .out_addr(fifo_w_out_addr)
     );

  assign debug_write = { 3'b0, fifo_w_out_data_last, S_AXI_AWREADY, M_AXI_AWVALID, M_AXI_WREADY, fifo_w_out_valid, fifo_write_debug[17:0], write_in_state[2:0], write_out_state[2:0] };

endmodule
