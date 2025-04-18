module quantization
  #(parameter DATA_WIDTH = 16,
    parameter d = 5,
    parameter L = 6
  )
  (
    input rstn,
    input en,
    input clk,
    input signed [DATA_WIDTH - 1 : 0] M,
    input signed [DATA_WIDTH - 1 : 0] vx,
    input signed [DATA_WIDTH - 1 : 0] vy,
    output [DATA_WIDTH - 1 : 0] vqx,
    output [DATA_WIDTH - 1 : 0] vqy
  );

  wire signed [DATA_WIDTH - 1 : 0] xin_array [1 : 0];
  reg signed [DATA_WIDTH - 1 : 0] y_array [1 : 0];
  integer i;

  assign {xin_array[1], xin_array[0]} = {vx, vy};

  wire signed [DATA_WIDTH - 1 : 0] xin_array_0 = xin_array[0];
  wire signed [DATA_WIDTH - 1 : 0] xin_array_1 = xin_array[1];
  wire signed [DATA_WIDTH - 1 : 0] y_array_0 = y_array[0];
  wire signed [DATA_WIDTH - 1 : 0] y_array_1 = y_array[1];


  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      for (i = 0; i < 2; i++)
        y_array[i] <= 0;
    end
    else if (rstn && en)
    begin
      for (i = 0; i < 2; i++)
        y_array[i] <= ((xin_array[i] + M) * L + M) / (2 * (M + 1));
    end
  end

  assign vqx = (rstn && en) ? y_array[0] : {DATA_WIDTH{1'b0}};
  assign vqy = (rstn && en) ? y_array[1] : {DATA_WIDTH{1'b0}};

endmodule