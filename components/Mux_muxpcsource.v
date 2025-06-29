module mux_muxpcsource(
    input wire [1:0] ctrl,
    input wire [31:0] o0,
    input wire [31:0] o1,
    input wire [31:0] o2,
    input wire [27:0] o3,
    output wire [31:0] out
);

assign out =    (ctrl == 2'b00) ? o0 :
                (ctrl == 2'b01) ? o1 :
                (ctrl == 2'b10) ? {o2[31:28], o3[27:0]} :
                (ctrl == 2'b11) ? o0 :
                                  o0; 

endmodule