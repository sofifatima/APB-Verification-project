class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)
  
  apb_sequencer sqr;
  apb_driver   drv;
  apb_monitor  mon;
  
  
  
  //constructor
  function new(string name = "apb_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = apb_sequencer::type_id::create("sqr",this);
    drv = apb_driver::type_id::create("drv",this);
    mon = apb_monitor::type_id::create("mon",this);
  endfunction
  
  //connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
    `uvm_info("AGENT",$sformatf("Connected Sequencer to Driver"),UVM_LOW)
  endfunction
endclass
