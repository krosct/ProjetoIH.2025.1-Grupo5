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
    // General
    output reg PCWrite,
    output reg EPCWrite,
    output reg ALUOp,
    output reg [2:0] IorD,
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
    // Mux
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
reg [2:0] state;
reg [2:0] COUNTER;

// Machine States
parameter ST_READ_F_MEMORY = 5'd0;

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
    //
end

always @(posedge clk) begin
    //
end

endmodule