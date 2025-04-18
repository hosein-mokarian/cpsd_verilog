module space_vector
  #(parameter DATA_WIDTH = 16,
    parameter d = 5
  )
  (
    input rstn,
    input en,
    input clk,
    input [DATA_WIDTH - 1 : 0] xin,
    input qrs,
    output [DATA_WIDTH - 1 : 0] vx,
    output [DATA_WIDTH - 1 : 0] vy
  );

  reg [DATA_WIDTH - 1 : 0] sr [d - 1 : 0];
  integer i;

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      for (i = 0; i < d; i++)
        sr[i] <= 0;
    end
    else if (rstn && en)
    begin
      sr[0] <= xin;
      for (i = 0; i < d - 1; i++)
        sr[i + 1] <= sr[i];
    end
  end

  assign vx = (rstn && en) ? sr[d - 1] : {DATA_WIDTH{1'b0}};
  assign vy = (rstn && en) ? sr[0] : {DATA_WIDTH{1'b0}};
  
endmodule