class apb_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(apb_scoreboard)
  
  uvm_analysis_imp#(apb_transaction, apb_scoreboard) mon_export;
  
  apb_transaction exp_queue[$];
  
  bit [31:0] sc_mem [0:256];
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
    mon_export = new("mon_export", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    foreach(sc_mem[i]) sc_mem[i] = i;
  endfunction
  
  // write task - recives the pkt from monitor and pushes into queue
  function void write(apb_transaction tr);
    //tr.print();
    exp_queue.push_back(tr);
  endfunction 
  
  virtual task run_phase(uvm_phase phase);
    //super.run_phase(phase);
    apb_transaction expdata;
    
    forever begin
      wait(exp_queue.size() > 0);
      expdata = exp_queue.pop_front();
      
      if(expdata.pwrite == apb_transaction::WRITE) begin
        sc_mem[expdata.addr] = expdata.data;
        `uvm_info("APB_SCOREBOARD",$sformatf("------ :: WRITE DATA       :: ------"),UVM_LOW)
        `uvm_info("",$sformatf("Addr: %0h",expdata.addr),UVM_LOW)
        `uvm_info("",$sformatf("Data: %0h",expdata.data),UVM_LOW)        
      end
      else if(expdata.pwrite == apb_transaction::READ) begin
        if(sc_mem[expdata.addr] == expdata.data) begin
          `uvm_info("APB_SCOREBOARD",$sformatf("------ :: READ DATA Match :: ------"),UVM_LOW)
          `uvm_info("",$sformatf("Addr: %0h",expdata.addr),UVM_LOW)
          `uvm_info("",$sformatf("Expected Data: %0h Actual Data: %0h",sc_mem[expdata.addr],expdata.data),UVM_LOW)
        end
        else begin
          `uvm_error("APB_SCOREBOARD","------ :: READ DATA MisMatch :: ------")
          `uvm_info("",$sformatf("Addr: %0h",expdata.addr),UVM_LOW)
          `uvm_info("",$sformatf("Expected Data: %0h Actual Data: %0h",sc_mem[expdata.addr],expdata.data),UVM_LOW)
        end
      end
    end
  endtask 
  
endclass
