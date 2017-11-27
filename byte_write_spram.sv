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
  
  logic [7:0][DATA_WIDTH/8-1:0] mem [ADDR_DEPTH];
  
  logic mem_if_write_r;
  logic [ADDR_WIDTH-1:0] mem_if_address_r;
  logic [DATA_WIDTH-1:0] mem_if_write_data_r;
  logic [DATA_WIDTH/8-1:0] mem_if_write_strb_r;
  
  always_ff @(posedge clk) begin
    mem_if_write_r <= mem_if_write;
    mem_if_address_r <= mem_if_address;
    mem_if_write_data_r <= mem_if_write_data;
    mem_if_write_strb_r <= mem_if_write_strb;
  end
  integer i;
  always_ff @(posedge clk) begin
    if (mem_if_write_r) begin
      for (i=0; i<DATA_WIDTH/8; i++) begin : strb
        if (mem_if_write_strb_r[i]) begin
          mem[mem_if_address_r[ADDR_MSB:ADDR_LSB]][i] <= mem_if_write_data_r[8*i+:8];
        end else begin
          mem[mem_if_address_r[ADDR_MSB:ADDR_LSB]][i] <= mem_if_read_data[8*i+:8];
        end
      end
    end
  end
  
  always_ff @(posedge clk) begin
    mem_if_read_data <= mem[mem_if_address[ADDR_MSB:ADDR_LSB]];
  end
  
endmodule
