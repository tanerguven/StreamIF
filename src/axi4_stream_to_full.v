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

module axi4_stream_to_full #
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
   input wire                               ACLK,
   input wire                               ARESETN,
   input wire                               sw_reset,
   output reg                               sw_reset_ok,
   /* control ports */
   input wire [C_M_AXI_ADDR_WIDTH-1 : 0]    write_address,
   input wire                               write_start,
   output wire                              output_idle,
   output reg [C_AXI_DATA_WIDTH-1:0]        debug_data_sum,
   /* axi4-stream ports */
   output wire                              S_AXIS_TREADY,
   input wire [C_AXI_DATA_WIDTH-1 : 0]      S_AXIS_TDATA,
   input wire [(C_AXI_DATA_WIDTH/8)-1 : 0]  S_AXIS_TSTRB,
   input wire                               S_AXIS_TLAST,
   input wire                               S_AXIS_TVALID,
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
   output wire [C_AXI_DATA_WIDTH-1 : 0]     M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1 : 0]   M_AXI_WSTRB,
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
   input wire [C_AXI_DATA_WIDTH-1 : 0]      M_AXI_RDATA,
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


  wire           axi_stream_enabled;
  wire           axi_stream_data_valid;
  wire [C_AXI_DATA_WIDTH-1:0] axi_stream_data;

  axi4_stream_reader #
    (
     .C_S_AXIS_TDATA_WIDTH(C_AXI_DATA_WIDTH)
     )
  axi_stream_i
    (
     /* axi4-stream ports */
     .S_AXIS_ACLK(ACLK),
     .S_AXIS_ARESETN(ARESETN),
     .S_AXIS_TREADY(S_AXIS_TREADY),
     .S_AXIS_TDATA(S_AXIS_TDATA),
     .S_AXIS_TSTRB(S_AXIS_TSTRB),
     .S_AXIS_TLAST(S_AXIS_TLAST),
     .S_AXIS_TVALID(S_AXIS_TVALID),
     /* control signals */
     .ready(axi_stream_enabled),
     .data_valid(axi_stream_data_valid),
     .data(axi_stream_data)
     );


  reg [C_M_AXI_ADDR_WIDTH-1:0] axi_mm_write_address;
  wire [C_AXI_DATA_WIDTH-1:0]  axi_mm_write_data;
  wire                         axi_mm_write_data_valid;
  reg                          axi_mm_write_enabled;
  wire                         axi_mm_write_start;
  wire                         axi_mm_write_end;
  wire                         axi_mm_write_ready;

  // wire [C_M_AXI_ADDR_WIDTH-1:0]    axi_mm_read_address;
  // wire           axi_mm_start_read;

  wire                         axi_mm_output_idle;
  wire                         axi_mm_output_error;
  assign axi_mm_read_address = 0;
  assign axi_mm_start_read = 0;


  reg                          axi_mm_write_enabled_prev;
  always @(posedge ACLK) begin
    axi_mm_write_enabled_prev <= axi_mm_write_enabled;
  end

  // 1 clock signal when write_enabled
  assign axi_mm_write_start = (~axi_mm_write_enabled_prev & axi_mm_write_enabled);


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
     .write_start(axi_mm_write_start),
     .write_ready(axi_mm_write_ready),
     .write_end(axi_mm_write_end),
     .write_data_last(), //

     // .read_address(axi_mm_read_address),
     // .start_read(axi_mm_start_read),

     .read_address(0),
     .read_start(1'b0), //
     .read_data(), //
     .read_data_valid(), //
     .read_data_last(), //
     .read_ready(1'b0), //
     .read_end(), //

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


  // stream <-> mm signals
  assign axi_stream_enabled = axi_mm_write_ready && axi_mm_write_enabled;
  assign axi_mm_write_data = axi_stream_data;
  assign axi_mm_write_data_valid = axi_stream_data_valid || sw_reset;

  reg [3:0] state;
  assign output_idle = (state == 0);
  always @(posedge ACLK) begin
    if (ARESETN == 0) begin
      debug_data_sum <= 0;
      state <= 0;
      axi_mm_write_enabled <= 0;
      axi_mm_write_address <= 0;
      sw_reset_ok <= 0;
    end else if (sw_reset) begin
      // axi-mm'e write_data_walid veriyoruz
      if (axi_mm_output_idle) begin
        sw_reset_ok <= 1;
      end
    end else begin
      sw_reset_ok <= 0;

      case (state)
        0: begin
          if (write_start) begin
            $display("write start, write_address: %x", write_address);
            axi_mm_write_address <= write_address;
            axi_mm_write_enabled <= 1;
            $display("axi4_s2mm state <= 1");
            state <= 1;
          end
        end
        1: begin
          if (M_AXI_WVALID && M_AXI_WREADY) begin
            debug_data_sum <= debug_data_sum + M_AXI_WDATA;
          end

          if (M_AXI_WLAST) begin
            axi_mm_write_enabled <= 0;
            state <= 2;
            $display("axi4_s2mm state <= 2");
          end
        end
        2: begin
          if (axi_mm_write_end) begin
            state <= 0;
            $display("axi4_s2mm state <= 0");
          end
        end
      endcase
    end
  end
endmodule
