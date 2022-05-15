class apb_subscriber extends uvm_subscriber#(apb_transaction);
  
  `uvm_component_utils(apb_subscriber)
  
  bit [31:0] addr;
  bit [31:0] data;
  
  covergroup cover_bus;
    coverpoint addr {
      bins a[16] = {[0:255]};
    }
    coverpoint data {
      bins d[16] = {[0:255]};
    }
  endgroup
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
    cover_bus=new;
  endfunction
  
  function void write(apb_transaction t);
    `uvm_info("APB_SUBSCRIBER", $psprintf("Subscriber received tx %s", t.convert2string()), UVM_NONE);
   
    addr    = t.addr;
    data    = t.data;
    cover_bus.sample();
  endfunction
  
endclass
