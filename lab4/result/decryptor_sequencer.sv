class decryptor_transaction extends uvm_sequence_item;
	
	logic [7:0] pre_length        ,          // bytes before first character in message
			  msg_padded2[64]   ,		   // original message, plus pre- and post-padding
			  msg_crypto2[64]   ,          // encrypted message according to the DUT
			  msg_decryp2[64]   ;          // recovered decrypted message from DUT
  logic [5:0] LFSR_ptrn[6]      ,		   // 6 possible maximal-length 6-bit LFSR tap ptrns
			  LFSR_init         ,		   // NONZERO starting state for LFSR		   
			  lfsr_ptrn         ,          // one of 6 maximal length 6-tap shift reg. ptrns
			  lfsr2[64]         ;          // states of program 2 decrypting LFSR         
	
	string     str2;
	//    = "Mr_Watson_come here_I_want_to_see_you_my_aide";	// 1st program 1 input
	//  string     str2  = "Knowledge comes, but wisdom lingers.     ";	// program 2 output
	//  string     str2  = "                                         ";	// program 2 output
	//  string     str2  = "  01234546789abcdefghijklmnopqrstuvwxyz. ";	// 2nd program 1 input
	//  string     str2  = "            A joke is a very serious thing.";	// program 3 output
	int str_len                   ;		   // length of string (character count)
	// displayed encrypted string will go here:
	string     str_enc2[64]       ;          // decryption program input
	string     str_dec2[64]       ;          // decrypted string will go here
	int ct                        ;
	int lk                        ;		   // counts leading spaces for program 3
	int pat_sel                   ;          // LFSR pattern select
	
	string     out;

	function new(string name = "");
		super.new(name);
	endfunction: new


  `uvm_object_utils_begin(decryptor_transaction)
  //`uvm_field_array_int(msg_crypto2, UVM_ALL_ON)
  //`uvm_field_int(LFSR_ptrn,UVM_ALL_ON)
  `uvm_field_int(LFSR_init, UVM_ALL_ON)
  `uvm_field_int(pre_length, UVM_ALL_ON)
  `uvm_field_string(str2, UVM_ALL_ON)
     `uvm_object_utils_end
  
  
  
endclass: decryptor_transaction

