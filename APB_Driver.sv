class apb_driver extends uvm_driver#(apb_transaction);
  
  `uvm_component_utils(apb_driver)
  
  virtual dut_if vif;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_if)::get(this,"","vif",vif)) begin
      `uvm_error("build_phase","driver virtual interface failed")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    this.vif.master_cb.psel    <= 0;
    this.vif.master_cb.penable <= 0;

    forever begin
      apb_transaction tr;
      @ (this.vif.master_cb);
      //First get an item from sequencer
      seq_item_port.get_next_item(tr);
      @ (this.vif.master_cb);
      uvm_report_info("APB_DRIVER ", $psprintf("Got Transaction %s",tr.convert2string()));
      //Decode the APB Command and call either the read/write function
      case (tr.pwrite)
        apb_transaction::READ:  drive_read(tr.addr, tr.data);  
        apb_transaction::WRITE: drive_write(tr.addr, tr.data);
      endcase
      //Handshake DONE back to sequencer
      seq_item_port.item_done();
    end
  endtask
  
  virtual protected task drive_read(input  bit   [31:0] addr, output logic [31:0] data);
    this.vif.master_cb.paddr   <= addr;
    this.vif.master_cb.pwrite  <= 0;
    this.vif.master_cb.psel    <= 1;
    @ (this.vif.master_cb);
    this.vif.master_cb.penable <= 1;
    @ (this.vif.master_cb);
    data = this.vif.master_cb.prdata;
    this.vif.master_cb.psel    <= 0;
    this.vif.master_cb.penable <= 0;
  endtask

  virtual protected task drive_write(input bit [31:0] addr, input bit [31:0] data);
    this.vif.master_cb.paddr   <= addr;
    this.vif.master_cb.pwdata  <= data;
    this.vif.master_cb.pwrite  <= 1;
    this.vif.master_cb.psel    <= 1;
    @ (this.vif.master_cb);
    this.vif.master_cb.penable <= 1;
    @ (this.vif.master_cb);
    this.vif.master_cb.psel    <= 0;
    this.vif.master_cb.penable <= 0;
  endtask

endclass
