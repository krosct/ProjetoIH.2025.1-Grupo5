module sign_extend (
    input  wire [15:0] di,
    output wire [31:0] do
);

    assign do = (di[15]) ? {{16{1'b1}}, di} : {{16{1'b0}}, di};

endmodule