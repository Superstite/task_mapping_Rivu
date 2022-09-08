// Code your testbench here
// or browse Examples
module array_check_tb; 
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
  int i,j,app_1;
  logic app_end;

  //app_1
  assign task_graph = '{{32'd0,32'd0,32'd0,32'd7},{32'd0,32'd0,32'd6,32'd0},{32'd0,32'd6,32'd0,32'd5},{32'd7,32'd0,32'd5,32'd0}};


  //pushing each application loop ~~~~~~~~~~ 
  initial begin
    for(app_1=1;app_1<=500;app_1++) begin
      app_end=1'b0;
      count_root_task='0;
      // giving opp. becuase of SV array
      for(i=0;i<4;i++) begin
        for(j=0;j<4;j++) begin
          task_array = task_graph[i][j];
          `ifdef debug_help  
          $display("time = %f ns i= %d  j=%d task_array= %d task_graph = %d",$time,i,j,task_array,task_graph[i][j]);  
          `endif

          if (task_array!='0) begin 
            count_root_task=count_root_task+3'b001;
            if(count_root_task==3'b001) begin
              root_task=1'b1;
            end
          end
          @(posedge clk);
          if( root_task == '0) begin
            //#20; //2 clk cyle to read next task
            @(posedge clk);

          end else begin 
            @(posedge clk); root_task=1'b0;
          end

        end
      end
      @(posedge clk);app_end=1'b1;
      @(posedge clk);app_end=1'b0;
      @(posedge clk);
    end //app_1 number loop
  end 
  //pushing each application loop ~~~~~~~~~~

  //-timescale=1ns/1ns +vcs+flush+all +warn=all  +define+debug_help -sverilog
  task_mapper U0 ( 
    .clk    (clk),
    .rst_b  (rst),
    .task_array(task_array),
    .root_task,
    .row(i),
    .col(j),
    .app_end
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
    #5000 $finish; //1000 clk cylce simulation


endmodule