class decryptor_sequence extends uvm_sequence#(decryptor_transaction);
	`uvm_object_utils(decryptor_sequence)

	function new(string name = "");
		super.new(name);
	endfunction: new

	task body();
		decryptor_transaction dc_tx;
		
      repeat(3) begin
		dc_tx = decryptor_transaction::type_id::create(.name("dc_tx"), .contxt(get_full_name()));

		start_item(dc_tx);
		
		// Add the string here

		dc_tx.str2 = "Thank_you_Prof_Eldon_and_Xinyue";
		dc_tx.str_len = dc_tx.str2.len;
		
		dc_tx.LFSR_ptrn[0] = 6'h21;
		dc_tx.LFSR_ptrn[1] = 6'h2D;
		dc_tx.LFSR_ptrn[2] = 6'h30;
		dc_tx.LFSR_ptrn[3] = 6'h33;
		dc_tx.LFSR_ptrn[4] = 6'h36;
		dc_tx.LFSR_ptrn[5] = 6'h39;
          
         //dc_tx.pre_length = 10;
         dc_tx.pre_length = $urandom_range(8,11);
		
		if(dc_tx.pre_length < 7) begin
      			$display("illegal preamble length chosen, overriding with 8");
      			dc_tx.pre_length =  8;                     // override < 6 with a legal value
    	end  
    	else
      		$display("preamble length = %d",dc_tx.pre_length);
// select LFSR tap pattern
// ***** choose any value < 6 *****
//     	dc_tx.pat_sel                       =  2;
          dc_tx.pat_sel = $urandom_range(0,5);
        $display("Random Pattern Selected is:", dc_tx.pat_sel);
    	if(dc_tx.pat_sel > 5) begin 
      		$display("illegal pattern select chosen, overriding with 3");
      		dc_tx.pat_sel = 3;                         // overrides illegal selections
    	end  
    	else
          $display("Pattern Selected is Legal");
// set starting LFSR state for program -- 
// ***** choose any 6-bit nonzero value *****
//     	dc_tx.LFSR_init = 6'h01;                     // for program 2 run
        dc_tx.LFSR_init = $urandom_range(0,63);
    	if(!dc_tx.LFSR_init) begin
      		$display("illegal zero LFSR start pattern chosen, overriding with 6'h01");
      		dc_tx.LFSR_init = 6'h01;                   // override 0 with a legal (nonzero) value
    	end
    	else
      		$display("LFSR starting pattern = %b",dc_tx.LFSR_init);
    		$display("original message string length = %d",dc_tx.str_len);
          for(dc_tx.lk = 0; dc_tx.lk<dc_tx.str_len; dc_tx.lk++)
      		if(dc_tx.str2[dc_tx.lk]==8'h5f) continue;	       // count leading _ chars in string
	  		else break;                          // we shall add these to preamble pad length
			$display("embedded leading underscore count = %d",dc_tx.lk);
// precompute encrypted message
		dc_tx.lfsr_ptrn = dc_tx.LFSR_ptrn[dc_tx.pat_sel];        // select one of the 6 permitted tap ptrns ptrns
          $display("LFSR Pattern", dc_tx.lfsr_ptrn);
		dc_tx.lfsr2[0]     = dc_tx.LFSR_init;              // any nonzero value (zero may be helpful for debug)
    $display("run encryption of this original message: ");
    $display("%s",dc_tx.str2)        ;           // print original message in transcript window
    $display();
    $display("LFSR_ptrn = %h, LFSR_init = %h %h",dc_tx.lfsr_ptrn,dc_tx.LFSR_init,dc_tx.lfsr2[0]);
    for(int j=0; j<64; j++) 			   // pre-fill message_padded with ASCII _ characters
      dc_tx.msg_padded2[j] = 8'h5f;         
    for(int l=0; l<dc_tx.str_len; l++)  		   // overwrite up to 60 of these spaces w/ message itself
	  dc_tx.msg_padded2[dc_tx.pre_length+l] = byte'(dc_tx.str2[l]); 
// compute the LFSR sequence
    for (int ii=0;ii<63;ii++) begin :lfsr_loop
      dc_tx.lfsr2[ii+1] = (dc_tx.lfsr2[ii]<<1)+(^(dc_tx.lfsr2[ii]&dc_tx.lfsr_ptrn));//{LFSR[6:0],(^LFSR[5:3]^LFSR[7])};		   // roll the rolling code
      $display("lfsr_ptrn %d = %h",ii,dc_tx.lfsr2[ii]);
    end	  :lfsr_loop
// encrypt the message
    for (int i=0; i<64; i++) begin		   // testbench will change on falling clocks
      dc_tx.msg_crypto2[i]        = dc_tx.msg_padded2[i] ^ dc_tx.lfsr2[i];  //{1'b0,LFSR[6:0]};	   // encrypt 7 LSBs
      dc_tx.str_enc2[i]           = string'(dc_tx.msg_crypto2[i]);
    end
		$display("here is the original message with _ preamble padding");
        for(int jj=0; jj<64; jj++)
          $write("%s",dc_tx.msg_padded2[jj]);
        $display("\n");
          
          $display("here is the padded and encrypted pattern in ASCII in encrypted bits format");
          for(int jzj=0; jzj<64; jzj++)
            $write(dc_tx.msg_crypto2[jzj]);
          
        $display("here is the padded and encrypted pattern in ASCII");
        for(int jj=0; jj<64; jj++)
          $write("%s",dc_tx.str_enc2[jj]);
        $display("\n");
        $display("here is the padded pattern in hex"); 
        for(int jj=0; jj<64; jj++)
          $write(" %h",dc_tx.msg_padded2[jj]);
        $display("\n");
		
		
		
		// assert(sa_tx.randomize());
		//`uvm_info("sa_sequence", sa_tx.sprint(), UVM_LOW);
		finish_item(dc_tx);
		end
	endtask: body
endclass: decryptor_sequence

typedef uvm_sequencer#(decryptor_transaction) decryptor_sequencer;