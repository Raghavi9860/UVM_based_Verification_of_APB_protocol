class apb_transaction extends uvm_sequence_item;
  
  `uvm_object_utils(apb_transaction)
  
  //typedef for READ/Write transaction type
  typedef enum {READ, WRITE} kind_e;
  rand bit   [31:0] addr;      //Address
  rand bit [31:0] data;     //Data - For write or read response
  rand kind_e  pwrite;       //command type
  
  constraint c1{addr[31:0]>=32'd0; addr[31:0] <32'd256;};
  constraint c2{data[31:0]>=32'd0; data[31:0] <32'd256;};
  
  function new (string name = "apb_transaction");
    super.new(name);
  endfunction
  
  function string convert2string();
    return $psprintf("pwrite=%s paddr=%0h data=%0h",pwrite,addr,data);
  endfunction
  
endclass
