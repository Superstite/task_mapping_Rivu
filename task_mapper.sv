// Code your design here
/////////////////////////////////////////////////////
// Task Mapper System Verilog File                  #
// Code owner:- Rivu Ghosh                          #
////////////////////////////////////////////////////

module task_mapper (
  input logic clk,
  input logic rst_b,
  input logic [31:0] task_array, // task graph input
  input logic root_task, // application id is required
  input logic [31:0] row,col,
  output logic [31:0] src_id,dest_id
);



  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  //Keep this part of code in sync with TB
  int i,j;

  int task_graph_to_idmap[3:0][3:0]  = '{{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}};

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
  //#################### ID decoder##############
  //clock divider

  logic divby2_clk;

  always @(posedge clk)
    begin
      if (~rst_b)
        divby2_clk <= 1'b1;
      else
        divby2_clk <= ~divby2_clk;	
    end

  logic divby4_clk;
  always @(posedge divby2_clk)
    begin
      if (~rst_b)
        divby4_clk <= 1'b1;
      else
        divby4_clk <= ~divby4_clk;	
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
  //TODO occupation threshold =    num of 1 /num of 0
  //function to calculate number of 0 and 1 in occupation matrix for every clock cylce 
  localparam ThMax=1.7; //70% usage of cluster      


  int l,m;
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

  //##############################
  // Algorithm start here        #
  //##############################

  //root task mapping variable
  int  C[3:0][3:0];
  int  D[3:0][3:0];
  int cmin[$];


  //child task mapping  variable
  int signed C_child[3:0][3:0];
  int signed  C_child_i;
  int signed  C_child_j;
  //Minimum C calculation at every clock
  int signed cmin_child=1000; //high value intial

  // common variable
  int current_mapped_node_x,current_mapped_node_y;

  //############################################################################## 
  //Minimum C calculation at every clock
  initial begin
    foreach(C[i,j]) begin
      C[i][j]=0;
    end
  end


  always@(posedge clk) begin
    if(root_task==1'b1) begin

      foreach(pm[i,j]) begin
        if(pm[i][j]== '0) begin
          C[i][j]=Cm[i][j];
        end  else begin
          C[i][j]=20; // set to highest
        end
        `ifdef debug_help
        $display("time =%d ns i=%d  j=%d of C Matrix %d %d",$time,i,j,C[i][j],Cm[i][j]);
        `endif 
      end
      cmin=C.min()with(item>0);
      `ifdef debug_help    
      $display("Minimum distance of PE vailabe at time time =%d ns Cmin=%p",$time,int'(cmin));
      `endif
    end
  end

  //##############################################################################
  //The D matrix: D(PE) is defined as the number of idle neighbors of that PE
  int dmax;
  always@(posedge clk) begin
    D='{{dm_00 , dm_01 , dm_02 , dm_03} , {dm_10 , dm_11 , dm_12 , dm_13} , {dm_20 , dm_21 , dm_22 , dm_23 }, {dm_30 , dm_31 , dm_32 , dm_33}}; 
    foreach(D[i,j]) begin
      // dmax=int'(D.max()with(item>0));
      `ifdef debug_help
      if(root_task)
        $display("Dmatrix time =%dns i=%d j=%d  element %d",$time,i,j,D[i][j]);
      `endif
    end
    // $display("Dmatrix time =%dns %p weightage maximum idle neigbour",$time,dmax);
  end
  //##############################################################################

  //Maximum D calculation  
  always@(posedge clk) begin
    if(root_task==1'b1) begin
      foreach(C[i,j]) begin
        if(C[i][j]==int'(cmin)) begin
          `ifdef debug_help
          if(root_task)
            $display(" C matrix :- time =%dns cordinates x=%d y=%d",$time,i,j);
          `endif
          dmax= (D[i][j]>dmax)?D[i][j]:dmax;
        end      
      end
    end 
  end
  //##############################################################################

  ////#############################root task mapping//#############################

  always@(posedge clk) begin

    if(root_task==1'b1) begin
      foreach(D[i,j]) begin 
        if(D[i][j]==int'(dmax)) begin
          pm[i][j]=1'b1;

          `ifdef debug_help    
          $display(" time =%dns cordinates x=%d y=%d PE is busy",$time,i,j);
          `endif
          src_id =  id_decoder_mtc(i,j);
          task_graph_to_idmap[row][col]= src_id;
          dest_id= src_id;
          $display(" time =%dns src_id= %d dest_id=%d",$time,src_id,dest_id);


          current_mapped_node_x=i;
          current_mapped_node_y=j;
          break;

        end
      end
    end
  end

  //##############################################################################

  ////#############################child task mapping//#############################  


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

  //###################### MD calculation for child task //######################

  always@(posedge clk) begin
    if(child_task==1'b1) begin

      foreach(pm[i,j]) begin
        if(pm[i][j]== '0) begin
          C_child_i= ($signed(current_mapped_node_x -i)<0)?-$signed(current_mapped_node_x -i):current_mapped_node_x -i;
          C_child_j =($signed(current_mapped_node_y -j)<0)?-$signed(current_mapped_node_y -j):current_mapped_node_y -j;
          C_child[i][j]= C_child_i + C_child_j;
          `ifdef debug_help
          $display("time =%d i= %d j=%d C_child is %d and current_node_x= %d current_node_y=%d",$time,i,j,C_child[i][j],current_mapped_node_x,current_mapped_node_y);
          `endif
          cmin_child=(C_child[i][j]<cmin_child)?C_child[i][j]:cmin_child;

        end
        else if (pm[i][j]==1'b1) begin
          C_child[i][j]= 1000;
          `ifdef debug_help
          $display("time =%d i= %d j=%d C_child is %d and current_node_x= %d current_node_y=%d",$time,i,j,C_child[i][j],current_mapped_node_x,current_mapped_node_y);
          `endif
        end 
      end
      `ifdef debug_help
      $display("Minimum distance of PE vailabe at  time =%d ns Cmin_child= %d",$time,cmin_child);
      `endif
    end
  end
  //##############################################################################


  ////#############################child task mapping final step //#############################  
  always@(posedge divby2_clk) begin
    if(child_task==1'b1 & (task_array!=0)) begin
      foreach(C_child[i,j]) begin 
        if(C_child[i][j]==int'(cmin_child)) begin
          pm[i][j]=1'b1;

          `ifdef debug_help    
          $display(" time =%dns cordinates x=%d y=%d PE is busy",$time,i,j);
          `endif

          src_id=  id_decoder_mtc(i,j);
          task_graph_to_idmap[int'(row)][int'(col)]= src_id;
          dest_id= (task_graph_to_idmap[int'(col)][int'(row)]==0)?src_id:task_graph_to_idmap[int'(col)][int'(row)];

          $display(" time =%dns src_id= %d dest_id=%d",$time,src_id,dest_id);

          current_mapped_node_x=i;
          current_mapped_node_y=j;
          break;
        end
      end
    end
  end

  //PE release after
  always@(posedge clk) begin
    foreach(pm[i,j]) begin
      if(pm[i][j]==1'b1) begin
        `ifdef debug_help 
        $display("1. time =%d ns i=%d  j=%d of pm Matrix %d is used",$time,i,j,pm[i][j]);
        `endif
        @(posedge divby2_clk);  @(posedge divby2_clk); @(posedge divby2_clk);  @(posedge divby2_clk);
        @(posedge divby2_clk); begin pm[i][j]=1'b0;  end // delay by number of element in a row of task graph X task pushing interval // 4x20=80
        `ifdef debug_help 
        $display("2. time =%d ns i=%d  j=%d of pm Matrix %d is released ",$time,i,j,pm[i][j]);
        `endif
      end
    end
    //$display(" time =%dns pm matrix %p",$time);
  end


  `ifdef debug_help 
  always @(posedge clk)
    $display("time %d ns row %d col %d of  task_graph_to_idmap array  %p is %d",$time,row,col, task_graph_to_idmap,task_graph_to_idmap[row][col]);
  `endif
  //##############################################################################

endmodule
