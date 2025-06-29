module Mux_1bit(
    input wire ctrl,
    input wire [31:0] o0,
    input wire [31:0] o1,
    output wire [31:0] out
);

assign out = (ctrl == 1'b1) ? o1 : o0;

endmodule