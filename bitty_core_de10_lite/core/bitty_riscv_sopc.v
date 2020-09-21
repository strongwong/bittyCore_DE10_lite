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

module bitty_riscv_sopc(
    input   wire        clk,
    input   wire        rst,
	 
	 output              rst_out,
	 
	 output  wire[1:0]   ledh_out,
	 
	 output	wire[5:0]   led_out
);


    reg                 rst_s1;
	 reg                 rst_s2;
	 wire                rst_nr;

//	 wire[31:0]          ip_inst_o;
	 
    // 连接指令存储器
    wire[`InstAddrBus]  inst_addr_o;
    wire[`InstBus]       inst_rom_o;
    wire                core_ce_o;

    // risc-v ram
    wire                mem_ce_i;
    wire                mem_we_i;
    wire[`DataAddrBus]  mem_addr_i;
    wire[`DataBus]      mem_data_i;
    wire[`DataBus]      mem_data_o;
    wire[3:0]           mem_sel_i;
	 
	 assign ledh_out[0] = core_ce_o;
	 assign ledh_out[1] = mem_ce_i;
//	 assign ledh_out[2] = inst_addr_o[2];


//	 always @ (*) begin
//        ledh_out[0] <= core_ce_o;
//	//	  ledh_out[10:1] <= inst_addr_o[11:2];
//	 end

//    reg clk;
//    always @ (posedge clk_50) begin
//	     clk = ~clk_50;
//	 end

//    always @ (posedge clk or negedge rst) begin
//	     if (!rst) begin 
//		     rst_s1 <= 1'b0;
//			  rst_s2 <= 1'b0;
//		  end else begin
//		     rst_s1 <= 1'b1;
//			  rst_s2 <= rst_s1;
//		  end
//	 end

		assign rst_out = rst;  
//    assign rst_nr = rst_s2;	  
//    assign rst_out = rst_s2;
	 
//    always @ (posedge clk) begin
//	    if (rst == `RstEnable) begin
//		     led_out[0] <= 1'b0;
//			  led_out[1] <= 1'b0;
//		 end else begin
//		     led_out[0] <= u_bitty_riscv.u_regsfile.regs[26];
//			  led_out[0] <= u_bitty_riscv.u_regsfile.regs[27];
//		 end
//	 end

	 
    // 例化处理器 bitty risc-v
    bitty_riscv    u_bitty_riscv(
        .clk(clk),
        .rst(rst),
		  
		  .led_out(led_out),
		  
        .rom_data_i(inst_rom_o),
        .pc_addr_o(inst_addr_o),
        .pc_ce_o(core_ce_o),

        .ram_data_i(mem_data_o),
        .ram_addr_o(mem_addr_i),
        .ram_data_o(mem_data_i),
        .ram_we_o(mem_we_i),
        .ram_sel_o(mem_sel_i),
        .ram_ce_o(mem_ce_i)
    );

    // 例化指令存储器 ROM
//    inst_rom    u_inst_rom(
//        .ce_i(core_ce_o),
//        .addr_i(inst_addr_o),
//        .inst_o(inst_rom_o)
//    );
	 
	 
	 
//	 bitty_inst_rom u_bitty_inst_rom0(
//	     .address(inst_addr_o[8:2]),
//	     .clock(clk),
//	     .rden(core_ce_o),
//	     .q(ip_inst_o[7:0])
//		  );
//		  
//	 bitty_inst_rom1 u_bitty_inst_rom1(
//	     .address(inst_addr_o[8:2]),
//	     .clock(clk),
//	     .rden(core_ce_o),
//	     .q(ip_inst_o[15:8])
//		  );
//		  
//	 bitty_inst_rom2 u_bitty_inst_rom2(
//	     .address(inst_addr_o[8:2]),
//	     .clock(clk),
//	     .rden(core_ce_o),
//	     .q(ip_inst_o[23:16])
//		  );
//		  
//	 bitty_inst_rom3 u_bitty_inst_rom3(
//	     .address(inst_addr_o[8:2]),
//	     .clock(clk),
//	     .rden(core_ce_o),
//	     .q(ip_inst_o[31:24])
//		  );
//
//    always @ (*) begin
//        inst_rom_o = ip_inst_o;
//	 end
//    wire[31:0] addr_i;
//    assign addr_i = (mem_ce_i ? mem_addr_i : inst_addr_o);
    // ram data
    data_ram    u_data_ram(
        .clk(clk),
        .ce(mem_ce_i),
        .we(mem_we_i),
        .addr(mem_addr_i),
        .sel(mem_sel_i),
        .data_i(mem_data_i),

        .pc_ce(core_ce_o),
        .pc_addr(inst_addr_o),
		  .inst_o(inst_rom_o),
		  
        .data_o(mem_data_o)
    );

endmodule // bitty_riscv_sopc
