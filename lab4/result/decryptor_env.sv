class decryptor_env extends uvm_env;
	`uvm_component_utils(decryptor_env)

	decryptor_agent dc_agent;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		dc_agent	= decryptor_agent::type_id::create(.name("dc_agent"), .parent(this));
		//dc_sb		= decryptor_scoreboard::type_id::create(.name("dc_sb"), .parent(this));
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		//dc_agent.agent_ap.connect(dc_sb.sb_export_before);
		//dc_agent.agent_ap_after.connect(dc_sb.sb_export_after);
	endfunction: connect_phase
endclass: decryptor_env