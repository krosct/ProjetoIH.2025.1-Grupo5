module Cpu (
    input wire clk,
    input wire reset
);

    // Saidas Mux
    wire [31:0] mux_iord;
    wire [31:0] mux_contorexcep;
    wire [31:0] mux_selectbytesrc;
    wire [31:0] mux_pcsource;
    wire [31:0] mux_shamtsource;
    wire [31:0] mux_shiftfuncsrc;
    wire [31:0] mux_memtoreg;
    wire [31:0] mux_regdst;
    wire [31:0] mux_alusrca;
    wire [31:0] mux_alusrcb;

    // Saidas Controle
    wire ctrl_pcwritecondbeq;
    wire ctrl_pcwrite;
    wire ctrl_pcwritecondbne;
    wire ctrl_iord;
    wire ctrl_contorexcep;
    wire ctrl_selectbytesrc;
    wire ctrl_pcsource;
    wire ctrl_shamtsource;
    wire ctrl_shiftfuncsrc;
    wire ctrl_memtoreg;
    wire ctrl_regdst;
    wire ctrl_alusrca;
    wire ctrl_alusrcb;
    wire ctrl_epcwrite;
    wire ctrl_memread;
    wire ctrl_memwrite;
    wire ctrl_irwrite;
    wire ctrl_mdr1;
    wire ctrl_mdr2;
    wire ctrl_selectbyte;
    wire ctrl_hi;
    wire ctrl_lo;
    wire ctrl_divmult;
    wire ctrl_regwrite;
    wire ctrl_controla;
    wire ctrl_controlb;
    wire ctrl_aluop;
    wire ctrl_aluout;
    wire ctrl_opcodeexception;
    wire [2:0] alucontrol_out;

    // Saidas Alu
    wire [31:0] alu_result;
    wire alu_zero;
    wire alu_notzero;
    wire alu_overflowexception;

    // Saidas Condicionadores (and, or...)
    wire and_zero;
    wire and_notzero;
    wire or_pcwrite;

    // Saidas Registradores
    wire [31:0] pc_out;
    wire [31:28] pc_pcsource_out;
    wire [31:26] opcode;
    wire [25:21] rs;
    wire [20:16] rt;
    wire [15:0] immediate;
    wire [25:0] offset;
    wire [15:11] rd;
    wire [10:6] shamt;
    wire [2:0] instr_shiftfuncsrc_out;
    wire [5:0] funct;
    wire [31:0] mdr1_out;
    wire [31:0] mdr2_out;
    wire [31:0] lo_out;
    wire [31:0] hi_out;
    wire [31:0] reg_readdata1_out;
    wire [31:0] reg_readdata2_out;
    wire [31:0] a_out;
    wire [31:0] b_out;
    wire [31:0] reg_deslocamento_out;
    wire [31:0] aluout_out;

    // Saidas Componenetes Diversos
    wire [31:0] memory_memdata_out;
    wire [31:0] selectbyte_out;
    wire [31:0] divmult_hi_out;
    wire [31:0] divmult_lo_out;
    wire [31:0] divmult_zeroexception_out;
    wire [31:0] sign_extend_out;
    wire [31:0] shiftleft16_out;
    wire [31:0] shiftleft2bottom_out;
    wire [25:0] shiftleft2top_out;

    // Saidas Constantes
    wire [31:0] c_255;
    wire [31:0] c_254;
    wire [31:0] c_253;
    wire [31:0] c_29;
    wire [31:0] c_r31;
    wire [31:0] c_227;
    wire [31:0] c_0;
    wire [31:0] c_4;
    wire [31:0] c_001;
    wire [31:0] c_010;
    assign c_255 = 31'd255;
    assign c_254 = 31'd254;
    assign c_253 = 31'd253;
    assign c_29 = 31'd29;
    reg r31 = 31'b00;
    assign c_r31 = r31;
    assign c_227 = 31'd227;
    assign c_0 = 31'd0;
    assign c_4 = 31'd4;
    assign c_001 = 31'b001;
    assign c_010 = 31'b010;

    // Saidas fakes
    wire epc_out;
    wire nouse;
    assign nouse = 31'b00;

    Registrador regPC(.Clk(clk), .Reset(reset), .Load(or_pcwrite), .Entrada(mux_contorexcep), .Saida(pc_out));
    Registrador regEPC(.Clk(clk), .Reset(reset), .Load(ctrl_epcwrite), .Entrada(pc_out), .Saida(epc_out));
    Memoria memoria(.Address(mux_iord), .Clock(clk), .Wr(ctrl_memread), .Datain(selectbyte_out), .Dataout(memory_memdata_out));
    Instr_Reg instrREG(.Clk(clk), .Reset(reset), .Load_ir(ctrl_irwrite), .Entrada(memory_memdata_out), .Instr31_26(opcode), .Instr25_21(rs), .Instr20_16(rt), .Instr15_0(immediate));
    Registrador regMDR1(.Clk(clk), .Reset(reset), .Load(ctrl_mdr1), .Entrada(memory_memdata_out), .Saida(mdr1_out));
    Registrador regMDR2(.Clk(clk), .Reset(reset), .Load(ctrl_mdr2), .Entrada(memory_memdata_out), .Saida(mdr2_out));
    Registrador regLO(.Clk(clk), .Reset(reset), .Load(ctrl_lo), .Entrada(divmult_lo_out), .Saida(lo_out));
    Registrador regHI(.Clk(clk), .Reset(reset), .Load(ctrl_hi), .Entrada(divmult_hi_out), .Saida(hi_out));
    Banco_reg bancoREG(.Clk(clk), .Reset(reset), .RegWrite(ctrl_regwrite), .ReadReg1(rs), .ReadReg2(rt), .WriteReg(mux_regdst), .WriteData(selectbyte_out), .ReadData1(Read_Data1_Out), .ReadData2(Read_Data2_Out));
    Registrador regA(.Clk(clk), .Reset(reset), .Load(ctrl_controla), .Entrada(Read_Data1_Out), .Saida(a_out));
    Registrador regB(.Clk(clk), .Reset(reset), .Load(ctrl_controlb), .Entrada(Read_Data2_Out), .Saida(b_out));
    Registrador regALUOUT(.Clk(clk), .Reset(reset), .Load(ctrl_aluout), .Entrada(alu_result), .Saida(aluout_out));
    RegDesloc regDESLOC(.Clk(clk), .Reset(reset), .Shift(mux_shiftfuncsrc), .N(mux_shamtsource), .Entrada(Read_Data2_Out), .Saida(reg_deslocamento_out));
    ula32 ALU(.A(mux_alusrca), .B(mux_alusrcb), .Seletor(alucontrol_out), .S(alu_result), .Overflow(alu_overflowexception), .Negativo(nouse), .z(alu_zero), .Igual(nouse), .Maior(nouse), .Menor(nouse));
    Mux_1bit contorexcep(.ctrl(ctrl_contorexcep), .o0(mux_pcsource), .o1(selectbyte_out), .out(mux_contorexcep));
    Mux_3bits iord(.ctrl(ctrl_iord), .o0(pc_out), .o1(aluout_out), .o2(c_253), .o3(c_254), .o4(c_255), .o5(nouse), .o6(nouse), .o7(nouse), .out(mux_iord));
    Mux_2bits selectbytesrc(.ctrl(ctrl_selectbytesrc), .o0(pc_out), .o1(b_out), .o2(mux_memtoreg), .o3(nouse), .out(mux_selectbytesrc));
    Mux_3bits memtoreg(.ctrl(ctrl_memtoreg), .o0(mdr1_out), .o1(mdr2_out), .o2(reg_deslocamento_out), .o3(lo_out), .o4(hi_out), .o5(c_227), .o6(aluout_out), .o7(nouse), .out(mux_memtoreg));
    Mux_2bits regdst(.ctrl(ctrl_regdst), .o0(rt), .o1(rd), .o2(c_29), .o3(c_r31), .out(mux_regdst));
    Mux_muxshamtsource shamtsource(.ctrl(ctrl_shamtsource), .o0(immediate), .o1(mux_memtoreg), .out(mux_shamtsource));
    Mux_muxshiftfuncsrc shiftfuncsrc(.ctrl(ctrl_shiftfuncsrc), .o0(immediate), .o1(c_001), .o2(c_010), .o3(nouse), .out());
    Mux_2bits alusrca(.ctrl(ctrl_alusrca), .o0(c_0), .o1(pc_out), .o2(a_out), .o3(nouse), .out(mux_alusrca));
    Mux_3bits alusrcb(.ctrl(ctrl_alusrcb), .o0(b_out), .o1(c_4), .o2(sign_extend_out), .o3(shiftleft16_out), .o4(shiftleft2bottom_out), .o5(nouse), .o6(nouse), .o7(nouse), .out(mux_alusrcb));
    Mux_muxpcsource pcsource(.ctrl(ctrl_pcsource), .o0(pc_out), .o1(aluout_out), .o2(pc_out), .o3(shiftleft2top_out), .out(mux_pcsource));
    ByteSelector selectbyte(.ctrl(ctrl_selectbyte), .o0(mux_selectbytesrc), .out(selectbyte_out));
    SignExtend signextend(.di(immediate), .do(sign_extend_out));
    ShiftLeft16 shiftleft16(.di(sign_extend_out), .do(shiftleft16_out));
    ShiftLeft2bottom shiftleft2bottom(.di(sign_extend_out), .do(shiftleft2bottom_out));
    ShiftLeft2top shiftleft2top(.di1(rs), .di2(rt), .di3(immediate), .do(shiftleft2bottom_out));
   // DivMult divmult(.divmult_zeroexception); // ! completar apos fazer o modulo divmult

    control_unit control(
        // inputs
        .clk(clk),
        .resett(reset),
        .OverflowException(alu_overflowexception),
        .ng(nouse), // ?
        .Zero(alu_zero),
        .ZeroException(divmult_zeroexception),
        .eq(nouse),
        .gt(nouse),
        .lt(nouse),
        .opcode(opcode),
        .funct(funct),
        // outputs
        .PCWrite(ctrl_pcwrite),
        .EPCWrite(ctrl_epcwrite),
        .ALUOp(ctrl_aluop),
        .MemRead(ctrl_memread),
        .MemWrite(ctrl_memwrite),
        .IRWrite(ctrl_IRWrite),
        .RegWrite(ctrl_regwrite),
        .ControlA(ctrl_controla),
        .ControlB(ctrl_controlb),
        .ALUOut(ctrl_aluout),
        .DivMult(ctrl_divmult),
        .Hi(ctrl_hi),
        .Lo(ctrl_lo),
        .PCWriteCondBEQ(ctrl_PCWriteCondBEQ),
        .PCWriteCondBNE(ctrl_pcwritecondbne),
        .IorD(ctrl_iord),
        .ContOrExcep(ctrl_contorexcep),
        .RegDst(ctrl_regdst),
        .ALUSrcA(ctrl_alusrca),
        .ALUSrcB(ctrl_alusrcb),
        .PCSource(ctrl_pcsource),
        .ShamtSource(ctrl_shamtsource),
        .MemToReg(ctrl_memtoreg),
        .ShiftFuncSrc(ctrl_shiftfuncsrc),
        .SelectByteSrc(ctrl_selectbytesrc),
        .SelectByte(ctrl_selectbyte)
        //.rst_out // ! completar aqui!
    );
    
endmodule