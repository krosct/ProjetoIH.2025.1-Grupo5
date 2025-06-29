module mux_muxshiftfuncsrc(
    input wire [1:0] ctrl,
    input wire [31:0] o0,
    input wire [31:0] o1,
    input wire [31:0] o2,
    input wire [31:0] o3,
    output wire [2:0] out
);

assign out =    (ctrl == 2'b00) ? o0[2:0] :
                (ctrl == 2'b01) ? o1[2:0] :
                (ctrl == 2'b10) ? o2[2:0] :
                (ctrl == 2'b11) ? o3[2:0] :
                                  o0[2:0]; 

endmodule