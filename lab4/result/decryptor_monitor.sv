class decryptor_monitor extends uvm_monitor;
	`uvm_component_utils(decryptor_monitor)
	int err = 0;

	virtual decryptor_bfm bfm;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new
  uvm_analysis_imp#(decryptor_transaction, decryptor_monitor) mon_ap;

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual decryptor_bfm)::read_by_name
			(.scope("ifs"), .name("decryptor_bfm"), .val(bfm)));
      mon_ap = new("mon_ap", this);
	endfunction: build_phase

	function void write(decryptor_transaction dc_tx); 

    $display("run decryption:");
    for(int nn=0; nn<64; nn++)			   // count leading underscores
      if(dc_tx.str2[nn]==8'h5f) dc_tx.ct++; 
	  else break;
      $display("str2 ", dc_tx.str2, dc_tx.ct, bfm.data_out);
      
    for(int n=0; n<dc_tx.str_len+1; n++) begin
      dc_tx.msg_decryp2[n] <= bfm.data_out[n];
    end
    for(int rr=0; rr<dc_tx.str_len+1; rr++)
      dc_tx.str_dec2[rr] = string'(dc_tx.msg_decryp2[rr]);
      $display("String form of decrypted msg from DUT: %p", dc_tx.str_dec2);
      
      for(int i=0; i<dc_tx.str2.len; i++) begin
        if (dc_tx.str_dec2[i] != dc_tx.str2[i]) err++;
      end
        
      if(err>0)
        `uvm_info(get_full_name(),"WRONG: Output does not match Original String",UVM_LOW)
    else 
      `uvm_info(get_full_name(),"CORRECT: Output matches original string",UVM_LOW)
endfunction: write

endclass: decryptor_monitor