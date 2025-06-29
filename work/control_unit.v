module control_unit (
    input wire clk,
    input wire reset,
    // Flags ??
    input wire OverflowException, // Overflow
    input wire ng, // ?
    input wire Zero, // Resultado 0 da ULA
    input wire ZeroException, // Divisão por zero
    input wire eq,
    input wire gt,
    input wire lt,
    // Part of the instruction
    input wire [5:0] opcode,
    input wire [5:0] funct,
    // General
    output reg PCWrite,
    output reg EPCWrite,
    output reg [1:0] ALUOp,
    output reg MemRead,
    output reg MemWrite,
    output reg IRWrite,
    output reg RegWrite,
    output reg ControlA,
    output reg ControlB,
    output reg ALUOut,
    output reg DivMult,
    output reg Hi,
    output reg Lo,
    output reg PCWriteCondBEQ,
    output reg PCWriteCondBNE,
    // Mux
    output reg [2:0] IorD,
    output reg ContOrExcep,
    output reg [1:0]RegDst,
    output reg [1:0] ALUSrcA,
    output reg [2:0] ALUSrcB,
    output reg [1:0] PCSource,
    output reg ShamtSource,
    output reg[2:0] MemToReg,
    output reg [1:0] ShiftFuncSrc,
    output reg [1:0] SelectByteSrc,
    output reg SelectByte,
    // Controller for reset
    output reg rst_out
);

// Variables
reg [4:0] STATE;
reg [4:0] COUNTER;

// Machine States
parameter ST_READ_F_MEMORY = 5'd0;  // Estado inicial lê instrução da memória e soma PC = 4  INSTRUCTION FETCH
parameter ST_INTRUCTION_DECODE = 5'd1;  // Lê da memoria e escreve em IR INSTRUCION DECODE LÊ DA MEMORIA E 
parameter ST_ADD = 5'd2;
parameter ST_AND = 5'd3;
parameter ST_DIV = 5'd4;
parameter ST_MULT = 5'd5;
parameter ST_JR = 5'd6;
parameter ST_MFHI = 5'd7;
parameter ST_MFLO = 5'd8;
parameter ST_SLL = 5'd9;
parameter ST_SLT = 5'd10;
parameter ST_SRA = 5'd11;
parameter ST_SUB = 5'd12;
parameter ST_XCHG = 5'd13;
parameter ST_ADDI = 5'd14;
parameter ST_BEQ = 5'd15;
parameter ST_BNE = 5'd16;
parameter ST_SLLM = 5'd17;
parameter ST_LB = 5'd18;
parameter ST_LUI = 5'd19;
parameter ST_LW = 5'd20;
parameter ST_SB = 5'd21;
parameter ST_SW = 5'd22;
parameter ST_J = 5'd23;
parameter ST_JAL = 5'd24;
parameter ST_RESET = 5'd32; // Ultimo estado

// Parameters (Constants)
// Opcodes
parameter INST_R = 6'h0x0;
  // Functs
parameter ADD = 6'h0x20;
parameter AND = 6'h0x24;
parameter DIV = 6'h0x1a;
parameter MULT = 6'h0x18;
parameter JR = 6'h0x8;
parameter MFHI = 6'h0x10;
parameter MFLO = 6'h0x12;
parameter SLL = 6'h0x0;
parameter SLT = 6'h0x2a;
parameter SRA = 6'h0x3;
parameter SUB = 6'h0x22;
parameter XCHG = 6'h0x5;
// Tipo I
parameter ADDI = 6'h0x8;
parameter BEQ = 6'h0x4;
parameter BNE = 6'h0x5;
parameter SLLM = 6'h0x1;
parameter LB = 6'h0x20;
parameter LUI = 6'h0xf;
parameter LW = 6'h0x23;
parameter SB = 6'h0x28;
parameter SW = 6'h0x2b;
// TIPO J
parameter J = 6'h0x2;
parameter JAL = 6'h0x3;
initial begin
    rst_out = 1'b1;
end

