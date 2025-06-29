module ShiftLeft2bottom (
     input  wire [31:0] di,
     output wire [31:0] do
);

    assign do = di << 2;

endmodule