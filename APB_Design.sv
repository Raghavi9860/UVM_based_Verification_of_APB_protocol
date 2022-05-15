interface dut_if;

  logic pclk;
  logic rst_n;
  logic [31:0] paddr;
  logic psel;
  logic penable;
  logic pwrite;
  logic [31:0] pwdata;
  logic pready;
  logic [31:0] prdata;
  
  //Master Clocking block - used for Drivers
  clocking master_cb @(posedge pclk);
    output paddr, psel, penable, pwrite, pwdata;
    input  prdata;
  endclocking: master_cb

  //Slave Clocking Block - used for any Slave BFMs
  clocking slave_cb @(posedge pclk);
     input  paddr, psel, penable, pwrite, pwdata;
     output prdata;
  endclocking: slave_cb

  //Monitor Clocking block - For sampling by monitor components
  clocking monitor_cb @(posedge pclk);
     input paddr, psel, penable, pwrite, prdata, pwdata;
  endclocking: monitor_cb

  modport master(clocking master_cb);
  modport slave(clocking slave_cb);
  modport passive(clocking monitor_cb);

endinterface


module apb_slave(dut_if dif);

  logic [31:0] mem [0:256];
  logic [1:0] apb_st;
  const logic [1:0] SETUP=0;
  const logic [1:0] W_ENABLE=1;
  const logic [1:0] R_ENABLE=2;
  
  always @(posedge dif.pclk or negedge dif.rst_n) begin
    if (dif.rst_n==0) begin
      apb_st <=0;
      dif.prdata <=0;
      dif.pready <=1;
      for(int i=0;i<256;i++) mem[i]=i;
    end
    else begin
      case (apb_st)
        SETUP: begin
          dif.prdata <= 0;
          if (dif.psel && !dif.penable) begin
            if (dif.pwrite) begin
              apb_st <= W_ENABLE;
            end
            else begin
              apb_st <= R_ENABLE;
              dif.prdata <= mem[dif.paddr];
            end
          end
        end
        W_ENABLE: begin
          if (dif.psel && dif.penable && dif.pwrite) begin
            mem[dif.paddr] <= dif.pwdata;
          end
          apb_st <= SETUP;
        end
        R_ENABLE: begin
          apb_st <= SETUP;
        end
      endcase
    end
  end
/*
  always @(posedge dif.clock)
  begin
    `uvm_info("", $sformatf("DUT received cmd=%b, addr=%d, data=%d",
                            dif.cmd, dif.addr, dif.data), UVM_MEDIUM)
  end
*/  
endmodule
