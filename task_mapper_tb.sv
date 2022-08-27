// Code your testbench here
// or browse Examples
module array_check_tb; 
  localparam NUM_V=4;   
  reg clk;
  reg rst;
  logic [31:0]task_array; 
  logic root_task;



  initial begin
    #1 root_task=1'b0;   
  end


  logic [31:0] task_graph [2:0][2:0];
  logic [31:0] row ,col;
  logic [2:0] count_root_task;
  int i,j;



  initial begin
    row=0;
    col =0;
  end 

  assign task_graph = '{{32'd0,32'd5,32'd0},{32'd5,32'd0,32'd6},{32'd0,32'd6,32'd0}};
  //pushing each application loop ~~~~~~~~~~ 
  initial begin
    row=0;
    count_root_task='0;
    // giving opp. becuase of SV array
    for(i=2;i>=0;i--) begin
      col=0;
      for(j=2;j>=0;j--) begin
        if( root_task == '0) begin
          #20; //2 clk cyle to read next task
        end else begin 
          #10 root_task=1'b0;
          #10;
        end
        task_array = task_graph[i][j];
        if (task_array!='0) begin 
          count_root_task=count_root_task+3'b001;
          if(count_root_task==3'b001) begin
            root_task=1'b1;
          end
        end
        `ifdef debug_help  
        $display("time = %f ns i= %d  j=%d task_array= %d task_graph = %d",$time,row,col,task_array,task_graph[i][j]);  
        // $display("time %d ns row %d col %d",$time,row,col);
        `endif

        col++;
      end
      row++;
    end
  end 
  //pushing each application loop ~~~~~~~~~~

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
