/******************************************************************************
MIT License

Copyright (c) 2020 BH6BAO

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

******************************************************************************/

`include "bitty_defs.v"

module data_ram(
    input   wire                clk,
//    input   wire                rst,
    input   wire                ce,
    input   wire                we,
    input   wire[`DataAddrBus]  addr,
    input   wire[3:0]           sel,
    input   wire[`DataBus]      data_i,
    
	 input   wire                pc_ce,
    input   wire[31:0]          pc_addr,
    output  wire[31:0]          inst_o,
	 
    output  reg[`DataBus]       data_o
);

    // reg[`DataBus]       data_mem[0:`DataMemNum - 1];
    reg[`ByteWidth]     data_mem0[0:`DataMemNum - 1];
    reg[`ByteWidth]     data_mem1[0:`DataMemNum - 1];
    reg[`ByteWidth]     data_mem2[0:`DataMemNum - 1];
    reg[`ByteWidth]     data_mem3[0:`DataMemNum - 1];

    wire[31:0]  mem_out;

//    bitty_ram0 u_ram0(
//	     .address(pc_addr[11:2]),
//	     .clock(clk),
//	     .data(data_i[7:0]),
//        .rden(pc_ce),
//        .wren(1'b0),
//        .q(inst_o[7:0])
//		  );
//
//    bitty_ram1 u_ram1(
//	     .address(pc_addr[11:2]),
//	     .clock(clk),
//	     .data(data_i[15:8]),
//        .rden(pc_ce),
//        .wren(1'b0),
//        .q(inst_o[15:8])
//		  );
//
//    bitty_ram2 u_ram2(
//	     .address(pc_addr[11:2]),
//	     .clock(clk),
//	     .data(data_i[23:16]),
//        .rden(pc_ce),
//        .wren(1'b0),
//        .q(inst_o[23:16])
//		  );
//		  
//    bitty_ram3 u_ram3(
//	     .address(pc_addr[11:2]),
//	     .clock(clk),
//	     .data(data_i[31:24]),
//        .rden(pc_ce),
//        .wren(1'b0),
//        .q(inst_o[31:24])
//		  );

	 bitty_inst_rom u_bitty_inst_rom0(
	     .address(pc_addr[11:2]),
	     .clock(clk),
	     .q(inst_o[7:0])
		  );
		  
	 bitty_inst_rom1 u_bitty_inst_rom1(
	     .address(pc_addr[11:2]),
	     .clock(clk),
	     .q(inst_o[15:8])
		  );
		  
	 bitty_inst_rom2 u_bitty_inst_rom2(
	     .address(pc_addr[11:2]),
	     .clock(clk),
	     .q(inst_o[23:16])
		  );
		  
	 bitty_inst_rom3 u_bitty_inst_rom3(
	     .address(pc_addr[11:2]),
	     .clock(clk),
	     .q(inst_o[31:24])
		  );


//    always @ (posedge clk) begin
//        inst_o <= mem_out;
//    end	 

    // write 
    always @ (posedge clk) begin
        if (ce == `ReadDisable) begin
            // data_o   <= `ZeroWord;
        end else if (we == `WriteEnable) begin
            if (sel[0] == 1'b1) begin
                data_mem0[addr[`DataMemNumLog2+1 : 2]] <= data_i[7:0];
            end
            if (sel[1] == 1'b1) begin
                data_mem1[addr[`DataMemNumLog2+1 : 2]] <= data_i[15:8];
            end
            if (sel[2] == 1'b1) begin
                data_mem2[addr[`DataMemNumLog2+1 : 2]] <= data_i[23:16];
            end
            if (sel[3] == 1'b1) begin
                data_mem3[addr[`DataMemNumLog2+1 : 2]] <= data_i[31:24];
            end
        end
    end

    // read 
    always @ (*) begin
        if (ce == `ReadDisable) begin
            data_o  <= `ZeroWord;
        end else if (we == `WriteDisable) begin
            data_o  <={data_mem3[addr[`DataMemNumLog2 + 1 : 2]],
                        data_mem2[addr[`DataMemNumLog2 + 1 : 2]],
                        data_mem1[addr[`DataMemNumLog2 + 1 : 2]],
                        data_mem0[addr[`DataMemNumLog2 + 1 : 2]]};
        end else begin
            data_o  <= `ZeroWord;
        end
    end

endmodule // data_ram