always @(posedge clk) begin
    // TODO: Reset precisa ser revisado na nossa arquitetura
    if (reset == 1'b1) begin
        if (STATE != ST_RESET) begin
            STATE = ST_RESET;
            // Settings all signals
            PCWrite = 1'b0;
            EPCWrite = 1'b0;
            ALUOp = 2'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            IRWrite = 1'b0;
            RegWrite = 1'b0;
            ControlA = 1'b0;
            ControlB = 1'b0;
            ALUOut = 1'b0;
            DivMult = 1'b0;
            Hi = 1'b0;
            Lo = 1'b0;
            PCWriteCondBEQ = 1'b0;
            PCWriteCondBNE = 1'b0;
            // Mux
            IorD = 3'b0;
            ContOrExcep = 1'b0;
            RegDst = 2'b0;
            ALUSrcA = 2'b0;
            ALUSrcB = 3'b0;
            PCSource = 2'b0;
            ShamtSource = 1'b0;
            MemToReg = 3'b0;
            ShiftFuncSrc = 2'b0;
            SelectByteSrc = 2'b0;
            SelectByte = 1'b0;
            // Controller for reset
            rst_out = 1'b1; /// Comentário indicando o que foi alterado
            // Setting counter for next operation
            COUNTER = 5'd0;
        end
        else begin
            STATE = ST_READ_F_MEMORY;
            // Settings all signals (All Os)
            PCWrite = 1'b0;
            EPCWrite = 1'b0;
            ALUOp = 2'b0;   ///
            MemRead = 1'b1;     ///
            MemWrite = 1'b0;
            IRWrite = 1'b0;
            RegWrite = 1'b0;
            ControlA = 1'b0;
            ControlB = 1'b0;
            ALUOut = 1'b0;
            DivMult = 1'b0;
            Hi = 1'b0;
            Lo = 1'b0;
            PCWriteCondBEQ = 1'b0;
            PCWriteCondBNE = 1'b0;
            // Mux
            IorD = 3'b000;    ///
            ContOrExcep = 1'b0;
            RegDst = 2'b0;
            ALUSrcA = 2'b01;    ///
            ALUSrcB = 3'b001;    ///
            PCSource = 2'b0;
            ShamtSource = 1'b0;
            MemToReg = 3'b0;
            ShiftFuncSrc = 2'b0;
            SelectByteSrc = 2'b0;
            SelectByte = 1'b0;
            // Controller for reset
            rst_out = 1'b0; ///
            // Setting counter for next operation
            COUNTER = 5'd0;
        end
    end
    else begin
        case (STATE)
            ST_READ_F_MEMORY:
                if (COUNTER == 5'd0 || COUNTER == 5'd1 || COUNTER == 5'd2) begin
                    STATE = ST_READ_F_MEMORY;
                    // Settings all signals (All Os)
                    PCWrite = 1'b1;    /// PC + 4
                    EPCWrite = 1'b0;
                    ALUOp = 2'b0;   /// Soma
                    MemRead = 1'b1;     ///
                    MemWrite = 1'b0;
                    IRWrite = 1'b1;
                    RegWrite = 1'b0;
                    ControlA = 1'b0;
                    ControlB = 1'b0;
                    ALUOut = 1'b0;
                    DivMult = 1'b0;
                    Hi = 1'b0;
                    Lo = 1'b0;
                    PCWriteCondBEQ = 1'b0;
                    PCWriteCondBNE = 1'b0;
                    // Mux
                    IorD = 3'b000;    /// Busca nova instrução
                    ContOrExcep = 1'b0;
                    RegDst = 2'b0;
                    ALUSrcA = 2'b01;    /// PC
                    ALUSrcB = 3'b001;    /// 4
                    PCSource = 2'b0;
                    ShamtSource = 1'b0;
                    MemToReg = 3'b0;
                    ShiftFuncSrc = 2'b0;
                    SelectByteSrc = 2'b0;
                    SelectByte = 1'b0;
                    // Controller for reset
                    rst_out = 1'b0; ///
                    // Setting counter for next operation
                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 5'd3) begin
                    STATE = ST_INTRUCTION_DECODE;
                    // Settings all signals (All Os)
                    PCWrite = 1'b1;    ///
                    EPCWrite = 1'b0;
                    ALUOp = 2'b0;   /// Soma
                    MemRead = 1'b1;     ///
                    MemWrite = 1'b0;
                    IRWrite = 1'b1;    ///
                    RegWrite = 1'b0;
                    ControlA = 1'b0;
                    ControlB = 1'b0;
                    ALUOut = 1'b0;
                    DivMult = 1'b0;
                    Hi = 1'b0;
                    Lo = 1'b0;
                    PCWriteCondBEQ = 1'b0;
                    PCWriteCondBNE = 1'b0;
                    // Mux
                    IorD = 3'b000;    /// Busca nova instrução
                    ContOrExcep = 1'b0;
                    RegDst = 2'b0;
                    ALUSrcA = 2'b01;
                    ALUSrcB = 3'b001;
                    PCSource = 2'b0;
                    ShamtSource = 1'b0;
                    MemToReg = 3'b0;
                    ShiftFuncSrc = 2'b0;
                    SelectByteSrc = 2'b0;
                    SelectByte = 1'b0;
                    // Controller for reset
                    rst_out = 1'b0; ///
                    // Setting counter for next operation
                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 5'd4) begin                 
                    STATE = ST_INTRUCTION_DECODE;
                    // Settings all signals (All Os)
                    PCWrite = 1'b0;    /// PC já escrito
                    EPCWrite = 1'b0;
                    ALUOp = 2'b0;   /// Soma
                    MemRead = 1'b1;     ///
                    MemWrite = 1'b0;
                    IRWrite = 1'b0;    /// 
                    RegWrite = 1'b0;
                    ControlA = 1'b1;    /// Escreve em A
                    ControlB = 1'b1;    /// Escreve em B
                    ALUOut = 1'b0;
                    DivMult = 1'b0;
                    Hi = 1'b0;
                    Lo = 1'b0;
                    PCWriteCondBEQ = 1'b0;
                    PCWriteCondBNE = 1'b0;
                    // Mux
                    IorD = 3'b000;    /// Busca nova instrução
                    ContOrExcep = 1'b0;
                    RegDst = 2'b0;
                    ALUSrcA = 2'b01;    ///
                    ALUSrcB = 3'b100;  ///
                    PCSource = 2'b0;
                    ShamtSource = 1'b0;
                    MemToReg = 3'b0;
                    ShiftFuncSrc = 2'b0;
                    SelectByteSrc = 2'b0;
                    SelectByte = 1'b0;
                    // Controller for reset
                    rst_out = 1'b0; ///
                    // Setting counter for next operation
                    COUNTER = COUNTER + 1;
                end
                else if (COUNTER == 5'd5) begin
                    case (opcode) // Se for tipo R; outro Case para funct
                        INST_R:
                            case (funct)
                                ADD: begin
                                    STATE = ST_ADD;
                                end
                                AND: begin
                                    STATE = ST_AND;
                                end
                                DIV: begin
                                    STATE = ST_DIV;
                                end
                                MULT: begin
                                    STATE = ST_MULT;
                                end
                                JR: begin
                                    STATE = ST_JR;
                                end
                                MFHI: begin
                                    STATE = ST_MFHI;
                                end
                                MFLO: begin
                                    STATE = ST_MFLO;
                                end
                                SLL: begin
                                    STATE = ST_SLL;
                                end
                                SLT: begin
                                    STATE = ST_SLT;
                                end
                                SRA: begin
                                    STATE = ST_SRA;
                                end
                                SUB: begin
                                    STATE = ST_SUB;
                                end
                                SUB: begin
                                    STATE = ST_XCHG;
                                end
                            endcase
                        ADDI: begin
                            STATE = ST_ADDI;
                        end
                        BEQ: begin
                            STATE = ST_BEQ;
                        end
                        BNE: begin
                            STATE = ST_BNE;
                        end
                        SLLM: begin
                            STATE = ST_SLLM;
                        end
                        LB: begin
                            STATE = ST_LB;
                        end
                        LUI: begin
                            STATE = ST_LUI;
                        end
                        LW: begin
                            STATE = ST_LW;
                        end
                        SB: begin
                            STATE = ST_SB;
                        end
                        SW: begin
                            STATE = ST_SW;
                        end
                        J: begin
                            STATE = ST_J;
                        end
                        JAL: begin
                            STATE = ST_JAL;
                        end
                        // TODO: Falta Default
                    endcase
                    // Settings all signals to 0
                    PCWrite = 1'b0;
                    EPCWrite = 1'b0;
                    ALUOp = 2'b0;
                    MemRead = 1'b0;
                    MemWrite = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    ControlA = 1'b0;
                    ControlB = 1'b0;
                    ALUOut = 1'b0;
                    DivMult = 1'b0;
                    Hi = 1'b0;
                    Lo = 1'b0;
                    PCWriteCondBEQ = 1'b0;
                    PCWriteCondBNE = 1'b0;
                    // Mux
                    IorD = 3'b0;
                    ContOrExcep = 1'b0;
                    RegDst = 2'b0;
                    ALUSrcA = 2'b0;
                    ALUSrcB = 3'b0;
                    PCSource = 2'b0;
                    ShamtSource = 1'b0;
                    MemToReg = 3'b0;
                    ShiftFuncSrc = 2'b0;
                    SelectByteSrc = 2'b0;
                    SelectByte = 1'b0;
                    // Controller for reset
                    rst_out = 1'b0; /// Comentário indicando o que foi alterado
                    // Setting counter for next operation
                    COUNTER = 5'd0;  // We'll start as from 0 on non-commom states
                end
            ST_ADD: begin
                if (COUNTER == 5'd0) begin

                end
            end
        endcase
    end
end

endmodule