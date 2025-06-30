module alu_control (
    input wire [1:0] ctrl,
    input wire [5:0] o0,
    output reg [2:0] out
);

    // Functs
    parameter ADD = 6'h0x20;
    parameter AND = 6'h0x24;
    parameter JR = 6'h0x8;
    parameter SLT = 6'h0x2a;
    parameter SUB = 6'h0x22;
    parameter XCHG = 6'h0x5;

    always @(ctrl) begin
        if (ctrl == 2'b00) begin
            out = 3'b001;
        end
        else if (ctrl == 2'b01) begin
            out = 3'b010;
        end
        else if (ctrl == 2'b10) begin
            case (o0)
                ADD: begin
                    out = 3'b001;
                end
                AND: begin
                    out = 3'b011;
                end
                SLT: begin
                    out = 3'b111;
                end
                JR: begin
                    out = 3'b000;
                end
                XCHG: begin
                    out = 3'b000;
                end
                SUB: begin
                    out = 3'b010;
                end
                Default: begin
                    out = 3'b000;
                end
    end

endmodule