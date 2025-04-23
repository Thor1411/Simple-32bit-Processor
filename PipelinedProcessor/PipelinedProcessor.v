module PipelinedProcessor (
    input clk,
    input reset,
    output [31:0] result,
    output [31:0] instruction
);
    // Pipeline registers between stages
    reg [31:0] IF_ID_instruction, IF_ID_pc;
    reg [31:0] ID_EX_reg1, ID_EX_reg2, ID_EX_immediate, ID_EX_pc;
    reg [2:0]  ID_EX_alu_op;
    reg        ID_EX_use_immediate, ID_EX_write_enable;
    reg [4:0]  ID_EX_write_addr;

    reg [31:0] EX_MEM_alu_result, EX_MEM_reg2;
    reg        EX_MEM_write_enable;
    reg [4:0]  EX_MEM_write_addr;

    reg [31:0] MEM_WB_result;
    reg        MEM_WB_write_enable;
    reg [4:0]  MEM_WB_write_addr;

    // IF Stage: Fetch Instruction
    wire [31:0] pc, next_pc, fetched_instruction;
    reg [31:0] pc_reg;
    assign next_pc = (reset) ? 0 : pc_reg + 4;
    assign pc = pc_reg;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_reg <= 0;
        else
            pc_reg <= next_pc;
    end

    Memory instruction_memory (
        .pc(pc),
        .instruction(fetched_instruction)
    );

    always @(posedge clk) begin
        IF_ID_instruction <= fetched_instruction;
        IF_ID_pc <= pc;
    end

    // ID Stage: Decode Instruction
    wire [31:0] reg_out1, reg_out2;
    wire [31:0] immediate_value;
    wire [2:0] alu_op;
    wire use_immediate, write_enable;
    wire [4:0] read_addr1, read_addr2, write_addr;

    assign alu_op = IF_ID_instruction[31:29];
    assign use_immediate = IF_ID_instruction[28];
    assign write_enable = (alu_op != 3'b110 && alu_op != 3'b111);
    assign immediate_value = {{15{IF_ID_instruction[17]}}, IF_ID_instruction[17:0]};
    assign read_addr1 = IF_ID_instruction[22:18];
    assign read_addr2 = IF_ID_instruction[17:13];
    assign write_addr = IF_ID_instruction[27:23];

    RegisterFile reg_file (
        .clk(clk),
        .write_addr(MEM_WB_write_addr),
        .write_data(MEM_WB_result),
        .write_enable(MEM_WB_write_enable),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .read_data1(reg_out1),
        .read_data2(reg_out2)
    );

    always @(posedge clk) begin
        ID_EX_reg1 <= reg_out1;
        ID_EX_reg2 <= reg_out2;
        ID_EX_immediate <= immediate_value;
        ID_EX_alu_op <= alu_op;
        ID_EX_use_immediate <= use_immediate;
        ID_EX_write_enable <= write_enable;
        ID_EX_write_addr <= write_addr;
        ID_EX_pc <= IF_ID_pc;
    end

    // EX Stage: ALU Operations
    wire [31:0] alu_result, alu_operand2;

    assign alu_operand2 = ID_EX_use_immediate ? ID_EX_immediate : ID_EX_reg2;

    ALU alu (
        .A(ID_EX_reg1),
        .B(alu_operand2),
        .ALUOp({ID_EX_alu_op, ID_EX_use_immediate}),
        .Result(alu_result)
    );

    always @(posedge clk) begin
        EX_MEM_alu_result <= alu_result;
        EX_MEM_reg2 <= ID_EX_reg2;
        EX_MEM_write_enable <= ID_EX_write_enable;
        EX_MEM_write_addr <= ID_EX_write_addr;
    end

    // MEM Stage: Memory Access
    always @(posedge clk) begin
        MEM_WB_result <= EX_MEM_alu_result; // No memory instructions in this pipeline
        MEM_WB_write_enable <= EX_MEM_write_enable;
        MEM_WB_write_addr <= EX_MEM_write_addr;
    end

    // WB Stage: Write Back
    assign result = MEM_WB_result;

    // Output the current instruction for debugging
    assign instruction = IF_ID_instruction;

endmodule


module TwosComplement (
    input [31:0] A,          // Input number
    output [31:0] result     // 2's complement result
);
    assign result = ~A + 1;  // Invert the bits and add 1
endmodule


