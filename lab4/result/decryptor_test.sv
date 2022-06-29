class decryptor_test extends uvm_test;
		`uvm_component_utils(decryptor_test)

		decryptor_env dc_env;
  		decryptor_sequence dc_seq;

		function new(string name, uvm_component parent);
			super.new(name, parent);
		endfunction: new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			dc_env = decryptor_env::type_id::create(.name("dc_env"), .parent(this));
            dc_seq = decryptor_sequence::type_id::create(.name("dc_seq"), .contxt(get_full_name()));
		endfunction: build_phase

		task run_phase(uvm_phase phase);
            super.run_phase(phase);
			phase.raise_objection(.obj(this));
			dc_seq.start(dc_env.dc_agent.dc_seqr);
			phase.drop_objection(.obj(this));
		endtask: run_phase
endclass: decryptor_test