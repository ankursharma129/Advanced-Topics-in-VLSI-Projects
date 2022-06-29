class decryptor_agent extends uvm_agent;
	`uvm_component_utils(decryptor_agent)

	uvm_analysis_port#(decryptor_transaction) agent_ap;

	decryptor_sequencer		dc_seqr;
	decryptor_driver		dc_drvr;
	decryptor_monitor	dc_mon;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		agent_ap	= new(.name("agent_ap"), .parent(this));

		dc_seqr		= decryptor_sequencer::type_id::create(.name("dc_seqr"), .parent(this));
		dc_drvr		= decryptor_driver::type_id::create(.name("dc_drvr"), .parent(this));
		dc_mon	= decryptor_monitor::type_id::create(.name("dc_mon"), .parent(this));
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		dc_drvr.seq_item_port.connect(dc_seqr.seq_item_export);
		//dc_mon.mon_ap.connect(agent_ap);
      dc_drvr.drv_port.connect(dc_mon.mon_ap);
	endfunction: connect_phase
endclass: decryptor_agent