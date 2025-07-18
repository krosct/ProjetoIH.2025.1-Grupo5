module Mux_muxshamtsource(
    input wire ctrl,
    input wire [15:0] o0,
    input wire [31:0] o1,
    output wire [4:0] out
);

assign out = (ctrl == 1'b1) ? o1[4:0] : o0[10:6];

endmodule