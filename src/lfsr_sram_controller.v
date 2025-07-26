module lfsr_sram_controller (
input wire clk,
input wire rst,
input wire [7:0] in, // in[0] = write_enable, in[4:1] = data_in[3:0]
output reg [7:0] out, // data read from SRAM
inout wire [7:0] io // optional debug output
);

// LFSR: 4-bit for 16-address space
reg [3:0] lfsr;
wire feedback = lfsr[3] ^ lfsr[2];  // taps at bit 4 and 3 (x⁴ + x³ + 1)

// SRAM: 16x8 memory
reg [7:0] mem [0:15];

// Control Signals
wire write_enable = in[0];
wire [3:0] data_in = in[4:1];
wire [3:0] address = lfsr;
wire [7:0] full_data_in = {4'b0000, data_in};

// LFSR update
always @(posedge clk or posedge rst) begin
    if (rst) begin
        lfsr <= 4'b0001;  // LFSR seed
    end else begin
        lfsr <= {lfsr[2:0], feedback};
    end
end

// SRAM Read/Write Logic
always @(posedge clk) begin
    if (write_enable) begin
        mem[address] <= full_data_in;
        out <= 8'h00;  // Output zero during write (optional)
    end else begin
        out <= mem[address];
    end
end

// Optional debug on io pins (can be removed or modified)
assign io = {4'b0000, address};  // show LFSR address on io[3:0]
endmodule
