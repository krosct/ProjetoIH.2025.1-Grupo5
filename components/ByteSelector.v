module ByteSelector (
    input wire ctrl,
    input wire [31:0] o0,
    output wire [31:0] out
);

    // wire [7:0] selected_byte_8bits;
    // wire [1:0] byte_select;
    // assign byte_select = o0[1:0];

    // assign selected_byte_8bits = (byte_select == 2'b00) ? o0[7:0] :
    //                              (byte_select == 2'b01) ? o0[15:8] :
    //                              (byte_select == 2'b10) ? o0[23:16] :
    //                              (byte_select == 2'b11) ? o0[31:24] :
    //                                                       o0;

    assign out = (ctrl == 1'b0) ? o0 : {24'b0, o0[7:0]};

endmodule