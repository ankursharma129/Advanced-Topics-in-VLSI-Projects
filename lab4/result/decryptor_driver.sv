class decryptor_driver extends uvm_driver#(decryptor_transaction);
	`uvm_component_utils(decryptor_driver)

	virtual decryptor_bfm bfm;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new
  uvm_analysis_port#(decryptor_transaction) drv_port;

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual decryptor_bfm)::read_by_name
			(.scope("ifs"), .name("decryptor_bfm"), .val(bfm)));
      drv_port = new("drv_port",this);
	endfunction: build_phase

	task run_phase(uvm_phase phase);
      super.run_phase(phase);
		drive();
	endtask: run_phase

	virtual task drive();
		decryptor_transaction dc_tx;
      	
		forever begin
			seq_item_port.get_next_item(dc_tx);
          	dc_tx.print();
			repeat(5) @(posedge bfm.clk);
			for(int qp=0; qp<64; qp++) begin
			  @(posedge bfm.clk);
			  bfm.wr_en   <= 'b1;                   // turn on memory write enable
			  bfm.waddr   <= qp+64;                 // write encrypted message to mem [64:127]
			  bfm.data_in <= dc_tx.msg_crypto2[qp];  // deryptor transaction has message
              //$display("Data in", dc_tx.msg_crypto2[qp]);
			end
			@(posedge bfm.clk)
				bfm.wr_en   <= 'b0; 
			@(posedge bfm.clk) 
				bfm.init <= 0;
          repeat(1) @(posedge bfm.clk);
          	wait(bfm.done === 1'b1);
            for(int nn=0; nn<64; nn++)			   // count leading underscores
              if(dc_tx.str2[nn]==8'h5f) dc_tx.ct++; 
              else break;
            $display("ct = %d",dc_tx.ct);
            for(int n=0; n<dc_tx.str_len+1; n++) begin
              @(posedge bfm.clk);
              bfm.raddr          <= n;
              @(posedge bfm.clk);
              dc_tx.msg_decryp2[n] <= bfm.data_out;
              
            end
            $display("raddr", bfm.raddr);
          $display(dc_tx.msg_decryp2);
          wait(bfm.done === 1'b1);
      		drv_port.write(dc_tx);
			seq_item_port.item_done();
        end
			
	endtask: drive
endclass: decryptor_driver