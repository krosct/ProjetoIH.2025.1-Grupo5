module Mux_iord (
input wire[2:0]IorD,
input wire[31:0] Data_0,
input wire[31:0] Data_1,
output wire[31:0] Data_Out

);

wire [31:0] A1;
wire [31:0] A2;
wire [31:0] A3;
wire [31:0] A4;
wire [31:0] A5;
assign A1 = (IorD == 3'b100) ? 32'd255 : 32'b0; // Operando 2 placeholder
assign A2 = (IorD == 3'b011) ? 32'd255 : A1;
assign A3 = (IorD == 3'b010) ? 32'd254 : A2;
assign A4 = (IorD == 3'b010) ? 32'd253 : A3;
assign A5 = (IorD == 3'b001) ? Data_1 : A4;
assign Data_Out = (IorD == 3'b000) ? Data_0 : A5;
endmodule