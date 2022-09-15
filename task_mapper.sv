// Code your design here
/////////////////////////////////////////////////////
// Task Mapper System Verilog File                  #
// Code owner:- Rivu Ghosh                          #
////////////////////////////////////////////////////

module task_mapper #(NUM_V=4)(
  input logic clk,
  input logic rst_b,
  input logic [31:0] task_array, // task graph input
  input logic root_task,app_end, // application start and end indication
  input logic [31:0] row,col,
  output logic [31:0] src_id,dest_id
);


  `include "algo_variable.sv"
  logic [31:0]  threshold_detection_logic;



  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  //Keep this part of code in sync with TB
  int i,j;
  int l,m;
  //app_1
  int task_graph_to_idmap[NUM_V-1:0][NUM_V-1:0]  = '{{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};
  //app_2
//int task_graph_to_idmap[NUM_V-1:0][NUM_V-1:0]  = '{{0,0,0},{0,0,0},{0,0,0}};
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

  //#################### ID decoder##############
  function int id_decoder_mtc ( input [31:0] i,j); 
    int id;
    case({i,j})
      {32'd0,32'd0}:id=0;
      {32'd0,32'd1}:id=1;
      {32'd0,32'd2}:id=2;
      {32'd0,32'd3}:id=3;
      //
      {32'd1,32'd0}:id=8;
      {32'd1,32'd1}:id=9;
      {32'd1,32'd2}:id=10;
      {32'd1,32'd3}:id=11;
      //
      {32'd2,32'd0}:id=16;
      {32'd2,32'd1}:id=17;
      {32'd2,32'd2}:id=18;
      {32'd2,32'd3}:id=19;
      //
      {32'd3,32'd0}:id=24;
      {32'd3,32'd1}:id=25;
      {32'd3,32'd2}:id=26;
      {32'd3,32'd3}:id=27;
      default: id=0;
    endcase
    return id;
  endfunction

  function int id_decoder_stc1 ( input [31:0] i,j); 
    int id;
    case({i,j})
      {32'd0,32'd0}:id=4;
      {32'd0,32'd1}:id=5;
      {32'd0,32'd2}:id=6;
      {32'd0,32'd3}:id=7;
      //
      {32'd1,32'd0}:id=12;
      {32'd1,32'd1}:id=13;
      {32'd1,32'd2}:id=14;
      {32'd1,32'd3}:id=15;
      //
      {32'd2,32'd0}:id=20;
      {32'd2,32'd1}:id=21;
      {32'd2,32'd2}:id=22;
      {32'd2,32'd3}:id=23;
      //
      {32'd3,32'd0}:id=28;
      {32'd3,32'd1}:id=29;
      {32'd3,32'd2}:id=30;
      {32'd3,32'd3}:id=31;
      default: id=0;
    endcase
    return id;
  endfunction

  function int id_decoder_stc2 ( input [31:0] i,j); 
    int id;
    case({i,j})
      {32'd0,32'd0}:id=36;
      {32'd0,32'd1}:id=37;
      {32'd0,32'd2}:id=38;
      {32'd0,32'd3}:id=39;
      //
      {32'd1,32'd0}:id=44;
      {32'd1,32'd1}:id=45;
      {32'd1,32'd2}:id=46;
      {32'd1,32'd3}:id=47;
      //
      {32'd2,32'd0}:id=52;
      {32'd2,32'd1}:id=53;
      {32'd2,32'd2}:id=54;
      {32'd2,32'd3}:id=55;
      //
      {32'd3,32'd0}:id=60;
      {32'd3,32'd1}:id=61;
      {32'd3,32'd2}:id=62;
      {32'd3,32'd3}:id=63;
      default: id=0;
    endcase
    return id;
  endfunction  

  function int id_decoder_stc3 ( input [31:0] i,j); 
    int id;
    case({i,j})
      {32'd0,32'd0}:id=32;
      {32'd0,32'd1}:id=33;
      {32'd0,32'd2}:id=34;
      {32'd0,32'd3}:id=35;
      //
      {32'd1,32'd0}:id=40;
      {32'd1,32'd1}:id=41;
      {32'd1,32'd2}:id=42;
      {32'd1,32'd3}:id=43;
      //
      {32'd2,32'd0}:id=48;
      {32'd2,32'd1}:id=49;
      {32'd2,32'd2}:id=50;
      {32'd2,32'd3}:id=51;
      //
      {32'd3,32'd0}:id=56;
      {32'd3,32'd1}:id=57;
      {32'd3,32'd2}:id=58;
      {32'd3,32'd3}:id=59;
      default: id=0;
    endcase
    return id;
  endfunction


  //#################### ID decoder##############
  function logic[63:0] pos_decoder_mtc ( input logic [31:0] id); 
    logic[31:0] i,j;
    case(id)
      0 : {i,j}= {32'd0,32'd0};
      1 : {i,j}= {32'd0,32'd1};
      2 : {i,j}= {32'd0,32'd2};
      3 : {i,j}= {32'd0,32'd3};
      //
      8 : {i,j}= {32'd1,32'd0};
      9 : {i,j}= {32'd1,32'd1};
      10: {i,j}= {32'd1,32'd2};
      11: {i,j}= {32'd1,32'd3};
      //
      16: {i,j}= {32'd2,32'd0};
      17: {i,j}= {32'd2,32'd1};
      18: {i,j}= {32'd2,32'd2};
      19: {i,j}= {32'd2,32'd3};
      //
      24: {i,j}= {32'd3,32'd0};
      25: {i,j}= {32'd3,32'd1};
      26: {i,j}= {32'd3,32'd2};
      27: {i,j}= {32'd3,32'd3}; 
      default: {i,j}= {32'd0,32'd0};
    endcase
    return {i,j};
  endfunction     


  function logic [63:0] pos_decoder_stc1 ( input logic [31:0] id); 
    logic [31:0] i,j;
    case({id})
      4:{i,j}= {32'd0,32'd0};
      5:{i,j}= {32'd0,32'd1};
      6:{i,j}= {32'd0,32'd2};
      7:{i,j}= {32'd0,32'd3};
      //
      12:{i,j}= {32'd1,32'd0};
      13:{i,j}= {32'd1,32'd1};
      14:{i,j}= {32'd1,32'd2};
      15:{i,j}= {32'd1,32'd3};
      //
      20:{i,j}= {32'd2,32'd0};
      21:{i,j}= {32'd2,32'd1};
      22:{i,j}= {32'd2,32'd2};
      23:{i,j}= {32'd2,32'd3};
      //
      28:{i,j}= {32'd3,32'd0};
      29:{i,j}= {32'd3,32'd1};
      30:{i,j}= {32'd3,32'd2};
      31:{i,j}= {32'd3,32'd3};
      default: {i,j}={32'd0,32'd0};
    endcase
    return {i,j};
  endfunction

  function logic [63:0] pos_decoder_stc2 ( input logic [31:0] id); 
    logic [31:0] i,j;
    case({id})
      36:{i,j}= {32'd0,32'd0};
      37:{i,j}= {32'd0,32'd1};
      38:{i,j}= {32'd0,32'd2};
      39:{i,j}= {32'd0,32'd3};
      //
      44:{i,j}= {32'd1,32'd0};
      45:{i,j}= {32'd1,32'd1};
      46:{i,j}= {32'd1,32'd2};
      47:{i,j}= {32'd1,32'd3};
      //
      52:{i,j}= {32'd2,32'd0};
      53:{i,j}= {32'd2,32'd1};
      54:{i,j}= {32'd2,32'd2};
      55:{i,j}= {32'd2,32'd3};
      //
      60:{i,j}= {32'd3,32'd0};
      61:{i,j}= {32'd3,32'd1};
      62:{i,j}= {32'd3,32'd2};
      63:{i,j}= {32'd3,32'd3};
      default: {i,j}={32'd0,32'd0} ;
    endcase
    return {i,j};
  endfunction  

  function logic [63:0] pos_decoder_stc3 (input logic [31:0] id); 
    logic [31:0] i,j;
    case(id)
      32 :{i,j}= {32'd0,32'd0};
      33 :{i,j}= {32'd0,32'd1};
      34 :{i,j}=  {32'd0,32'd2};
      35 :{i,j}=  {32'd0,32'd3};
      //
      40 :{i,j}=  {32'd1,32'd0};
      41 :{i,j}=  {32'd1,32'd1};
      42 :{i,j}=    {32'd1,32'd2};
      43 :{i,j}= {32'd1,32'd3};
      //
      48 :{i,j}= {32'd2,32'd0};
      49 :{i,j}= {32'd2,32'd1};
      50 :{i,j}= {32'd2,32'd2};
      51 :{i,j}= {32'd2,32'd3};
      //
      56 :{i,j}= {32'd3,32'd0};
      57 :{i,j}= {32'd3,32'd1};
      58 :{i,j}= {32'd3,32'd2};
      59 :{i,j}= {32'd3,32'd3};
      default:{i,j}={32'd0,32'd0};
    endcase
    return {i,j};
  endfunction  
  /////////////////// 

  //clock divider

  logic divby2_clk;

  always @(posedge clk)
    begin
      if (~rst_b)
        divby2_clk <= 1'b1;
      else
        divby2_clk <= ~divby2_clk;	
    end

  //###############

  //PE occupaction state matrix   - intialization 
  logic [3:0]  pm [3:0]  =  '{ 4{ 4'h0 } };       //MTC - cluster 1
  logic [3:0]  ps1 [3:0]  = '{ 4{ 4'h0 } };      //STC - cluster 2
  logic [3:0]  ps2 [3:0]  = '{ 4{ 4'h0 } };      //STC - cluster 3 
  logic [3:0]  ps3 [3:0]  = '{ 4{ 4'h0 } };      //STC - cluster 4 




  //Thm -PE occupation threshold of MTC’s cluster 
  //Th-is -PE occupation threshold of ith STC’s cluster
  //
  //TODO occupation threshold =    num of 1 /num of pe in  cluster
  //function to calculate number of 0 and 1 in occupation matrix for every clock cylce 
  localparam thmax=0.9; //90% usage of cluster    
  real th_mtc,th_stc1,th_stc2,th_stc3;
  real zero_count_mtc,one_count_mtc;
  real zero_count_stc1,one_count_stc1;
  real zero_count_stc2,one_count_stc2;
  real zero_count_stc3,one_count_stc3;

  always@(negedge clk) begin
    zero_count_mtc=0;
    foreach(pm[i,j]) begin
      if(pm[i][j]==0) begin
        zero_count_mtc++;
      end
    end
    one_count_mtc=16-zero_count_mtc;
    th_mtc=(one_count_mtc/16);
    `ifdef debug_help
    // $display("time =%d ns zero %d one %d occupation threshold of mtc %f",$time,zero_count_mtc,one_count_mtc,th_mtc);
    `endif
  end

  always@(negedge clk) begin
    zero_count_stc1=0;
    foreach(ps1[i,j]) begin
      if(ps1[i][j]==0) begin
        zero_count_stc1++;
      end
    end
    one_count_stc1=16-zero_count_stc1;
    th_stc1=(one_count_stc1/16);
    `ifdef debug_help
    // $display("time =%d ns zero %d one %d occupation threshold of stc1 %f",$time,zero_count_stc1,one_count_stc1,th_stc1);
    `endif
  end

  always@(negedge clk) begin
    zero_count_stc2=0;
    foreach(ps2[i,j]) begin
      if(ps2[i][j]==0) begin
        zero_count_stc2++;
      end
    end
    one_count_stc2=16-zero_count_stc2;
    th_stc2=(one_count_stc2/16);
    `ifdef debug_help
    // $display("time =%d ns zero %d one %d occupation threshold of stc2 %f",$time,zero_count_stc2,one_count_stc2,th_stc2);
    `endif
  end

  always@(negedge clk) begin
    zero_count_stc3=0;
    foreach(ps3[i,j]) begin
      if(ps3[i][j]==0) begin
        zero_count_stc3++;
      end
    end
    one_count_stc3=16-zero_count_stc3;
    th_stc3=(one_count_stc3/16);
    `ifdef debug_help
    //$display("time =%d ns zero %d one %d occupation threshold of stc2 %f",$time,zero_count_stc3,one_count_stc3,th_stc3);
    `endif
  end

  real threshold_cluster[3:0];
  int min_threshold_cluster[$];
  real item[$];

  always@(negedge clk) begin
    threshold_cluster='{th_stc3,th_stc2,th_stc1,th_mtc};
    item=threshold_cluster.min();
    min_threshold_cluster=threshold_cluster.find_last_index(x) with (x==item[0]);
    `ifdef debug_help
    $display("time =%d threshold_cluster array= %p cluster %d has min threshold",$time,threshold_cluster,min_threshold_cluster[0]);
    `endif
  end

  /////////////////////////////////////////////////////////////////////////

  //C-Matrix  - Manhattan distance   between any PE and the task controller (MTC or STC)- MD(aij ) = | 𝑥i − 𝑥j|+| 𝑦i − 𝑦j |.
  //SV array
  int  Cm [3:0][3:0] ='{{6,5,4,3},{5,4,3,2},{4,3,2,1},{3,2,1,10}};    //self highest= 10 // MTC -(0,0) 
  int  C1 [3:0][3:0] ='{{3,4,5,6},{2,3,4,5},{1,2,3,4},{10,1,2,3}};      // STC -(0,7)
  int  C2 [3:0][3:0] ='{{10,1,2,3},{1,2,3,4},{2,3,4,5},{3,4,5,6}};      // STC -(7,7)
  int  C3 [3:0][3:0] ='{{3,2,1,10},{4,3,2,1},{5,4,3,2},{6,5,4,3}};      // STC -(7,0)

  `ifdef debug_help
  initial begin
    foreach(Cm[l,m])begin
      $display("time =%d ns i=%d  j=%d of Cm Matrix %d ",$time,l,m,Cm[l][m]);
    end
  end

  initial begin
    foreach(C1[l,m])begin
      $display("time =%d ns i=%d  j=%d of C1 Matrix %d ",$time,l,m,C1[l][m]);
    end
  end

  initial begin
    foreach(C2[l,m])begin
      $display("time =%d ns i=%d  j=%d of C2 Matrix %d ",$time,l,m,C2[l][m]);
    end
  end

  initial begin
    foreach(C3[l,m])begin
      $display("time =%d ns i=%d  j=%d of C3 Matrix %d ",$time,l,m,C3[l][m]);
    end
  end

  `endif 


  //The D matrix: D(PE) is defined as the number of idle neighbors of that PE
  //TODO calculate the number of zeros within optdist of each PE of cluster every clock cylce
  //check all this possition (y+1,x),(y+2,x),(y-1,x),(y-2,x),(y,x+1),(y,x+2),(y,x-1),(y,x-2),(y+1,x+1),
  //(y+1,x-1),(y-1,x+1),(y-1,x-1)

  logic [7:0]   dm_00 , dm_01 , dm_02 , dm_03 , dm_10 , dm_11 , dm_12 , dm_13 , dm_20 , dm_21 , dm_22 , dm_23 , dm_30 , dm_31 , dm_32 , dm_33 , ds1_00, ds1_01, ds1_02, ds1_03, ds1_10, ds1_11, ds1_12, ds1_13, ds1_20, ds1_21, ds1_22, ds1_23, ds1_30, ds1_31, ds1_32, ds1_33, ds2_00, ds2_01, ds2_02, ds2_03, ds2_10, ds2_11, ds2_12, ds2_13, ds2_20, ds2_21, ds2_22, ds2_23, ds2_30, ds2_31, ds2_32, ds2_33, ds3_00, ds3_01, ds3_02, ds3_03, ds3_10, ds3_11, ds3_12, ds3_13, ds3_20, ds3_21, ds3_22, ds3_23, ds3_30, ds3_31, ds3_32, ds3_33;   

  //optimum distance = Max MD /3 = 6/3 =2  to check occupation of neighbors (TODO improvise on this)
  integer optdist= 2;
  //To check occupation of neighbors  
  always_ff @(posedge clk) begin

    //D matrix for cluster 1 (MTC)
    dm_00 <= pm[0][1]+pm[0][2]+pm[1][0]+pm[2][0]+pm[1][1];  
    dm_01 <= pm[1][1]+pm[2][1]+pm[0][2]+pm[0][3]+pm[0][0]+pm[1][0]+pm[1][2];
    dm_02 <= pm[0][0]+pm[0][1]+pm[0][3]+pm[1][2]+pm[2][2]+pm[1][1]+pm[3][3];
    dm_03 <= pm[0][1]+pm[0][2]+pm[1][3]+pm[1][2]+pm[2][3];
    dm_10 <= pm[0][0]+pm[2][0]+pm[3][0]+pm[1][1]+pm[1][2]+pm[2][1]+pm[0][1];
    dm_11 <= pm[1][0]+pm[1][2]+pm[1][3]+pm[0][0]+pm[0][1]+pm[0][2]+pm[2][0]+pm[2][1]+pm[2][2]+pm[3][1];
    dm_12 <= pm[1][0]+pm[1][1]+pm[1][3]+pm[0][1]+pm[0][2]+pm[0][3]+pm[2][1]+pm[2][2]+pm[2][3]+pm[3][2];
    dm_13 <= pm[1][0]+pm[1][1]+pm[1][2]+pm[0][2]+pm[0][3]+pm[2][2]+pm[2][3]+pm[3][3];
    dm_20 <= pm[0][0]+pm[1][0]+pm[1][1]+pm[2][1]+pm[2][2]+pm[2][3]+pm[3][0]+pm[3][1];
    dm_21 <= pm[0][1]+pm[1][0]+pm[1][1]+pm[1][2]+pm[2][0]+pm[2][2]+pm[2][3]+pm[3][0]+pm[3][1]+pm[3][2];
    dm_22 <= pm[0][2]+pm[1][1]+pm[1][2]+pm[1][3]+pm[2][0]+pm[2][1]+pm[2][3]+pm[3][1]+pm[3][2]+pm[3][3]; 
    dm_23 <= pm[0][3]+pm[1][2]+pm[1][3]+pm[2][1]+pm[2][2]+pm[3][2]+pm[3][3];
    dm_30 <= pm[1][0]+pm[2][0]+pm[2][1]+pm[3][1]+pm[3][2];
    dm_31 <= pm[1][1]+pm[2][0]+pm[2][1]+pm[2][2]+pm[3][0]+pm[3][2]+pm[3][3]; 
    dm_32 <= pm[1][2]+pm[2][1]+pm[2][2]+pm[2][3]+pm[3][0]+pm[3][1]+pm[3][3];
    dm_33 <= pm[1][3]+pm[2][2]+pm[2][3]+pm[3][1]+pm[3][2];

    //D matrix for cluster 2  
    ds1_00 <= ps1[0][1]+ps1[0][2]+ps1[1][0]+ps1[2][0]+ps1[1][1];
    ds1_01 <= ps1[1][1]+ps1[2][1]+ps1[0][2]+ps1[0][3]+ps1[0][0]+ps1[1][0]+ps1[1][2];
    ds1_02 <= ps1[0][0]+ps1[0][1]+ps1[0][3]+ps1[1][2]+ps1[2][2]+ps1[1][1]+ps1[3][3];
    ds1_03 <= ps1[0][1]+ps1[0][2]+ps1[1][3]+ps1[1][2]+ps1[2][3];
    ds1_10 <= ps1[0][0]+ps1[2][0]+ps1[3][0]+ps1[1][1]+ps1[1][2]+ps1[2][1]+ps1[0][1];
    ds1_11 <= ps1[1][0]+ps1[1][2]+ps1[1][3]+ps1[0][0]+ps1[0][1]+ps1[0][2]+ps1[2][0]+ps1[2][1]+ps1[2][2]+ps1[3][1];
    ds1_12 <= ps1[1][0]+ps1[1][1]+ps1[1][3]+ps1[0][1]+ps1[0][2]+ps1[0][3]+ps1[2][1]+ps1[2][2]+ps1[2][3]+ps1[3][2];
    ds1_13 <= ps1[1][0]+ps1[1][1]+ps1[1][2]+ps1[0][2]+ps1[0][3]+ps1[2][2]+ps1[2][3]+ps1[3][3];
    ds1_20 <= ps1[0][0]+ps1[1][0]+ps1[1][1]+ps1[2][1]+ps1[2][2]+ps1[2][3]+ps1[3][0]+ps1[3][1];
    ds1_21 <= ps1[0][1]+ps1[1][0]+ps1[1][1]+ps1[1][2]+ps1[2][0]+ps1[2][2]+ps1[2][3]+ps1[3][0]+ps1[3][1]+ps1[3][2];
    ds1_22 <= ps1[0][2]+ps1[1][1]+ps1[1][2]+ps1[1][3]+ps1[2][0]+ps1[2][1]+ps1[2][3]+ps1[3][1]+ps1[3][2]+ps1[3][3]; 
    ds1_23 <= ps1[0][3]+ps1[1][2]+ps1[1][3]+ps1[2][1]+ps1[2][2]+ps1[3][2]+ps1[3][3];
    ds1_30 <= ps1[1][0]+ps1[2][0]+ps1[2][1]+ps1[3][1]+ps1[3][2];
    ds1_31 <= ps1[1][1]+ps1[2][0]+ps1[2][1]+ps1[2][2]+ps1[3][0]+ps1[3][2]+ps1[3][3]; 
    ds1_32 <= ps1[1][2]+ps1[2][1]+ps1[2][2]+ps1[2][3]+ps1[3][0]+ps1[3][1]+ps1[3][3];
    ds1_33 <= ps1[1][3]+ps1[2][2]+ps1[2][3]+ps1[3][1]+ps1[3][2];            

    //D matrix for cluster 3 
    ds2_00 <= ps2[0][1]+ps2[0][2]+ps2[1][0]+ps2[2][0]+ps2[1][1];
    ds2_01 <= ps2[1][1]+ps2[2][1]+ps2[0][2]+ps2[0][3]+ps2[0][0]+ps2[1][0]+ps2[1][2];
    ds2_02 <= ps2[0][0]+ps2[0][1]+ps2[0][3]+ps2[1][2]+ps2[2][2]+ps2[1][1]+ps2[3][3];
    ds2_03 <= ps2[0][1]+ps2[0][2]+ps2[1][3]+ps2[1][2]+ps2[2][3];
    ds2_10 <= ps2[0][0]+ps2[2][0]+ps2[3][0]+ps2[1][1]+ps2[1][2]+ps2[2][1]+ps2[0][1];
    ds2_11 <= ps2[1][0]+ps2[1][2]+ps2[1][3]+ps2[0][0]+ps2[0][1]+ps2[0][2]+ps2[2][0]+ps2[2][1]+ps2[2][2]+ps2[3][1];
    ds2_12 <= ps2[1][0]+ps2[1][1]+ps2[1][3]+ps2[0][1]+ps2[0][2]+ps2[0][3]+ps2[2][1]+ps2[2][2]+ps2[2][3]+ps2[3][2];
    ds2_13 <= ps2[1][0]+ps2[1][1]+ps2[1][2]+ps2[0][2]+ps2[0][3]+ps2[2][2]+ps2[2][3]+ps2[3][3];
    ds2_20 <= ps2[0][0]+ps2[1][0]+ps2[1][1]+ps2[2][1]+ps2[2][2]+ps2[2][3]+ps2[3][0]+ps2[3][1];
    ds2_21 <= ps2[0][1]+ps2[1][0]+ps2[1][1]+ps2[1][2]+ps2[2][0]+ps2[2][2]+ps2[2][3]+ps2[3][0]+ps2[3][1]+ps2[3][2];
    ds2_22 <= ps2[0][2]+ps2[1][1]+ps2[1][2]+ps2[1][3]+ps2[2][0]+ps2[2][1]+ps2[2][3]+ps2[3][1]+ps2[3][2]+ps2[3][3]; 
    ds2_23 <= ps2[0][3]+ps2[1][2]+ps2[1][3]+ps2[2][1]+ps2[2][2]+ps2[3][2]+ps2[3][3];
    ds2_30 <= ps2[1][0]+ps2[2][0]+ps2[2][1]+ps2[3][1]+ps2[3][2];
    ds2_31 <= ps2[1][1]+ps2[2][0]+ps2[2][1]+ps2[2][2]+ps2[3][0]+ps2[3][2]+ps2[3][3]; 
    ds2_32 <= ps2[1][2]+ps2[2][1]+ps2[2][2]+ps2[2][3]+ps2[3][0]+ps2[3][1]+ps2[3][3];
    ds2_33 <= ps2[1][3]+ps2[2][2]+ps2[2][3]+ps2[3][1]+ps2[3][2]; 

    //D matrix for cluster 4
    ds3_00 <= ps3[0][1]+ps3[0][2]+ps3[1][0]+ps3[2][0]+ps3[1][1];
    ds3_01 <= ps3[1][1]+ps3[2][1]+ps3[0][2]+ps3[0][3]+ps3[0][0]+ps3[1][0]+ps3[1][2];
    ds3_02 <= ps3[0][0]+ps3[0][1]+ps3[0][3]+ps3[1][2]+ps3[2][2]+ps3[1][1]+ps3[3][3];
    ds3_03 <= ps3[0][1]+ps3[0][2]+ps3[1][3]+ps3[1][2]+ps3[2][3];
    ds3_10 <= ps3[0][0]+ps3[2][0]+ps3[3][0]+ps3[1][1]+ps3[1][2]+ps3[2][1]+ps3[0][1];
    ds3_11 <= ps3[1][0]+ps3[1][2]+ps3[1][3]+ps3[0][0]+ps3[0][1]+ps3[0][2]+ps3[2][0]+ps3[2][1]+ps3[2][2]+ps3[3][1];
    ds3_12 <= ps3[1][0]+ps3[1][1]+ps3[1][3]+ps3[0][1]+ps3[0][2]+ps3[0][3]+ps3[2][1]+ps3[2][2]+ps3[2][3]+ps3[3][2];
    ds3_13 <= ps3[1][0]+ps3[1][1]+ps3[1][2]+ps3[0][2]+ps3[0][3]+ps3[2][2]+ps3[2][3]+ps3[3][3];
    ds3_20 <= ps3[0][0]+ps3[1][0]+ps3[1][1]+ps3[2][1]+ps3[2][2]+ps3[2][3]+ps3[3][0]+ps3[3][1];
    ds3_21 <= ps3[0][1]+ps3[1][0]+ps3[1][1]+ps3[1][2]+ps3[2][0]+ps3[2][2]+ps3[2][3]+ps3[3][0]+ps3[3][1]+ps3[3][2];
    ds3_22 <= ps3[0][2]+ps3[1][1]+ps3[1][2]+ps3[1][3]+ps3[2][0]+ps3[2][1]+ps3[2][3]+ps3[3][1]+ps3[3][2]+ps3[3][3]; 
    ds3_23 <= ps3[0][3]+ps3[1][2]+ps3[1][3]+ps3[2][1]+ps3[2][2]+ps3[3][2]+ps3[3][3];
    ds3_30 <= ps3[1][0]+ps3[2][0]+ps3[2][1]+ps3[3][1]+ps3[3][2];
    ds3_31 <= ps3[1][1]+ps3[2][0]+ps3[2][1]+ps3[2][2]+ps3[3][0]+ps3[3][2]+ps3[3][3]; 
    ds3_32 <= ps3[1][2]+ps3[2][1]+ps3[2][2]+ps3[2][3]+ps3[3][0]+ps3[3][1]+ps3[3][3];
    ds3_33 <= ps3[1][3]+ps3[2][2]+ps3[2][3]+ps3[3][1]+ps3[3][2]; 

  end

  //##############################################################################
  //The D matrix: D(PE) is defined as the number of idle neighbors of that PE

  always@(posedge clk) begin
    D='{{dm_00 , dm_01 , dm_02 , dm_03} , {dm_10 , dm_11 , dm_12 , dm_13} , {dm_20 , dm_21 , dm_22 , dm_23 }, {dm_30 , dm_31 , dm_32 , dm_33}}; 
    foreach(D[i,j]) begin
      // dmax=int'(D.max()with(item>0));
      `ifdef debug_help
      if(root_task)
        $display("Dmatrix of mtc time =%dns i=%d j=%d  element %d",$time,i,j,D[i][j]);
      `endif
    end
    // $display("Dmatrix time =%dns %p weightage maximum idle neigbour",$time,dmax);
  end
  //##############################################################################

  //##############################################################################
  //The D matrix: D(PE) is defined as the number of idle neighbors of that PE

  always@(posedge clk) begin
    D_stc1='{{ds1_00 , ds1_01 , ds1_02 , ds1_03} , {ds1_10 , ds1_11 , ds1_12 , ds1_13} , {ds1_20 , ds1_21 , ds1_22 , ds1_23 }, {ds1_30 , ds1_31 , ds1_32 , ds1_33}}; 
    foreach(D_stc1[i,j]) begin
      // dmax_stc1=int'(D_stc1.max()with(item>0));
      `ifdef debug_help
      if(root_task)
        $display("Dmatrix of stc1 time =%dns i=%d j=%d  element %d",$time,i,j,D_stc1[i][j]);
      `endif
    end
    // $display("Dmatrix time =%dns %p weightage maximum idle neigbour",$time,dmax_stc1);
  end
  //##############################################################################
  //##############################################################################
  //The D matrix: D(PE) is defined as the number of idle neighbors of that PE

  always@(posedge clk) begin
    D_stc2='{{ds2_00 , ds2_01 , ds2_02 , ds2_03} , {ds2_10 , ds2_11 , ds2_12 , ds2_13} , {ds2_20 , ds2_21 , ds2_22 , ds2_23 }, {ds2_30 , ds2_31 , ds2_32 , ds2_33}}; 
    foreach(D_stc2[i,j]) begin
      // dmax_stc2=int'(D_stc2.max()with(item>0));
      `ifdef debug_help
      if(root_task)
        $display("Dmatrix of stc2 time =%dns i=%d j=%d  element %d",$time,i,j,D_stc2[i][j]);
      `endif
    end
    // $display("Dmatrix time =%dns %p weightage maximum idle neigbour",$time,dmax_stc2);
  end
  //##############################################################################

  //##############################################################################
  //The D matrix: D(PE) is defined as the number of idle neighbors of that PE

  always@(posedge clk) begin
    D_stc3='{{ds3_00 , ds3_01 , ds3_02 , ds3_03} , {ds3_10 , ds3_11 , ds3_12 , ds3_13} , {ds3_20 , ds3_21 , ds3_22 , ds3_23 }, {ds3_30 , ds3_31 , ds3_32 , ds3_33}}; 
    foreach(D_stc3[i,j]) begin
      // dmax_stc3=int'(D_stc3.max()with(item>0));
      `ifdef debug_help
      if(root_task)
        $display("Dmatrix of stc3 time =%dns i=%d j=%d  element %d",$time,i,j,D_stc3[i][j]);
      `endif
    end
    // $display("Dmatrix time =%dns %p weightage maximum idle neigbour",$time,dmax_stc3);
  end
  //############################################################################## 



  //###################### negedge detector for child task detection//######################
  logic child_task,root_task_ff;

  always_latch begin
    if(~rst_b) begin
      root_task_ff<= '0;
    end 
    else begin
      if(root_task) begin
        root_task_ff<=root_task;
      end
    end
  end

  assign child_task= root_task_ff & ~root_task;


  //##############################################################################

  //

  //flush task_graph_to_idmap matrix at end of each application execuetion
  always @(posedge clk) begin
    if(app_end==1'b1)
      task_graph_to_idmap <= '{{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};
      //task_graph_to_idmap <= '{{0,0,0},{0,0,0},{0,0,0}};
  end


  `ifdef debug_help 
  always @(posedge clk)
    $display("time %d ns row %d col %d of  task_graph_to_idmap array  %p is %d",$time,row,col, task_graph_to_idmap,task_graph_to_idmap[row][col]);
  `endif
  ////////////////


  // assign each application to a cluster which have least occupation threshold

  always @(posedge clk) begin
    if(~rst_b) begin threshold_detection_logic<='0; end
    else begin
      //  if((app_end==1'b1) || (real'(th_mtc) > thmax) || (real'(th_stc1) > thmax) ||(real'(th_stc2) > thmax) ||(real'(th_stc3) > thmax)) //TODO
      if(app_end==1'b1)
        threshold_detection_logic<=min_threshold_cluster[0];
      else
        threshold_detection_logic<=threshold_detection_logic;
    end
    `ifdef debug_help 
    $display("time %d ns %d cluster selected ",$time,threshold_detection_logic);
    `endif
  end

  //##############################################################################

  //
  //##############################
  // Algorithm start here        #
  //##############################
  `include "mtc.sv"   
  `include "stc1.sv"  
  `include "stc2.sv"  
  `include "stc3.sv" 

  //algorithm end
  //

endmodule
