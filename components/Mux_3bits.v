module Mux_3bits(
    input wire [2:0] ctrl,
    input wire [31:0] o0,
    input wire [31:0] o1,
    input wire [31:0] o2,
    input wire [31:0] o3,
    input wire [31:0] o4,
    input wire [31:0] o5,
    input wire [31:0] o6,
    input wire [31:0] o7,
    output wire [31:0] out
);

assign out =    (ctrl == 3'b000) ? o0 :
                (ctrl == 3'b001) ? o1 :
                (ctrl == 3'b010) ? o2 :
                (ctrl == 3'b011) ? o3 :
                (ctrl == 3'b100) ? o4 :
                (ctrl == 3'b101) ? o5 :
                (ctrl == 3'b110) ? o6 :
                (ctrl == 3'b111) ? o7 :
                                   o0; 

endmodule