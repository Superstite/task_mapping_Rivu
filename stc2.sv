 
  //############################################################################## 
  //Minimum C calculation at every clock
  initial begin
    foreach(C_stc2[i,j]) begin
      C_stc2[i][j]=0;
    end
  end


  always@(posedge clk) begin
    if(root_task==1'b1) begin

      foreach(ps2[i,j]) begin
        if(ps2[i][j]== '0) begin
          C_stc2[i][j]=C1[i][j];
        end  else begin
          C_stc2[i][j]=20; // set to highest
        end
        `ifdef debug_help
        $display("time =%d ns i=%d  j=%d of C Matrix of stc2 %d %d",$time,i,j,C_stc2[i][j],C1[i][j]);
        `endif 
      end
      cmin_stc2=C_stc2.min()with(item>0);
      `ifdef debug_help    
      $display("Minimum distance of PE vailabe at time time =%d ns Cmin_stc2=%p",$time,int'(cmin_stc2));
      `endif
    end
  end

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

  //Maximum D calculation  
  always@(posedge clk) begin
    if(root_task==1'b1) begin
      foreach(C_stc2[i,j]) begin
        if(C_stc2[i][j]==int'(cmin_stc2)) begin
          `ifdef debug_help
          if(root_task)
            $display(" C matrix of stc2 :- time =%dns cordinates x=%d y=%d",$time,i,j);
          `endif
          dmax_stc2= (D_stc2[i][j]>dmax_stc2)?D_stc2[i][j]:dmax_stc2;
        end      
      end
    end 
  end
  //##############################################################################

  ////#############################root task mapping//#############################

  always@(posedge divby2_clk) begin

    if(root_task==1'b1) begin
      foreach(D_stc2[i,j]) begin 
        if(D_stc2[i][j]==int'(dmax_stc2)) begin
          ps2[i][j]=1'b1;

          `ifdef debug_help    
          $display(" time =%dns cordinates x=%d y=%d PE is busy",$time,i,j);
          `endif
          src_id =  id_decoder_stc2(i,j);
          task_graph_to_idmap[row][col]= src_id;
          dest_id= src_id;
          $display(" time =%dns stc2 cluster :- src_id= %d dest_id=%d Minimum MD 0 i.e root_task",$time,src_id,dest_id);


          current_mapped_node_x_stc2=i;
          current_mapped_node_y_stc2=j;
          break;

        end
      end
    end
  end

  //##############################################################################

  ////#############################child task mapping//#############################  


  

  //###################### MD calculation for child task //######################

  always@(posedge clk) begin
    if(child_task==1'b1) begin

      foreach(ps2[i,j]) begin
        if(ps2[i][j]== '0) begin
          C_child_i_stc2= ($signed(current_mapped_node_x_stc2 -i)<0)?-$signed(current_mapped_node_x_stc2 -i):current_mapped_node_x_stc2 -i;
          C_child_j_stc2 =($signed(current_mapped_node_y_stc2 -j)<0)?-$signed(current_mapped_node_y_stc2 -j):current_mapped_node_y_stc2 -j;
          C_child_stc2[i][j]= C_child_i_stc2 + C_child_j_stc2;
          `ifdef debug_help
          $display("time =%d i= %d j=%d C_child is %d and current_node_x_stc2= %d current_node_y_stc2=%d",$time,i,j,C_child_stc2[i][j],current_mapped_node_x_stc2,current_mapped_node_y_stc2);
          `endif
          cmin_child_stc2=(C_child_stc2[i][j]<cmin_child_stc2)?C_child_stc2[i][j]:cmin_child_stc2;

        end
        else if (ps2[i][j]==1'b1) begin
          C_child_stc2[i][j]= 1000;
          `ifdef debug_help
          $display("time =%d i= %d j=%d C_child is %d and current_node_x_stc2= %d current_node_y_stc2=%d",$time,i,j,C_child_stc2[i][j],current_mapped_node_x_stc2,current_mapped_node_y_stc2);
          `endif
        end 
      end
      `ifdef debug_help
      $display("Minimum distance of PE vailabe at  time =%d ns Cmin_child_stc2= %d",$time,cmin_child_stc2);
      `endif
    end
  end

  //##############################################################################


  ////#############################child task mapping final step //#############################  
  always@(posedge divby2_clk) begin
    if(child_task==1'b1 & (task_array!=0)) begin
      foreach(C_child_stc2[i,j]) begin 
        if(C_child_stc2[i][j]==int'(C_child_stc2.min())) begin
          ps2[i][j]=1'b1;

          `ifdef debug_help    
          $display(" time =%dns cordinates x=%d y=%d PE is busy",$time,i,j);
          `endif

          src_id=  id_decoder_stc2(i,j);
          task_graph_to_idmap[int'(row)][int'(col)]= src_id;
          dest_id= (task_graph_to_idmap[int'(col)][int'(row)]==0)?src_id:task_graph_to_idmap[int'(col)][int'(row)];
          if(int'(C_child_stc2.min())==1000)
            $display(" time =%dns stc2 Cluster is busy",$time);
          else
          $display(" time =%dns stc2 cluster: src_id= %d dest_id=%d Minimum MD %d",$time,src_id,dest_id,int'(C_child_stc2.min()));

          current_mapped_node_x_stc2=i;
          current_mapped_node_y_stc2=j;
          break;
        end
        else begin
          //  $display("time %dns Cchild_matrixmin %d",$time,int'(C_child_stc2.min()));
        end
      end
    end
  end

  //PE release after delay by number of element in a row of task graph X task pushing interval // 4x20=80
  always@(posedge clk) begin
    foreach(ps2[i,j]) begin
      if(ps2[i][j]==1'b1) begin
        `ifdef debug_help 
        $display("1. time =%d ns i=%d  j=%d of ps2 Matrix %d is used",$time,i,j,ps2[i][j]);
        `endif
        @(posedge divby2_clk);  @(posedge divby2_clk); @(posedge divby2_clk);  @(posedge divby2_clk);
        @(posedge divby2_clk); begin ps2[i][j]=1'b0;  end // delay by number of element in a row of task graph X task pushing interval // 4x20=80
        `ifdef debug_help 
        $display("2. time =%d ns i=%d  j=%d of ps2 Matrix %d is released ",$time,i,j,ps2[i][j]);
        `endif
      end
    end
    //$display(" time =%dns pm matrix %p",$time);
  end




