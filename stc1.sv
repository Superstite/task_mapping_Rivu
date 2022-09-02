
//############################################################################## 
//Minimum C calculation at every clock
initial begin
  foreach(C_stc1[i,j]) begin
    C_stc1[i][j]=0;
  end
end


always@(posedge clk) begin
  if((root_task==1'b1) && (threshold_detection_logic==32'd1)) begin

    foreach(ps1[i,j]) begin
      if(ps1[i][j]== '0) begin
        C_stc1[i][j]=C1[i][j];
      end  else begin
        C_stc1[i][j]=20; // set to highest
      end
      `ifdef debug_help
      $display("time =%d ns i=%d  j=%d of C Matrix of stc1 %d %d",$time,i,j,C_stc1[i][j],C1[i][j]);
      `endif 
    end
    cmin_stc1=C_stc1.min()with(item>0);
    `ifdef debug_help    
    $display("Minimum distance of PE vailabe at time time =%d ns Cmin_stc1=%p",$time,int'(cmin_stc1));
    `endif
  end
end



//Maximum D calculation  
always@(posedge clk) begin
  if((root_task==1'b1)&& (threshold_detection_logic==32'd1)) begin
    foreach(C_stc1[i,j]) begin
      if(C_stc1[i][j]==int'(cmin_stc1)) begin
        `ifdef debug_help
        if(root_task)
          $display(" C matrix of stc1 :- time =%dns cordinates x=%d y=%d",$time,i,j);
        `endif
        dmax_stc1= (D_stc1[i][j]>dmax_stc1)?D_stc1[i][j]:dmax_stc1;
      end      
    end
  end 
end
//##############################################################################

////#############################root task mapping//#############################

always@(posedge divby2_clk) begin

  if((root_task==1'b1)&& (threshold_detection_logic==32'd1)) begin
    foreach(D_stc1[i,j]) begin 
      if(D_stc1[i][j]==int'(dmax_stc1)) begin
        ps1[i][j]=1'b1;

        `ifdef debug_help    
        $display(" time =%dns cordinates x=%d y=%d PE is busy",$time,i,j);
        `endif
        src_id =  id_decoder_stc1(i,j);
        task_graph_to_idmap[row][col]= src_id;
        dest_id= src_id;
        $display(" time =%dns stc1 cluster :- src_id= %d dest_id=%d Minimum MD 0 i.e root_task",$time,src_id,dest_id);


        current_mapped_node_x_stc1=i;
        current_mapped_node_y_stc1=j;
        break;

      end
    end
  end
end

//##############################################################################

////#############################child task mapping//#############################  




//###################### MD calculation for child task //######################

always@(posedge clk) begin
  if((child_task==1'b1)&& (threshold_detection_logic==32'd1)) begin

    foreach(ps1[i,j]) begin
      if(ps1[i][j]== '0) begin
        C_child_i_stc1= ($signed(current_mapped_node_x_stc1 -i)<0)?-$signed(current_mapped_node_x_stc1 -i):current_mapped_node_x_stc1 -i;
        C_child_j_stc1 =($signed(current_mapped_node_y_stc1 -j)<0)?-$signed(current_mapped_node_y_stc1 -j):current_mapped_node_y_stc1 -j;
        C_child_stc1[i][j]= C_child_i_stc1 + C_child_j_stc1;
        `ifdef debug_help
        $display("time =%d i= %d j=%d C_child is %d and current_node_x_stc1= %d current_node_y_stc1=%d",$time,i,j,C_child_stc1[i][j],current_mapped_node_x_stc1,current_mapped_node_y_stc1);
        `endif
        cmin_child_stc1=(C_child_stc1[i][j]<cmin_child_stc1)?C_child_stc1[i][j]:cmin_child_stc1;

      end
      else if (ps1[i][j]==1'b1) begin
        C_child_stc1[i][j]= 1000;
        `ifdef debug_help
        $display("time =%d i= %d j=%d C_child is %d and current_node_x_stc1= %d current_node_y_stc1=%d",$time,i,j,C_child_stc1[i][j],current_mapped_node_x_stc1,current_mapped_node_y_stc1);
        `endif
      end 
    end
    `ifdef debug_help
    $display("Minimum distance of PE vailabe at  time =%d ns Cmin_child_stc1= %d",$time,cmin_child_stc1);
    `endif
  end
end

//##############################################################################


////#############################child task mapping final step //#############################  
always@(posedge divby2_clk) begin
  if(((child_task==1'b1)&& (threshold_detection_logic==32'd1)) & (task_array!=0)) begin
    foreach(C_child_stc1[i,j]) begin 
      if(C_child_stc1[i][j]==int'(C_child_stc1.min())) begin
        ps1[i][j]=1'b1;

        `ifdef debug_help    
        $display(" time =%dns cordinates x=%d y=%d PE is busy",$time,i,j);
        `endif

        src_id=  id_decoder_stc1(i,j);
        task_graph_to_idmap[int'(row)][int'(col)]= src_id;
        dest_id= (task_graph_to_idmap[int'(col)][int'(row)]==0)?src_id:task_graph_to_idmap[int'(col)][int'(row)];
        if(int'(C_child_stc1.min())==1000)
          $display(" time =%dns stc1 Cluster is busy",$time);
        else
          $display(" time =%dns stc1 cluster: src_id= %d dest_id=%d Minimum MD %d",$time,src_id,dest_id,int'(C_child_stc1.min()));

        current_mapped_node_x_stc1=i;
        current_mapped_node_y_stc1=j;
        break;
      end
      else begin
        //  $display("time %dns Cchild_matrixmin %d",$time,int'(C_child_stc1.min()));
      end
    end
  end
end

//PE release after delay by number of element in a row of task graph X task pushing interval // 4x20=80
always@(posedge clk) begin
  foreach(ps1[i,j]) begin
    if(ps1[i][j]==1'b1) begin
      `ifdef debug_help 
      $display("1. time =%d ns i=%d  j=%d of ps1 Matrix %d is used",$time,i,j,ps1[i][j]);
      `endif
      @(posedge divby2_clk);  @(posedge divby2_clk); @(posedge divby2_clk);  @(posedge divby2_clk);
      @(posedge divby2_clk); begin ps1[i][j]=1'b0;  end // delay by number of element in a row of task graph X task pushing interval // 4x20=80
      `ifdef debug_help 
      $display("2. time =%d ns i=%d  j=%d of ps1 Matrix %d is released ",$time,i,j,ps1[i][j]);
      `endif
    end
  end
  //$display(" time =%dns pm matrix %p",$time);
end



