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