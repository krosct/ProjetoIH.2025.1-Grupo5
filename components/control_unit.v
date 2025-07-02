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
    output reg MDR1,
    output reg MDR2,
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
    output reg SelectByte
);

    // Variables
    reg [4:0] STATE;
    reg [4:0] COUNTER;

    // Machine States
    parameter ST_READ_F_MEMORY = 5'd0;  // Estado inicial lê instrução da memória e soma PC = 4  INSTRUCTION FETCH
    parameter ST_INTRUCTION_DECODE = 5'd1;  // Lê da memoria e escreve em IR INSTRUCION DECODE LÊ DA MEMORIA E DECODIFICA
    parameter ST_ADD_SUB_AND = 5'd2;
    parameter ST_DIV = 5'd4;
    parameter ST_MULT = 5'd5;
    parameter ST_JR = 5'd6;
    parameter ST_MFHI = 5'd7;
    parameter ST_MFLO = 5'd8;
    parameter ST_SLL_SRA = 5'd9;
    parameter ST_SLT = 5'd10;
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
    parameter ST_RESET = 5'd31;

    // Parameters (Constants)
    // Opcodes
    parameter INST_R = 6'h0;
    // Functs
    parameter ADD = 6'h20;
    parameter AND = 6'h24;
    parameter DIV = 6'h1a;
    parameter MULT = 6'h18;
    parameter JR = 6'h8;
    parameter MFHI = 6'h10;
    parameter MFLO = 6'h12;
    parameter SLL = 6'h0;
    parameter SLT = 6'h2a;
    parameter SRA = 6'h3;
    parameter SUB = 6'h22;
    parameter XCHG = 6'h5;
    // Tipo I
    parameter ADDI = 6'h8;
    parameter BEQ = 6'h4;
    parameter BNE = 6'h5;
    parameter SLLM = 6'h1;
    parameter LB = 6'h20;
    parameter LUI = 6'hf;
    parameter LW = 6'h23;
    parameter SB = 6'h28;
    parameter SW = 6'h2b;
    // TIPO J
    parameter J = 6'h2;
    parameter JAL = 6'h3;

    reg resett;
    initial resett = 1'b1;

    always @(posedge clk) begin
        // Settings all signals
        PCWrite = 1'b0;
        EPCWrite = 1'b0;
        ALUOp = 2'b0;
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
        if (resett == 1'b1) begin
            if (STATE != ST_RESET) begin
                STATE = ST_RESET;
                // Settings all signals
                resett = 1'b1;
                COUNTER = 5'd0;
            end
            else begin
                STATE = ST_READ_F_MEMORY;
                // Settings all signals
                PCWrite = 1'b1;
                IRWrite = 1'b1;
                ALUSrcA = 2'b01;
                ALUSrcB = 3'b001;
                resett = 1'b0;
                COUNTER = COUNTER + 1;
            end
        end
        else begin
            case (STATE)
                ST_READ_F_MEMORY:
                    if (COUNTER == 5'd1) begin
                        STATE = ST_INTRUCTION_DECODE;
                        // Settings all signals
                        ControlA = 1'b1;
                        ControlB = 1'b1;
                        ALUSrcA = 2'b1;
                        ALUSrcB = 3'b100;
                        COUNTER = COUNTER + 1;
                    end
                ST_INTRUCTION_DECODE:
                    if (COUNTER == 5'd2) begin
                        case (opcode)
                            INST_R:
                                case (funct)
                                    ADD: begin
                                        STATE = ST_ADD_SUB_AND;
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
                                        STATE = ST_SLL_SRA;
                                    end
                                    SLT: begin
                                        STATE = ST_SLT;
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
                            default: begin
                                resett = 1'b1;
                                // STATE = ST_RESET;
                            end
                        endcase
                        COUNTER = COUNTER + 1;
                    end

                ST_ADD_SUB_AND: begin
                    if (COUNTER == 5'd4) begin
                        ALUOp = 2'b10;
                        ALUOut = 1'b1;
                        RegDst = 2'b01;
                        ALUSrcA = 2'b10;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd5) begin
                        MemToReg = 3'b110;
                        SelectByteSrc = 2'b10;
                        RegWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end

                ST_ADDI: begin
                    if (COUNTER == 5'd4) begin
                        ALUSrcA = 2'b10;
                        ALUSrcB = 3'b010;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd5) begin
                        RegWrite = 1'b1;
                        MemToReg = 3'b110;
                        SelectByteSrc = 2'b10;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end

                ST_DIV: begin
                    if (COUNTER == 5'd4) begin
                        DivMult = 0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd38) begin
                        Hi = 1;
                        Lo = 1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                    else
                    begin
                        COUNTER = COUNTER + 1;
                    end
                end

                ST_MFLO: begin
                    if (COUNTER == 5'd4) begin
                        MemToReg = 3'b011;
                        RegDst = 2'b01;
                        RegWrite = 1'b1;
                        SelectByteSrc = 2'b10;
                        resett = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                end

                ST_MFHI: begin
                    if (COUNTER == 5'd4) begin
                        MemToReg = 3'b100;
                        SelectByteSrc = 2'b10;
                        RegDst = 2'b01;
                        RegWrite = 1'b1;
                        resett = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                end

                ST_LB: begin
                    if (COUNTER == 5'd4) begin
                        ALUSrcA = 2'b10;
                        ALUSrcB = 3'b010;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd5) begin
                        IorD = 3'b001;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd8) begin
                        MDR1 = 1'b1;
                        SelectByteSrc = 2'10;
                        SelectByte = 1'b1;
                        RegWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                    begin
                        COUNTER = COUNTER + 1;
                    end
                end

                ST_LW: begin
                    if (COUNTER == 5'd4) begin
                        ALUSrcA = 2'b10;
                        ALUSrcB = 3'b010;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd5) begin
                        IorD = 3'b001;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd8) begin
                        MDR1 = 1'b1;
                        SelectByteSrc = 2'10;
                        RegWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                    else
                    begin
                        COUNTER = COUNTER + 1;
                    end
                end

                ST_LUI: begin
                    if (COUNTER == 5'd4) begin
                        ALUSrcB = 3'b011;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd5) begin
                        MemToReg = 3'b110;
                        SelectByteSrc = 2'b10;
                        RegWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end

                ST_SB: begin
                    if (COUNTER == 5'd4) begin
                        ALUSrcA = 2'b10;
                        ALUSrcB = 3'b010;
                        SelectByte = 1'b1;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd5) begin
                        IorD = 3'b001;
                        MemWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end

                ST_SW: begin
                    if (COUNTER == 5'd4) begin
                        ALUSrcA = 2'b10;
                        ALUSrcB = 3'b010;
                        SelectByteSrc = 2'b01;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd5) begin
                        IorD = 3'b001;
                        MemWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end

                ST_JR: begin
                    if (COUNTER == 5'd4) begin
                        ALUSrcA = 2'b10;
                        ALUSrcB = 3'b010;
                        ALUOp = 2'b10;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd5) begin
                        PCSource = 2'b10;
                        PCWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end

                ST_J: begin
                    if (COUNTER == 5'd4) begin
                        PCSource = 2'b10;
                        PCWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end

                ST_JAL: begin
                    if (COUNTER == 5'd4) begin
                        RegDst = 2'b11;
                        RegWrite = 1'b1;
                        PCSource = 2'b10;
                        PCWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end

                ST_SLL_SRA: begin
                    if (COUNTER == 5'd4) begin
                        ShiftFuncSrc = 2'b01;
                        RegDst = 2'01;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd6) begin
                        MemToReg = 3'b010;
                        SelectByteSrc = 2'b10;
                        RegWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                    else
                    begin
                        COUNTER = COUNTER + 1;
                    end
                end

                ST_BEQ: begin
                    if (COUNTER == 5'd4) begin
                        PCSource = 2'b01;
                        ALUSrcA = 2'b10;
                        ALUOp = 2'b01;
                        PCWriteCondBEQ = 1'b1;
                        PCWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end

                ST_BNE: begin
                    if (COUNTER == 5'd4) begin
                        PCSource = 2'b01;
                        ALUSrcA = 2'b10;
                        ALUOp = 2'b01;
                        PCWriteCondBNE = 1'b1;
                        PCWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end

                ST_SLT: begin
                    if (COUNTER == 5'd4) begin
                        RegDst = 2'b01;
                        ALUSrcA = 2'b10;
                        ALUOp = 2'b10;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd5) begin
                        MemToReg = 3'b110;
                        SelectByteSrc = 2'b10;
                        RegWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end

                ST_SLLM: begin
                    if (COUNTER == 5'd4) begin
                        ShiftFuncSrc = 2'b01;
                        ALUSrcA = 2'b10;
                        ALUSrcB = 3'b010;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd5) begin
                        IorD = 3'b001;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd6) begin
                        MDR1 = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd7) begin
                        ShamtSource = 1'b1;
                        ShiftFuncSrc = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd8) begin
                        ShamtSource = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd9) begin
                        MemToReg = 3'b010;
                        SelectByteSrc = 2'10;
                        RegWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                end
                
                ST_XCHG: begin
                    if (COUNTER == 5'd4) begin
                        ALUSrcA = 2'b10;
                        ALUOp = 2'b10;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd5) begin
                        IorD = 3'b001;
                        MDR1 = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd8) begin
                        SelectByteSrc = 2'b10;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd9) begin
                        IorD = 3'b001;
                        MDR2 = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd12) begin
                        ALUSrcA = 2'b01;
                        ALUOp = 2'b10;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd13) begin
                        IorD = 3'b001;
                        MemWrite = 1'b1;
                        ALUOut = 1'b1;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 5'd14) begin
                        IorD = 3'b001;
                        MemToReg = 3'b001;
                        SelectByteSrc = 2'b10;
                        MemWrite = 1'b1;
                        COUNTER = COUNTER + 1;
                        resett = 1'b1;
                    end
                    else
                    begin
                        COUNTER = COUNTER + 1;
                    end
                end

            endcase
        end
    end

endmodule