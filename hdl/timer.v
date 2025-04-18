module timer
  #(parameter PERIOD = 8000)
  (
    input rstn,
    input en,
    input clk,
    input start,
    output update_flag
  );

  reg [31 : 0] counter;

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      counter <= 0;
    end
    else if (rstn && en)
    begin
      if (start == 1)
        counter <= 1;
      
      if (counter != 0)
        counter <= counter + 1;
      
      if (counter == PERIOD)
        counter <= 0;
    end
  end

  assign update_flag = (rstn && en && (counter == PERIOD)) ? 1'b1 : 1'b0;

endmodule