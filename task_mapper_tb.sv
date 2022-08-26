// Code your testbench here
// or browse Examples
module task_mapper_tb; 
  localparam NUM_V=4;   
  reg clk;
  reg rst;
  logic [31:0]task_array; 
  logic root_task;



  initial begin
    #1 root_task=1'b0;   
  end

  initial begin
    #18 root_task=1'b1; 
    $display("time=%d ns root_task= %d",$time, root_task);
  end

  initial begin
    #28 root_task=1'b0;   
  end


  logic [31:0] task_graph [2:0][2:0];
  assign task_graph = '{{32'd0,32'd5,32'd0},{32'd5,32'd0,32'd6},{32'd0,32'd6,32'd0}};
  int i,j;
  logic [31:0] row ,col;

  initial begin
    row=0;
    col =0;
  end

  initial begin
    row=0;
    // giving opp. becuase of SV array
    for(i=2;i>=0;i--) begin
      col=0;
      for(j=2;j>=0;j--) begin
        #20; //2 clk cyle to read next task
        task_array = task_graph[i][j];
        `ifdef debug_help  
        $display("time = %f ns i= %d  j=%d task_array= %d task_graph = %d",$time,row,col,task_array,task_graph[i][j]);  
        // $display("time %d ns row %d col %d",$time,row,col);
        `endif

        col++;
      end
      row++;
    end
  end 


  //-timescale=1ns/1ns +vcs+flush+all +warn=all  +define+debug_help -sverilog
  task_mapper U0 ( 
    .clk    (clk),
    .rst_b  (rst),
    .task_array(task_array),
    .root_task
  ); 

  initial begin
    clk = 1;  
    rst = 0;
  end 
  //reset generation   
  always   
    #1   rst =1;
  //clk generation  
  always begin 
    #5  clk =  ! clk; // T=10ns
  end
  //Waveform
  initial  begin
    $dumpfile ("task_mapper.vcd"); 
    $dumpvars; 
  end 
  //textual output

  /*
  initial  begin
     $display("\t\ttime,\tclk,\treset,\tenable,\tcount"); 
    $monitor("%d,\t%b ,\t%b",$time, clk, rst); 
 end 
 */  
  initial 
    #200 $finish; //1000 clk cylce simulation


endmodule
