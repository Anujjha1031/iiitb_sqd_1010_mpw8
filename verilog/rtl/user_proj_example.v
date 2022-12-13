// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;
   wire din;
   wire y;
   

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;
	
    

    // IO
    assign io_out[35] = y;
    assign io_oeb = 0;
    assign clk = wb_clk_i;
    assign rst = wb_rst_i;
    assign din = io_in[35]; 
    

    // IRQ
    assign irq = 3'b000;	// Unused

   
    iiitb_sqd_1010 instance (din,rst,clk,y);
    
    
endmodule

module iiitb_sqd_1010(din, reset, clk, y);
input din;
input clk;
input reset;
output reg y;
reg [1:0] cst, nst;
parameter S0 = 2'b00, //all state
          S1 = 2'b01,
          S2 = 2'b10,
          S3 = 2'b11;
always@(posedge clk)
	begin
	if(reset) begin
		y<=1'b0;
		cst<=1'b0;
		end
	else cst<=nst;
	
	if(din == 0 && cst == S3) y<= 1'b1;
	else	y<=1'b0;
	end
always @(cst or din)
 begin
 case (cst)
   S0: if (din == 1'b1)
          nst <= S1;
      else
          nst <= S0;
   S1: if (din == 1'b0)
        nst <= S2;
       else
           nst <= S0;
   S2: if (din == 1'b1)
         nst <= S3;
       else
          nst <= S0;
   S3: if (din == 1'b0)
          nst <= S0;
       else
          nst <= S1;
   default: nst <= S0;
  endcase
end

always@(posedge clk )
          begin
           if (reset)
             cst <= S0;
           else 
             cst <= nst;
          end
endmodule

`default_nettype wire
