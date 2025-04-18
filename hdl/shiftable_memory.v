module shiftable_memory
  #(parameter DATA_WIDTH = 16,
    parameter MEM_CAPACITY = 49
  )
  (
    input rstn,
    input en,
    input clk,
    input [DATA_WIDTH - 1 : 0] A,
    input shiftA,
    input [DATA_WIDTH - 1 : 0] WDB,
    input WEB,
    input clrB,
    output reg [DATA_WIDTH - 1 : 0] RDA,
    output reg [DATA_WIDTH - 1 : 0] RDB
  );

  reg [DATA_WIDTH - 1 : 0] memA [MEM_CAPACITY - 1 : 0];
  reg [DATA_WIDTH - 1 : 0] memB [MEM_CAPACITY - 1 : 0];
  integer i;


  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      for (i = 0; i < MEM_CAPACITY; i++)
      begin
        memA[i] <= 0;
        memB[i] <= 0;
      end
    end
    else if (rstn && en)
    begin
      if (shiftA)
      begin
        for (i = 0; i < MEM_CAPACITY; i++)
          memA[i] <= memB[i];
      end

      if (clrB)
      begin
        for (i = 0; i < MEM_CAPACITY; i++)
          memB[i] <= 0;
      end
      else if (WEB)
        memB[A] <= WDB;
    end
  end


  // always @(posedge clk or negedge rstn)
  // begin
  //   if (!rstn)
  //   begin
  //     for (i = 0; i < MEM_CAPACITY; i++)
  //       memA[i] <= 0;
  //   end
  //   else if (rstn && en)
  //   begin
  //     if (shiftA)
  //     begin
  //       for (i = 0; i < MEM_CAPACITY; i++)
  //         memA[i] <= memB[i];
  //     end
  //   end
  // end

  // always @(posedge clk or negedge rstn)
  // begin
  //   if (!rstn)
  //   begin
  //     for (i = 0; i < MEM_CAPACITY; i++)
  //       memB[i] <= 0;
  //   end
  //   else if (rstn && en)
  //   begin
  //     if (clrB)
  //     begin
  //       for (i = 0; i < MEM_CAPACITY; i++)
  //         memB[i] <= 0;
  //     end
  //     else if (WEB)
  //       memB[A] <= WDB;
  //   end
  // end

  always @(negedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      RDA <= 0;
      RDB <= 0;
    end
    else if (rstn && en)
    begin
      RDA <= memA[A];
      RDB <= memB[A];
    end
  end
  
endmodule