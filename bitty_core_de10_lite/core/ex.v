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

module ex(
    input   wire            rst,

    // from id/ex 译码阶段送到执行阶段的信息
    input   wire[`InstAddrBus]  ex_pc,
    input   wire[`InstBus]      ex_inst,
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`AluSelBus]    alusel_i,
    input   wire[`RegBus]       reg1_i,
    input   wire[`RegBus]       reg2_i,
    input   wire[`RegAddrBus]   wd_i,
    input   wire                wreg_i,
    input   wire                wcsr_reg_i,
    input   wire[`RegBus]       csr_reg_i,
    input   wire[`DataAddrBus]  wd_csr_reg_i,

    // 执行结果 to ex_mem
    output  reg[`RegAddrBus]    wd_o,
    output  reg                 wreg_o,
    output  reg[`RegBus]        wdata_o,

    output  reg[`AluOpBus]      ex_aluop_o,
    output  reg[`DataAddrBus]   ex_mem_addr_o,
    output  reg[`RegBus]        ex_reg2_o,

    // output to csr_reg
    output  wire                wcsr_reg_o,         // write csr enable
    output  wire[`DataAddrBus]  wd_csr_reg_o,
    output  reg[`RegBus]        wcsr_data_o,   

    // output  pc_reg / ctrl
    output  reg                 branch_flag_o,
    output  reg[`RegBus]        branch_addr_o
);

    // aluop 传递到 访存阶段
    always @ (*) begin
        if (rst == `RstEnable) begin
            ex_aluop_o  <= `EXE_NONE;
            ex_reg2_o   <= `ZeroWord;
            ex_mem_addr_o  <= `ZeroWord;
        end else begin
            ex_aluop_o  <= aluop_i;
            ex_reg2_o   <= reg2_i; 
            case (alusel_i)
                `EXE_RES_LOAD: begin
                    ex_mem_addr_o   <= (reg1_i + {{20{ex_inst[31]}}, ex_inst[31:20]});
                end
                `EXE_RES_STORE: begin
                    ex_mem_addr_o   <= (reg1_i + {{20{ex_inst[31]}}, ex_inst[31:25], ex_inst[11:7]});
                end
                default: begin
                    ex_mem_addr_o   <= `ZeroWord;
                end
            endcase
        end
    end

    // 相减结果
    wire[31:0]      exe_res_sub = reg1_i - reg2_i;

    // 保存逻辑运算的结果
    reg[`RegBus]    logicout;
    reg[`RegBus]    compare;        // 比较结果
    reg[`RegBus]    shiftres;       // 移位结果
    reg[`RegBus]    arithres;       // 算术结果
    reg[`RegBus]    branchres;      // 跳转回写偏移结果

    // 1. 根据 aluop_i 指示的运算子类型进行运算 
    // logic 
    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout    <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_AND: begin
                    logicout    <= (reg1_i & reg2_i);
                end
                `EXE_OR: begin
                    logicout    <= (reg1_i | reg2_i);
                end 
                `EXE_XOR: begin
                    logicout    <= (reg1_i ^ reg2_i);
                end
                default:   begin
                    logicout    <= `ZeroWord;
                end
            endcase
        end // if
    end // always

    // compare
    always @ (*) begin
        if (rst == `RstEnable) begin
            compare <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLT:  begin
                    if (reg1_i[31] != reg2_i[31]) begin
                        compare <= (reg1_i[31] ? 32'h1 : 32'h0);
                    end else begin
                        compare <= (exe_res_sub[31] ? 32'h1 : 32'h0);
                    end
                end 
                `EXE_SLTU: begin
                    compare <= ((reg1_i < reg2_i) ? 32'h1 : 32'h0);
                end
                default: begin
                    compare <= `ZeroWord;
                end
            endcase
        end
    end

    // shift
    always @ (*) begin
        if (rst == `RstEnable) begin
            shiftres    <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL: begin
                    shiftres    <= (reg1_i << reg2_i[4:0]);
                end
                `EXE_SRL: begin
                    shiftres    <= (reg1_i >> reg2_i[4:0]);
                end 
                `EXE_SRA: begin
                    shiftres    <= (({32{reg1_i[31]}} << (6'd32 - {1'b0, reg2_i[4:0]})) | (reg1_i >> reg2_i[4:0]));
                end
                `EXE_LUI: begin
                    shiftres    <= reg2_i;
                end
                default: begin
                    shiftres    <= `ZeroWord;
                end
            endcase
        end
    end

    // arith
    always @ (*) begin
        if (rst == `RstEnable) begin
            arithres    <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_ADD: begin
                    arithres    <= (reg1_i + reg2_i);
                end 
                `EXE_SUB: begin
                    arithres    <= (reg1_i - reg2_i);
                end
                default: begin
                    arithres    <= `ZeroWord;
                end 
            endcase
        end
    end

    // branch 
    always @ (*) begin
        if (rst == `RstEnable) begin
            branch_flag_o   <= `BranchDisable;
            branch_addr_o   <= `ZeroWord;
				branchres       <= `ZeroWord;
        end else begin
            branch_flag_o   <= `BranchDisable;
		      branch_addr_o   <= `ZeroWord;
				branchres       <= `ZeroWord;
            case (aluop_i)
                `EXE_BEQ: begin
                    if (reg1_i == reg2_i) begin
                        branch_flag_o   <= `BranchEnable;
                        branch_addr_o   <= ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else begin
                        branch_flag_o   <= `BranchDisable;
                    end
                end 
                `EXE_BNE: begin
                    if (reg1_i != reg2_i) begin
                        branch_flag_o   <= `BranchEnable;
                        branch_addr_o   <= ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else begin
                        branch_flag_o   <= `BranchDisable;
                    end
                end
                `EXE_BLT: begin
                    if (reg1_i[31] != reg2_i[31]) begin
                        branch_flag_o   <= (reg1_i[31] ? `BranchEnable : `BranchDisable);
                        branch_addr_o   <= ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else if (reg1_i < reg2_i) begin
                        branch_flag_o   <= `BranchEnable;
                        branch_addr_o   <= ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0}; 
                    end else begin
                        branch_flag_o   <= `BranchDisable;
                    end
                end
                `EXE_BGE: begin
                    if (reg1_i[31] != reg2_i[31]) begin
                        branch_flag_o   <= (reg1_i[31] ? `BranchDisable : `BranchEnable);
                        branch_addr_o   <= ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else if (reg1_i < reg2_i) begin
                        branch_flag_o   <= `BranchDisable;
                    end else begin
                        branch_flag_o   <= `BranchEnable;
                        branch_addr_o   <= ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end
                end
                `EXE_BLTU: begin
                    if (reg1_i[31] != reg2_i[31]) begin
                        branch_flag_o   <= (reg1_i[31] ? `BranchDisable : `BranchEnable);
                        branch_addr_o   <= ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else if (reg1_i < reg2_i) begin
                        branch_flag_o   <= `BranchEnable;
                        branch_addr_o   <= ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else begin
                        branch_flag_o   <= `BranchDisable;
                    end
                end
                `EXE_BGEU: begin
                    if (reg1_i[31] != reg2_i[31]) begin
                        branch_flag_o   <= (reg1_i[31] ? `BranchEnable : `BranchDisable);
                        branch_addr_o   <= ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0}; 
                    end else if (reg1_i < reg2_i) begin
                        branch_flag_o   <= `BranchDisable;
                    end else begin
                        branch_flag_o   <= `BranchEnable;
                        branch_addr_o   <= ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end
                end
                `EXE_JAL:  begin
                    branch_flag_o   <= `BranchEnable;
                    branch_addr_o   <= ex_pc + {{12{ex_inst[31]}}, ex_inst[19:12], ex_inst[20], ex_inst[30:21], 1'b0};
                    branchres       <= ex_pc + 4'h4;
                end
                `EXE_JALR: begin
                    branch_flag_o   <= `BranchEnable;
                    branch_addr_o   <= (reg1_i + {{20{ex_inst[31]}}, ex_inst[31:20]}) & (32'hfffffffe);
                    branchres       <= ex_pc + 4'h4;
                end

                default: begin
                    branch_flag_o   <= `BranchDisable;
                    branch_addr_o   <= `ZeroWord;
						  branchres       <= `ZeroWord;
                end
            endcase
        end
    end

    // csrr
	 assign wcsr_reg_o = wcsr_reg_i;
    assign wd_csr_reg_o = wd_csr_reg_i;

    always @ (*) begin
        if (rst == `RstEnable) begin
            wcsr_data_o <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_CSRRW: begin
                    wcsr_data_o <= reg1_i;
                end
                `EXE_CSRRS: begin
                    wcsr_data_o <= csr_reg_i | reg1_i;
                end
                `EXE_CSRRC: begin
                    wcsr_data_o <= csr_reg_i & (~reg1_i);
                end
                default: begin
                    wcsr_data_o <= `ZeroWord;
                end
            endcase
        end
    end


    // 2. 根据 alusel_i 指示的运算类型，选择一个运算结果作为最终结果
    always @ (*) begin
        wd_o    <= wd_i;    // wd_o 等于 wd_i, 要写的目的寄存器地址
        wreg_o  <= wreg_i;  // wreg_o 等于 wreg_i,表示是否要写目的寄存器
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                wdata_o <= logicout;    // wdata_o 中存放运算结果
            end 
            `EXE_RES_COMPARE: begin
                wdata_o <= compare;  
            end
            `EXE_RES_SHIFT: begin
                wdata_o <= shiftres;
            end
            `EXE_RES_ARITH: begin
                wdata_o <= arithres;
            end
            `EXE_RES_BRANCH: begin
                wdata_o <= branchres;
            end
            `EXE_RES_CSR   : begin
                wdata_o <= csr_reg_i;
            end
            default:    begin
                wdata_o <= `ZeroWord;
            end
        endcase
    end

endmodule // ex
