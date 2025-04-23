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