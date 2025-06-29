module shiftleft16 (
     input  wire [31:0] di,
     output wire [31:0] do
);

    assign do = di << 16;

endmodule