class apb_monitor extends uvm_monitor;

  virtual dut_if vif;

  //Analysis port -parameterized to apb_rw transaction
  ///Monitor writes transaction objects to this port once detected on interface
  uvm_analysis_port#(apb_transaction) ap;

  `uvm_component_utils(apb_monitor)

   function new(string name, uvm_component parent);
     super.new(name, parent);
     ap = new("ap", this);
   endfunction

   //Build Phase - Get handle to virtual if from agent/config_db
   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif)) begin
       `uvm_error("build_phase", "No virtual interface specified for this monitor instance")
       end
   endfunction

   virtual task run_phase(uvm_phase phase);
     super.run_phase(phase);
     forever begin
       apb_transaction tr;
       // Wait for a SETUP cycle
       do begin
         @ (this.vif.monitor_cb);
         end
         while (this.vif.monitor_cb.psel !== 1'b1 ||
                this.vif.monitor_cb.penable !== 1'b0);
         //create a transaction object
         tr = apb_transaction::type_id::create("tr", this);
        
         //populate fields based on values seen on interface
       tr.pwrite = (this.vif.monitor_cb.pwrite) ? apb_transaction::WRITE : apb_transaction::READ;
         tr.addr = this.vif.monitor_cb.paddr;

         @ (this.vif.monitor_cb);
         if (this.vif.monitor_cb.penable !== 1'b1) begin
            `uvm_error("APB", "APB protocol violation: SETUP cycle not followed by ENABLE cycle");
         end
         
       if (tr.pwrite == apb_transaction::READ) begin
         tr.data = this.vif.monitor_cb.prdata;
       end
       else if (tr.pwrite == apb_transaction::WRITE) begin
         tr.data = this.vif.monitor_cb.pwdata;
       end
       
         uvm_report_info("APB_MONITOR", $psprintf("Got Transaction %s",tr.convert2string()));
         //Write to analysis port
         ap.write(tr);
      end
   endtask

endclass
