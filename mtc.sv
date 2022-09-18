
//############################################################################## 
//Minimum C calculation at every clock
initial begin
  foreach(C[i,j]) begin
    C[i][j]=0;
  end
end


always@(posedge clk) begin
  if((root_task==1'b1) && (threshold_detection_logic==32'd0)) begin

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



//Maximum D calculation  
always@(posedge clk) begin
  if((root_task==1'b1) && (threshold_detection_logic==32'd0)) begin
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

always@(posedge divby2_clk) begin

  if((root_task==1'b1)&& (threshold_detection_logic==32'd0)) begin
    foreach(D[i,j]) begin 
      if(D[i][j]==int'(dmax)) begin
        pm[i][j]=1'b1;

        `ifdef debug_help    
        $display(" time =%dns cordinates x=%d y=%d PE is busy",$time,i,j);
        `endif
        src_id =  id_decoder_mtc(i,j);
        task_graph_to_idmap[row][col]= src_id;
        dest_id= src_id;
        $display(" time =%dns MTC cluster: src_id= %d dest_id=%d Minimum MD 0 i.e root_task",$time,src_id,dest_id);


        current_mapped_node_x=i;
        current_mapped_node_y=j;
        break;

      end
    end
  end
end

//##############################################################################

////#############################child task mapping//#############################  




//###################### MD calculation for child task //######################

always@(negedge clk) begin
  if((child_task==1'b1)&& (threshold_detection_logic==32'd0)) begin

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
logic[31:0] pos_decoder_mtc_x;
logic[31:0] pos_decoder_mtc_y;
always@(posedge divby2_clk) begin
  if(((child_task==1'b1)&& (threshold_detection_logic==32'd0)) & (task_array!=0)) begin

    if(task_graph_to_idmap[int'(col)][int'(row)]==0) begin
      foreach(C_child[i,j]) begin 
        if(C_child[i][j]==int'(C_child.min())) begin
          pm[i][j]=1'b1;

          `ifdef debug_help    
          $display(" time =%dns cordinates x=%d y=%d PE is busy",$time,i,j);
          `endif

          src_id=  id_decoder_mtc(i,j);
          task_graph_to_idmap[int'(row)][int'(col)]= src_id;
          // dest_id= (task_graph_to_idmap[int'(col)][int'(row)]==0)?src_id:task_graph_to_idmap[int'(col)][int'(row)];
          dest_id=src_id;
          if(int'(C_child.min())==1000)
            $display(" time =%dns MTC Cluster  is busy",$time);
          else
            //$display(" time =%dns MTC cluster: src_id= %d dest_id=%d Minimum MD 0",$time,src_id,dest_id);
            $display(" time =%dns MTC cluster: src_id= %d dest_id=%d",$time,src_id,dest_id);
          current_mapped_node_x=i;
          current_mapped_node_y=j;
          break;
        end
      end
    end 

    else begin
      {pos_decoder_mtc_x,pos_decoder_mtc_y} = pos_decoder_mtc(task_graph_to_idmap[int'(col)][int'(row)]);
      current_mapped_node_x=pos_decoder_mtc_x;
      current_mapped_node_y=pos_decoder_mtc_y;
      `ifdef debug_help  
      $display(" time =%dns task_graph_to_idmap[int'(col)][int'(row)], =%d current_mapped_node_x= %d current_mapped_node_y=%d",$time,task_graph_to_idmap[int'(col)][int'(row)],current_mapped_node_x,current_mapped_node_y);
      `endif
    end

  end
end

always@(negedge divby2_clk) begin
  if(((child_task==1'b1)&& (threshold_detection_logic==32'd0)) & (task_array!=0)) begin
    if(task_graph_to_idmap[int'(col)][int'(row)] !=0) begin
      foreach(C_child[i,j]) begin 
        if(C_child[i][j]==int'(C_child.min())) begin
          pm[i][j]=1'b1;
          src_id=  id_decoder_mtc(i,j);
          task_graph_to_idmap[int'(row)][int'(col)]= src_id;
          dest_id=task_graph_to_idmap[int'(col)][int'(row)];
         // $display(" time =%dns MTC cluster: src_id= %d dest_id=%d Minimum MD %d",$time,src_id,dest_id,int'(C_child.min()));
          $display(" time =%dns MTC cluster: src_id= %d dest_id=%d",$time,src_id,dest_id);
          break;
        end
      end
    end
  end
end



//PE release after delay by number of element in a row of task graph X task pushing interval // 4x20=80
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
