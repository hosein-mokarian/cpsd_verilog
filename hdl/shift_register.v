module shift_register
 #(parameter DATA_WIDTH = 16,
   parameter NB_OF_REGS = 1)
 (
  input rstn,
  input en,
  input clk,
  input [DATA_WIDTH - 1 : 0] xin,
  output [DATA_WIDTH - 1 : 0] y
 );

  reg [DATA_WIDTH - 1 : 0] sr [NB_OF_REGS - 1 : 0];
  integer i;

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      for (i = 0; i < NB_OF_REGS; i++)
        sr[i] <= 0;
    end
    else if(rstn && en)
    begin
      sr[0] <= xin;
      for (i = 0; i < NB_OF_REGS - 1; i++)
        sr[i + 1] <= sr[i];
    end
  end

  assign y = (rstn && en) ? sr[NB_OF_REGS - 1] : {DATA_WIDTH{1'b0}};

endmodule