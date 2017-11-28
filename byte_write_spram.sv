module byte_write_spram #(
  parameter ADDR_DEPTH = 32,
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input  logic clk,
  input  logic mem_if_write,
  input  logic [ADDR_WIDTH-1:0] mem_if_address,
  input  logic [DATA_WIDTH-1:0] mem_if_write_data,
  input  logic [DATA_WIDTH/8-1:0] mem_if_write_strb,
  output logic [DATA_WIDTH-1:0] mem_if_read_data
);
  
  localparam ADDR_LSB = $clog2(DATA_WIDTH/8);
  localparam ADDR_MSB = $clog2(ADDR_DEPTH)+ADDR_LSB;
  
  logic [DATA_WIDTH/8-1:0][7:0] mem [ADDR_DEPTH];
  
  genvar i;
  generate for (i=0; i<DATA_WIDTH/8; i++) begin : write_byte
  always_ff @(posedge clk) begin
    if (mem_if_write) begin
      if (mem_if_write_strb[i]) begin
        mem[mem_if_address[ADDR_MSB-1:ADDR_LSB]][i] <= mem_if_write_data[8*i+:8];
      end
    end
  end
  end endgenerate
  
  always_ff @(posedge clk) begin
    mem_if_read_data <= mem[mem_if_address[ADDR_MSB-1:ADDR_LSB]];
  end
  
endmodule
