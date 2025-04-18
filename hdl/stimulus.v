`timescale 1ns/1ps

module stimulus;

  parameter DATA_WIDTH = 16;

  // Inputs
	reg clk;
	reg rstn;
	reg en;
  reg start;
	reg signed [DATA_WIDTH - 1 : 0] xin;
  reg signed [DATA_WIDTH - 1 : 0] max;
  reg qrs;

	// Outputs
  wire normal;
  wire AF;
  wire VF;

	// Instantiate the Unit Under Test (UUT)
	cpsd_top uut (
		.clk(clk),
		.rstn(rstn),
		.en(en),
    .start(start),
		.xin(xin), 
    .max(max),
		.qrs(qrs),
    .normal(normal),
    .AF(AF),
    .VF(VF)
	);


  integer i = 1;
  integer fid_input_file, fid_output_file;
  integer counter = 0;
  integer period = 210 - 1;

  reg signed [DATA_WIDTH - 1 : 0] peakf;


  initial
  begin

    fid_input_file  = $fopen("ecg.txt", "r"); // ecg.txt // sample.txt
    fid_output_file = $fopen("output.dat", "w");
    
    if (fid_input_file == 0) 
      begin
        $display("Error: Failed to open file \n Exiting Simulation.");
        $finish;
      end

    xin = 0;
    clk = 0;
    rstn = 0;
    en = 0;
    start = 0;
    qrs = 0;

    #5 rstn = 1;
    #5 en = 1;
    start = 1;
    // max = 35;

    while (i > 0)
    begin
      @(negedge clk) 
      begin
        i = $fscanf(fid_input_file, "%d", xin);
      end
    end

    $fclose(fid_input_file);
    #1000; // 10000
    $display("Simulation ended normally");
    $finish;

  end


  initial 
		begin
			$dumpfile("cpsd_results.vcd");
			$dumpvars(0, stimulus);
		end


  always
		#1 clk = ~clk;
  
  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      counter <= 0;
      qrs <= 0;
    end
    else if (rstn && en)
    begin
      counter <= counter + 1;
      if (counter == period)
      begin
        counter <= 0;
        qrs <= 1;
      end
      else
        qrs <= 0;
    end
  end

  always @(posedge clk or negedge rstn)
  begin
    if (!rstn)
    begin
      max <= 100;
      peakf <= 0;
    end
    else if (rstn && en)
    begin
      if (qrs)
      begin
        max <= peakf;
        peakf <= -100;
      end
      
      if (xin > peakf)
        peakf <= xin;
    end
  end

endmodule