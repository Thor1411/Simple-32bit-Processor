module RippleCarryAdder (
    input [31:0] A,           // First 32-bit input
    input [31:0] B,           // Second 32-bit input
    input Cin,                // Carry input
    output [31:0] Sum,        // 32-bit sum output
    output Cout               // Carry output
);

    wire [31:0] carry;  // Carry bits for each bit position
    wire [31:0] sum_internal; // Internal sum for each bit

    // First bit (Least significant bit) addition
    full_adder FA0 (
        .A(A[0]), 
        .B(B[0]), 
        .Cin(Cin), 
        .Sum(Sum[0]), 
        .Cout(carry[0])
    );

    // Generate the rest of the full adders using a for loop
    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin : adder_gen
            full_adder FA (
                .A(A[i]), 
                .B(B[i]), 
                .Cin(carry[i-1]), 
                .Sum(Sum[i]), 
                .Cout(carry[i])
            );
        end
    endgenerate

    // The final carry output is the carry from the most significant bit
    assign Cout = carry[31];

endmodule

module full_adder (
    input A,          // Single bit input A
    input B,          // Single bit input B
    input Cin,        // Carry input
    output Sum,       // Sum output
    output Cout       // Carry output
);

    assign Sum = A ^ B ^ Cin;    // Sum is the XOR of A, B, and Cin
    assign Cout = (A & B) | (Cin & (A ^ B));  // Carry is generated based on the bits' combinations

endmodule