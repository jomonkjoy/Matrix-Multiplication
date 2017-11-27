module matrix_multiply #(
  parameter SIZE_COUNT = 8,
  parameter SIZE_WIDTH = $clog2(SIZE_COUNT),
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 16
) (
  input  logic                  clk,
  input  logic                  reset,
  input  logic                  start,
  input  logic [SIZE_WIDTH-1:0] mat_a_size[2],
  input  logic [SIZE_WIDTH-1:0] mat_b_size[2],
  output logic [ADDR_WIDTH-1:0] mat_a_addess,
  input  logic [DATA_WIDTH-1:0] mat_a_read_data[SIZE_COUNT],
  output logic [ADDR_WIDTH-1:0] mat_b_addess,
  input  logic [DATA_WIDTH-1:0] mat_b_read_data[SIZE_COUNT],
  output logic                  mat_c_write,
  output logic [ADDR_WIDTH-1:0] mat_c_addess,
  output logic [DATA_WIDTH-1:0] mat_c_write_data[SIZE_COUNT],
  output                        busy
);
  
  logic load;
  logic row_count_max;
  logic col_count_max;
  logic [SIZE_WIDTH-1:0] row_count;
  logic [SIZE_WIDTH-1:0] col_count;
  logic [SIZE_WIDTH-1:0] row_count_r[4];
  logic [SIZE_WIDTH-1:0] col_count_r[4];
  
  typedef enum {IDLE,ACTIVE,DONE} state_type;
  state_type state;
  
  assign row_count_max = row_count >= mat_a_size[0];
  assign col_count_max = col_count >= mat_a_size[1];
  
  always_ff @(posedge clk) begin
    row_count_r[0] <= row_count;
    row_count_r[1] <= row_count_r[0];
    row_count_r[2] <= row_count_r[1];
    row_count_r[3] <= row_count_r[2];
  end
  
  always_ff @(posedge clk) begin
    col_count_r[0] <= col_count;
    col_count_r[1] <= col_count_r[0];
    col_count_r[2] <= col_count_r[1];
    col_count_r[3] <= col_count_r[2];
  end
  
  always_ff @(posedge clk) begin
    if (state == IDLE) begin
      row_count <= {SIZE_WIDTH{1'b0}};
      col_count <= {SIZE_WIDTH{1'b0}};
    end else if (state == ACTIVE) begin
      if (row_count_max) begin
        row_count <= {SIZE_WIDTH{1'b0}};
        if (col_count_max) begin
          col_count <= {SIZE_WIDTH{1'b0}};
        end else begin
          col_count <= col_count + 1;
        end
      end else begin
        row_count <= row_count + 1;
      end
    end
  end
  
endmodule
