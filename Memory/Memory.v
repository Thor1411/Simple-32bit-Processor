module Memory (
    input [31:0] pc,
    output reg [31:0] instruction
);
  reg [31:0] memory [0:255];  // Memory with 256 locations

    initial begin
       // Sample instructions for different ALU operations and jumps
			memory[0]  = {3'b000, 1'b0, 5'b00001, 5'b00010, 5'b00011, 13'b0};       // ADD r1, r2, r3
			memory[1]  = {3'b000, 1'b1, 5'b00001, 5'b00010, 18'b0000000000000111};  // ADD r1, r2, #7 (immediate)
			memory[2]  = {3'b001, 1'b0, 5'b00100, 5'b00010, 5'b00011, 13'b0};       // SUB r4, r2, r3
			memory[3]  = {3'b001, 1'b1, 5'b00100, 5'b00010, 18'b0000000000000010};  // SUB r4, r2, #2 (immediate)
			memory[4]  = {3'b010, 1'b0, 5'b00101, 5'b00010, 5'b00011, 13'b0};       // AND r5, r2, r3
			memory[5]  = {3'b011, 1'b0, 5'b00110, 5'b00010, 5'b00011, 13'b0};       // OR r6, r2, r3
			memory[6]  = {3'b100, 1'b0, 5'b00111, 5'b00010, 5'b00011, 13'b0};       //  MUL r7, r2, r3
			memory[7]  = {3'b101, 1'b1, 5'b01000, 5'b00000, 18'b0000000000100010};  // MOV r8, #34 (immediate)
            memory[8]  = {3'b000, 1'b0, 5'b00101, 5'b00100, 5'b00010, 13'b0};       // ADD r5, r4, r2
			memory[9] = {3'b000, 1'b1, 5'b00101, 5'b00001, 18'b0000000000001001};  // ADD r5, r1, #9 (immediate)
			memory[10] = {3'b001, 1'b0, 5'b00110, 5'b00111, 5'b00000, 13'b0};       // SUB r6, r7, r1
      	    memory[11] = {3'b001, 1'b1, 5'b00110, 5'b00010, 18'b0000000000000001};  // SUB r6, r2, #1 (immediate)
      		memory[12] = {3'b010, 1'b0, 5'b01000, 5'b00101, 5'b00011, 13'b0};       // AND r8, r5, r3
      		memory[13] = {3'b011, 1'b0, 5'b01001, 5'b00010, 5'b00011, 13'b0};       // OR r9, r2, r3
      		memory[14] = {3'b100, 1'b0, 5'b01010, 5'b00010, 5'b00100, 13'b0};       // MUL r10, r2, r4
      		memory[15] = {3'b101, 1'b1, 5'b01011, 5'b00001, 18'b0000000000001010};  // MOV r11, #10 (immediate)
    end
    always @(pc) begin
        instruction <= memory[pc >> 2];  // Fetch instruction, considering word-aligned addressing
    end
endmodule
