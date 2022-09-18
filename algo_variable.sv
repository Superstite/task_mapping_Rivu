
//MTC
//root task mapping variable
int  C[3:0][3:0];
int  D[3:0][3:0];
int cmin[$];
int dmax;  

//child task mapping  variable
int signed C_child[3:0][3:0];
int signed  C_child_i;
int signed  C_child_j;
//Minimum C calculation at every clock
int signed cmin_child=1000; //high value intial

// common variable
int current_mapped_node_x,current_mapped_node_y; 

// STC1
//root task mapping variable
int  C_stc1[3:0][3:0];
int  D_stc1[3:0][3:0];
int cmin_stc1[$];
int dmax_stc1;  

//child task mapping  variable
int signed C_child_stc1[3:0][3:0];
int signed  C_child_i_stc1;
int signed  C_child_j_stc1;
//Minimum C calculation at every clock
int signed cmin_child_stc1=1000; //high value intial

// common variable
int current_mapped_node_x_stc1,current_mapped_node_y_stc1;

// STC2
//root task mapping variable
int  C_stc2[3:0][3:0];
int  D_stc2[3:0][3:0];
int cmin_stc2[$];
int dmax_stc2;  

//child task mapping  variable
int signed C_child_stc2[3:0][3:0];
int signed  C_child_i_stc2;
int signed  C_child_j_stc2;
//Minimum C calculation at every clock
int signed cmin_child_stc2=1000; //high value intial

// common variable
int current_mapped_node_x_stc2,current_mapped_node_y_stc2; 

//STC3
//root task mapping variable
int  C_stc3[3:0][3:0];
int  D_stc3[3:0][3:0];
int cmin_stc3[$];
int dmax_stc3;  

//child task mapping  variable
int signed C_child_stc3[3:0][3:0];
int signed  C_child_i_stc3;
int signed  C_child_j_stc3;
//Minimum C calculation at every clock
int signed cmin_child_stc3=1000; //high value intial

// common variable
int current_mapped_node_x_stc3,current_mapped_node_y_stc3; 
//
logic [31:0] active_cluster;
