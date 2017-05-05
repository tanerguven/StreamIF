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

module axi4_full_master_rw #
  (
   parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h00000000,
   // Burst Length. Supports 4, 8, 16, 32, 64, 128, 256 burst lengths
   parameter integer C_M_AXI_BURST_LEN	= 256,
   parameter integer C_M_AXI_ID_WIDTH	= 1,
   parameter integer C_M_AXI_ADDR_WIDTH	= 32,
   parameter integer C_M_AXI_DATA_WIDTH	= 32,
   parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
   parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
   parameter integer C_M_AXI_WUSER_WIDTH	= 0,
   parameter integer C_M_AXI_RUSER_WIDTH	= 0,
   parameter integer C_M_AXI_BUSER_WIDTH	= 0
   )
  (
   input wire [C_M_AXI_ADDR_WIDTH-1:0] 		write_address,
   input wire 								write_start,
   input wire [C_M_AXI_DATA_WIDTH-1:0] 		write_data,
   input wire 								write_data_valid,
   output wire 								write_data_last,
   output wire 								write_ready,
   output wire 								write_end,

   input wire [C_M_AXI_ADDR_WIDTH-1:0] 		read_address,
   input wire 								read_start,
   output wire [C_M_AXI_DATA_WIDTH-1:0] 		read_data,
   output wire 								read_data_valid,
   output wire 								read_data_last,
   input wire 								read_ready,
   output wire 								read_end,

   output wire 								output_idle,
   output wire 								output_error,
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


  function integer clogb2 (input integer bit_depth);
	begin
	  for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	    bit_depth = bit_depth >> 1;
	end
  endfunction


  /* axi signals */
  reg [C_M_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
  reg 							 axi_awvalid;
  wire [C_M_AXI_DATA_WIDTH-1 : 0] axi_wdata;
  reg 							  axi_wlast;
  wire 							  axi_wvalid;
  reg 							  axi_bready;
  reg [C_M_AXI_ADDR_WIDTH-1 : 0]  axi_araddr = 0;
  reg 							  axi_arvalid = 0;
  wire 							  axi_rready;

  /* */
  reg 							  error_reg;
  wire 							  write_resp_error;



  /*  */
  reg [2:0]  write_control_state = 0;
  reg [7:0]  write_burst_count = 0;
  reg [2:0]  read_control_state = 0;

  // I/O Connections assignments

  //I/O Connections. Write Address (AW)
  assign M_AXI_AWID	= 'b0;
  assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
  assign M_AXI_AWLEN	= C_M_AXI_BURST_LEN - 1;
  assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
  assign M_AXI_AWBURST	= 2'b01;
  assign M_AXI_AWLOCK	= 1'b0;
  assign M_AXI_AWCACHE	= 4'b0010;  //Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port.
  assign M_AXI_AWPROT	= 3'h0;
  assign M_AXI_AWQOS	= 4'h0;
  assign M_AXI_AWUSER	= 'b1;
  assign M_AXI_AWVALID	= axi_awvalid;
  //Write Data(W)
  assign M_AXI_WDATA	= axi_wdata;
  assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
  assign M_AXI_WLAST	= axi_wlast;
  assign M_AXI_WUSER	= 'b0;
  assign M_AXI_WVALID	= axi_wvalid;
  //Write Response (B)
  assign M_AXI_BREADY	= axi_bready;
  //Read Address (AR)
  assign M_AXI_ARID	= 'b0;
  assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;
  assign M_AXI_ARLEN	= C_M_AXI_BURST_LEN - 1;
  assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
  assign M_AXI_ARBURST	= 2'b01;
  assign M_AXI_ARLOCK	= 1'b0;
  assign M_AXI_ARCACHE	= 4'b0010; //Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port
  assign M_AXI_ARPROT	= 3'h0;
  assign M_AXI_ARQOS	= 4'h0;
  assign M_AXI_ARUSER	= 'b1;
  assign M_AXI_ARVALID	= axi_arvalid;
  //Read and Read Response (R)
  assign M_AXI_RREADY	= axi_rready;

  /* */
  assign output_idle = (write_control_state==0) && (read_control_state==0);
  assign output_error = error_reg;


  reg 		 write_control_wen;

  assign axi_wvalid = (write_data_valid && write_control_wen);
  assign axi_wdata = write_data;
  assign write_ready = (M_AXI_WREADY && write_control_wen);
  assign write_data_last = axi_wlast;

  always @(posedge M_AXI_ACLK) begin
	if (M_AXI_ARESETN == 0) begin
	  write_control_state <= 0;
	  axi_awaddr <= 0;
	  axi_awvalid <= 0;
	  axi_bready <= 0;

	  write_burst_count <= 0;
	  axi_wlast <= 0;

	  write_control_wen <= 0;
	end else begin
	  case (write_control_state)
		0: begin // idle
		  if (write_start) begin
			axi_awaddr <= write_address;
			axi_awvalid <= 1;

			write_control_state <= write_control_state + 1;
			$display("[axi4_full_master_rw_2] write_address: %x", write_address);
		  end
		end
		1: begin
		  if (M_AXI_AWREADY) begin
			axi_awvalid <= 0;

			write_control_state <= write_control_state + 1;

			write_burst_count <= 0;
			write_control_wen <= 1;
		  end
		end
		2: begin // burst state
		  if (M_AXI_WVALID && M_AXI_WREADY) begin

			if (write_burst_count == C_M_AXI_BURST_LEN-2) begin
			  axi_wlast <= 1;
			  write_control_state <= write_control_state + 1;
			end

			write_burst_count <= write_burst_count + 1;
			$display("[axi4_full_master_rw_v3] write: %x (%d/%d)", axi_wdata, write_burst_count+1, C_M_AXI_BURST_LEN);
		  end
		end
		3: begin
		  write_control_wen <= 0;
		  axi_wlast <= 0;
		  axi_bready <= 1;
		  write_control_state <= write_control_state + 1;
		  $display("[axi4_full_master_rw_v3] write: %x (%d/%d)", axi_wdata, write_burst_count+1, C_M_AXI_BURST_LEN);
		end
		4: begin
		  if (M_AXI_BVALID) begin
		  	axi_bready <= 0;
			write_control_state <= 0;
		  end
		end
	  endcase
	end
  end

  // gecikmeyi azaltmak icin bu sekilde cikis verildi
  // 1 clock high sinyal uretir
  assign write_end = (write_control_state == 4 && M_AXI_BVALID);



  assign read_data = M_AXI_RDATA;
  assign read_data_valid = M_AXI_RVALID && ((read_control_state == 2) || (read_control_state == 1)); // FIXME: state 1 de dahil olabilir
  assign read_data_last = M_AXI_RLAST;

  assign axi_rready = (read_ready && read_control_state == 2);

  /* read control state machine */
  always @(posedge M_AXI_ACLK) begin
	if (M_AXI_ARESETN == 0) begin
	  read_control_state <= 0;
	  axi_araddr <= 0;
	  axi_arvalid <= 0;
	end else begin
	  case (read_control_state)
		0: begin
		  if (read_start) begin
			axi_araddr <= read_address;
			axi_arvalid <= 1;
			read_control_state <= 1;
			$display("axi4_full_master_rw_v3 read_address: %x", read_address);
		  end
		end
		1: begin
		  if (M_AXI_ARREADY) begin
			axi_arvalid <= 0;
			read_control_state <= 2;
		  end
		end
		2: begin // burst state
		  if (M_AXI_RLAST && M_AXI_RVALID) // axi crossbar RLAST i tumune gonderiyor
			read_control_state <= 3;

		end
		3: begin // end state
			read_control_state <= 0;
		end
	  endcase
	end
  end

  assign read_end = (read_control_state == 3);

  /* error_reg */
  assign write_resp_error = axi_bready & M_AXI_BVALID & M_AXI_BRESP[1];
  always @(posedge M_AXI_ACLK) begin
	if (M_AXI_ARESETN == 0) begin
	  error_reg <= 1'b0;
	end else if (write_resp_error) begin
	  $display("write_resp_error");
	  $finish;
	  error_reg <= 1'b1;
	end else begin
	  error_reg <= error_reg;
	end
  end


endmodule
