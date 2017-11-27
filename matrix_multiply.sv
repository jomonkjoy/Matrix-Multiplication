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
  
  assign busy = state != IDLE;
  
  always_ff @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
    end else begin
      case (state)
        IDLE : begin
          if (start) begin
            state <= ACTIVE;
          end
        end
        ACTIVE : begin
          if (row_count_max && col_count_max) begin
            state <= DONE;
          end
        end
        DONE : begin
          if (row_count_r[2] >= mat_a_size[0]) begin
            state <= IDLE;
          end
        end
        default : state <= IDLE;
      endcase
    end
  end
  
  always_ff @(posedge clk) begin
    if (state == ACTIVE | state == DONE) begin
      load <= row_count_r[2] >= mat_a_size[0];
    end else begin
      load <= 1'b1;
    end
  end
  
  always_ff @(posedge clk) begin
    if (state == ACTIVE | state == DONE) begin
      mat_c_write <= row_count_r[2] >= mat_a_size[0];
    end else begin
      mat_c_write <= 1'b0;
    end
  end
  
  assign mat_a_address  = {'h0,col_count};
  assign mat_b_address  = {'h0,row_count};
  assign mat_c_address  = {'h0,col_count_r[3]};
  
  genvar i;
  generate for (i=0; i<SIZE_COUNT; i++) begin : gen
    multiply_acc #(DATA_WIDTH) mac_unit (
      .clk   (clk),
      .reset (reset),
      .load  (load),
      .a     (mat_a_read_data[row_count_r[0]]),
      .b     (mat_b_read_data[i]),
      .acc   (mat_c_write_data[i]),
    );
  end endgenerate
  
endmodule
