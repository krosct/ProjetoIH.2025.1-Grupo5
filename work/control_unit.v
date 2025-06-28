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
    output reg ALUOut,
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
    output reg SelectByte
    // Controller for reset
    output reg reset_out

);
// Variables
reg [2:0] state;
reg [2:0] COUNTER;

// Parameters (Constants)

// Opcodes

always @(posedge clk) begin


end

endmodule