// Code your testbench here

module task_mapper_tb; 
  localparam NUM_V=4;   
  reg clk;
  reg rst;
  logic [31:0]task_array; 
  logic root_task;

 initial begin
    clk = 1;  
    rst = 0;
  end

  initial begin
    #1 root_task=1'b0;   
  end


  logic [31:0] task_graph [3:0][3:0];
  logic [2:0] count_root_task;
  int i,j;


  assign task_graph = '{{32'd0,32'd0,32'd0,32'd7},{32'd0,32'd0,32'd6,32'd0},{32'd0,32'd6,32'd0,32'd5},{32'd7,32'd0,32'd5,32'd0}};
  
  
  //pushing each application loop ~~~~~~~~~~ 
  initial begin
    count_root_task='0;
    // giving opp. becuase of SV array
    for(i=0;i<4;i++) begin
      for(j=0;j<4;j++) begin
        task_array = task_graph[i][j];
        if (task_array!='0) begin 
          count_root_task=count_root_task+3'b001;
          if(count_root_task==3'b001) begin
            root_task=1'b1;
          end
        end
        if( root_task == '0) begin
          #20; //2 clk cyle to read next task
        end else begin 
          #10 root_task=1'b0;
          #10;
        end

        `ifdef debug_help  
        $display("time = %f ns i= %d  j=%d task_array= %d task_graph = %d",$time,i,j,task_array,task_graph[i][j]);  
        // $display("time %d ns row %d col %d",$time,row,col);
        `endif
      end
    end
  end 
  //pushing each application loop ~~~~~~~~~~

  //-timescale=1ns/1ns +vcs+flush+all +warn=all  +define+debug_help -sverilog
  task_mapper U0 ( 
    .clk    (clk),
    .rst_b  (rst),
    .task_array(task_array),
    .root_task,
    .row(i),
    .col(j)
  ); 

  
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
    #550 $finish; //1000 clk cylce simulation


endmodule
