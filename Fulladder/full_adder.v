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