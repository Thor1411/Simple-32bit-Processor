module BoothsMultiplier (
    input [31:0] A,               // Multiplicand (input operand)
    input [31:0] B,               // Multiplier (input operand)
    output reg [63:0] Product     // 64-bit Product (output)
);
    reg [63:0] accumulator;       // 64-bit accumulator and result register
    reg [32:0] booth_reg;         // 33-bit register to store B and an additional bit
    reg [31:0] multiplicand;      // Holds the value of A (multiplicand)
    integer i;

    always @(*) begin
        // Initialize registers
        accumulator = 64'b0;         // Accumulator starts at zero
        multiplicand = A;            // Load multiplicand
        booth_reg = {B, 1'b0};       // Concatenate B and extra 0 bit for Booth's check

        // Booth's Algorithm Loop (32 iterations for 32-bit multiplication)
        for (i = 0; i < 32; i = i + 1) begin
            case (booth_reg[1:0])
                2'b01: accumulator = accumulator + {multiplicand, 32'b0};  // Add multiplicand for '01'
                2'b10: accumulator = accumulator - {multiplicand, 32'b0};  // Subtract multiplicand for '10'
                default: ; // No operation for 00 or 11
            endcase

            // Arithmetic right shift of {accumulator, booth_reg} to propagate sign
            {accumulator, booth_reg} = {accumulator, booth_reg} >>> 1;
        end

        // Assign the final product
        Product = accumulator;
    end
endmodule
