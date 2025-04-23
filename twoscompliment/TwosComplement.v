module TwosComplement (
    input [31:0] A,          // Input number
    output [31:0] result     // 2's complement result
);
    assign result = ~A + 1;  // Invert the bits and add 1
endmodule