module ALU (
    input [31:0] A,          
    input [31:0] B,          
    input [3:0] ALUOp,       
    output reg [31:0] Result,
    output reg Zero          
);
    wire [31:0] sum;		// 32-bit sum from ripple carry adder
    wire [31:0] sub;
    wire carry_out;          // Final carry-out from ripple carry adder
    wire [63:0] product;     // 64-bit product from Booth's multiplier
    wire [31:0] sub_result;  // Result of the subtraction for ALU

    // Instantiate the Ripple Carry Adder
    RippleCarryAdder rca (
        .A(A), 
        .B(B), 
        .Cin(0),         // No carry-in for initial addition
        .Sum(sum), 
        .Cout(carry_out)
    );

    // Instantiate the Booth's Multiplier
    BoothsMultiplier multiplier (
        .A(A), 
        .B(B), 
        .Product(product)
    );

    TwosComplement twos_complement (
        .A(B), 
        .result(sub_result)
    );

    RippleCarryAdder rba (
        .A(A), 
        .B(sub_result), 
        .Cin(0),         // No carry-in for initial addition
        .Sum(sub), 
        .Cout(carry_out)
    );

    always @(*) begin
        case (ALUOp)
            4'b0000: Result = sum;
            4'b0001: Result = sum;
            4'b0010: Result = sub;
            4'b0011: Result = sub;
            4'b0100: Result = A & B;
            4'b0101: Result = A & B;
          	4'b0111: Result = A | B;
          	4'b0110: Result = A | B;
            4'b1000: Result = product[31:0];
            4'b1011: Result = B;
            default: Result = 0;
        endcase
        Zero = (Result == 0);       
    end
endmodule

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

module Memory (
    input [31:0] pc,
    output reg [31:0] instruction
);
  reg [31:0] memory [0:255];  // Memory with 256 locations

    initial begin
       // Sample instructions for different ALU operations and jumps
        memory[0]  = {3'b000, 1'b0, 5'b00001, 5'b00010, 5'b00011, 13'b0};      // ADD r1, r2, r3
      	memory[1]  = {3'b000, 1'b1, 5'b00001, 5'b00010, 18'b0000000000000111};  // ADD r1, r2, #7  (immediate)
        memory[2]  = {3'b001, 1'b0, 5'b00100, 5'b00010, 5'b00011, 13'b0};      // SUB r4, r2, r3
        memory[3]  = {3'b001, 1'b1, 5'b00100, 5'b00010, 18'b0000000000000010};  // SUB r4, r2, #2 (immediate)
        memory[4]  = {3'b010, 1'b0, 5'b00101, 5'b00010, 5'b00011, 13'b0};      // AND r5, r2, r3
        memory[5]  = {3'b011, 1'b0, 5'b00110, 5'b00010, 5'b00011, 13'b0};      // OR r6, r2, r3
        memory[6]  = {3'b100, 1'b0, 5'b00111, 5'b00010, 5'b00011, 13'b0};      //  MUL r7, r2, r3
        memory[7]  = {3'b101, 1'b1, 5'b01000, 5'b00000, 18'b0000000000100010};  // MOV r8, #34 (immediate)
      	memory[8]  = {3'b000, 1'b0, 5'b00101, 5'b00100, 5'b00010, 13'b0};       // ADD r5, r4, r2
      	memory[9]  = {3'b000, 1'b1, 5'b00101, 5'b00001, 18'b0000000000001001};  // ADD r5, r1, #9 (immediate)
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


module RegisterFile (
    input clk,
    input [4:0] write_addr,
    input [31:0] write_data,
    input write_enable,
    input [4:0] read_addr1,
    input [4:0] read_addr2,
    output reg [31:0] read_data1,
    output reg [31:0] read_data2
);
    reg [31:0] registers [0:31];  // 32 registers

    initial begin
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
          registers[i] = 32'b101;  // Initialize registers
        end
    end

    always @(posedge clk) begin
        if (write_enable)
            registers[write_addr] <= write_data;  // Write data to register if enabled
    end

    always @(*) begin
        read_data1 = registers[read_addr1];  // Read from register file
        read_data2 = registers[read_addr2];
    end
endmodule


module InstructionFetch (
    input clk,
    input reset,
    input [31:0] next_address,
    output reg [31:0] pc
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 0;  // Reset PC to 0
        else
            pc <= next_address;  // Update PC with next address
    end
endmodule