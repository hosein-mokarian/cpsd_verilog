module demuxN
  #(parameter N = 2)
  (
    input rstn,
    input en,
    input clk,
    input xin,
    input [(N / 2) - 1: 0] sel,
    output reg [N - 1 : 0] y
  );


  integer i;
  
  always @(*)
  begin
    if (!rstn)
    begin
      for (i = 0; i < N; i++)
        y[i] = 0;
    end
    else if (rstn && en)
    begin
      for (i = 0; i < N; i++)
        if (i == sel)
          y[i] = xin;
        else
          y[i] = 0;
    end
  end

endmodule