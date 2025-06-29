module shiftleft2top (
     input  wire [4:0] di1,
     input  wire [4:0] di2,
     input  wire [15:0] di3,
     output wire [28:0] do
);

    assign do = di << 2;

endmodule