// Code your testbench here
// or browse Examples
module apb_slave_tb;

  reg PCLK;
  reg RSTN;
  reg PWRITE;
  reg PSEL;
  reg PENABLE;
  reg [7:0] PADDR;
  reg [7:0] PWDATA;
  wire [7:0] PRDATA;
  wire PREADY;
  wire PSLVERR;

  apb_slave dut(

    .PCLK(PCLK),
    .RSTN(RSTN),
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PENABLE(PENABLE),
    .PSLVERR(PSLVERR)

  );

  integer i;

  // clock gen
  initial begin

    PCLK = 0;
    forever #5 PCLK = ~PCLK;

  end

  initial begin

    $dumpfile("test_apb_slave.vcd");
    $dumpvars(0, apb_slave_tb);

    // monitoring everything
    $monitor("Time = %t | RSTN = %b | PSEL = %b | PENABLE = %b | PWRITE = %b | PADDR = %b | Invalid_Addr = %b | PWDATA = %b | @%b = %b | PREADY = %b | PRDATA = %b | PSLVERR = %b | Protocol_error = %b | CURRENT_STATE = %b | NEXT_STATE = %b", $time, RSTN, PSEL, PENABLE, PWRITE, PADDR, dut.invalid_addr, PWDATA, PADDR, dut.mem[PADDR], PREADY, PRDATA, PSLVERR, dut.protocol_error, dut.current_state, dut.next_state);

    // initially
    RSTN = 1'b0;
    PSEL = 1'b0; PENABLE = 1'b0;

    @(posedge PCLK); RSTN = 1;


    // Check default memory locations or uninitialized memory
    if ($test$plusargs("DEF_MEM_LOC")) begin

      for( i=0; i<256; i=i+1 ) begin

        $display("@%0b => Data = %0b", i, dut.mem[i]);

      end

    end

    @(posedge PCLK); // to initialize our state machine into IDLE state


    // write continuesly one after another at different memory addresses

    if( $test$plusargs("WRITE_CONT") ) begin

      @(posedge PCLK); PSEL = 0; PENABLE = 0; // idle phase

      // 1st write/transfer
      @(posedge PCLK); PSEL = 1; PWRITE = 1; PADDR = 8'hCA; PWDATA = 8'h55; // setup phase

      @(posedge PCLK); PENABLE = 1; // enable phase

      wait(PREADY==1'b1); // master should wait for slave ready before any transfer

      @(posedge PCLK); PENABLE = 0; // once transfer is completed, PSEL and PENABLE should be de-asserted, and state will be going to setup phase for new transfer.

      // 2nd write/transfer
      @(posedge PCLK); PWRITE = 1; PADDR = 8'h37; PWDATA = 8'hAA; 

      @(posedge PCLK); PENABLE = 1; 

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0;

      // 3rd write/transfer
      @(posedge PCLK); PWRITE = 1; PADDR = 8'hB1; PWDATA = 8'h0F; 

      @(posedge PCLK); PENABLE = 1; 

      wait(PREADY==1'b1);

      @(posedge PCLK); PSEL = 0; PENABLE = 0;

    end

    // read continuosly one after another at different memory addresses (first WRITE_CONT and then run this for proper verify)
    if($test$plusargs("READ_CONT")) begin

      @(posedge PCLK); PSEL = 0; PENABLE = 0; // idle

      // 1st reed/transfer
      @(posedge PCLK); PSEL = 1; PWRITE = 0; PADDR = 8'hCA; // setup phase

      @(posedge PCLK); PENABLE = 1; // enable phase

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0; // once one transfer is completed, PSEL and PENABLE should be de-asserted, and state will be going to setup phase for new transfer.

      // 2nd readd/transfer
      @(posedge PCLK); PWRITE = 0; PADDR = 8'h37; 
      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0;

      // 3rd read/tranfer
      @(posedge PCLK); PWRITE = 0; PADDR = 8'h07; 
      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0;

      // 4th read/tranfer
      @(posedge PCLK); PWRITE = 0; PADDR = 8'hB1; 
      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PSEL = 0; PENABLE = 0;

    end

    // Burst write testcase (back to back write without deasserting penable)
    if ($test$plusargs("BURST_WRITE_INVALID")) begin

      // Idle phase
      @(posedge PCLK); PSEL = 0; PENABLE = 0;

      // First Write Transfer
      @(posedge PCLK); PSEL = 1; PWRITE = 1; PADDR = 8'h20; PWDATA = 8'hAB; PENABLE = 0; // setup
      
      @(posedge PCLK); PENABLE = 1; // enable phase
      
      // Next SETUP phase is skipped, PENABLE remains HIGH

      // Second Write Transfer (invalid)
      @(posedge PCLK); PADDR = 8'h21; PWDATA = 8'hCD; // Without de-asserting PENABLE
      
      @(posedge PCLK); PADDR = 8'h22; PWDATA = 8'hEF;

    end


    // check for no transfer - continue togglig psel but penable is always at low. fsm should be only in setup phase, should not go to enable phase.
    if ($test$plusargs("NO_XFER_PSEL_ONLY")) begin

      @(posedge PCLK); PSEL = 0; PENABLE = 0; PWRITE = 0;

      @(posedge PCLK); PSEL = 1; PADDR = 8'h50; PWDATA = 8'hAA; PWRITE = 1;
      
      @(posedge PCLK); PSEL = 0; 

      repeat (3) @(posedge PCLK);

    end


    // testcase for random address, random write data, pwrite=1 (write data).
    if( $test$plusargs("WRITE_RANDOM") ) begin

      @(posedge PCLK); PSEL = 0; PENABLE = 0; // idle phase

      // 1st write/transfer
      @(posedge PCLK); PSEL = 1; PWRITE = 1; PADDR = $random; PWDATA = $random; // setup phase

      @(posedge PCLK); PENABLE = 1; // enable phase

      wait(PREADY==1'b1); // master should wait for slave ready before any transfer

      @(posedge PCLK); PENABLE = 0; // once transfer is completed, PSEL and PENABLE should be de-asserted, and state will be going to setup phase for new transfer.

      // 2nd write/transfer
      @(posedge PCLK); PWRITE = 1; PADDR = $random; PWDATA = $random; 

      @(posedge PCLK); PENABLE = 1; 

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0;

      // 3rd write/transfer
      @(posedge PCLK); PWRITE = 1; PADDR = $random; PWDATA = $random; 

      @(posedge PCLK); PENABLE = 1; 

      wait(PREADY==1'b1);

      @(posedge PCLK); PSEL = 0; PENABLE = 0;

    end


    // To check PSLVERR when master tries to write data on unexits or out-of-the-range memory address
    // Valid address from: 05H to F1H.

    if ($test$plusargs("PSLVERR_AT_WRITE")) begin

      @(posedge PCLK); PSEL = 0; PENABLE = 0; 

      @(posedge PCLK); PSEL = 1; PWRITE = 1; PADDR = 8'hCA; PWDATA = 8'b01010101; 

      @(posedge PCLK); PENABLE = 1; 

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0; 

      @(posedge PCLK); PWRITE = 1; PADDR = 8'h37; PWDATA = 8'b10101010;

      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0;

      // i give invalid or out-of-range address, so it should give PSLVERR = 1
      @(posedge PCLK); PWRITE = 1; PADDR = 8'hFF; PWDATA = 8'b10101010;

      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0;

      // simulation stops here, because once invalid address found, it stops future transfer

      // valid
      @(posedge PCLK); PWRITE = 1; PADDR = 8'hB1; PWDATA = 8'b00001111;

      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0;

      // again inavalid address, so PSLVERR = 1

      @(posedge PCLK); PWRITE = 1; PADDR = 8'h01; PWDATA = 8'b10101010;

      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PSEL = 0; PENABLE = 0;

    end


    // To check PSLVERR when master tries to read data from unexit or out-of-the-range memory address
    // Valid address from: 05H to F1H.
    if ($test$plusargs("PSLVERR_AT_READ")) begin

      @(posedge PCLK); PSEL = 0; PENABLE = 0; 

      @(posedge PCLK); PSEL = 1; PWRITE = 0; PADDR = 8'hCA; 
      @(posedge PCLK); PENABLE = 1; 

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0; 

      @(posedge PCLK); PWRITE = 0; PADDR = 8'h37;

      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0;

      // read from invalid address, so it should give PSLVERR =1
      @(posedge PCLK); PWRITE = 0; PADDR = 8'hFF;

      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0;

      // again invalid address so slave erorr
      @(posedge PCLK); PWRITE = 0; PADDR = 8'h01;

      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0;

      @(posedge PCLK); PWRITE = 0; PADDR = 8'hB1;

      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PSEL = 0; PENABLE = 0;

    end


    // Write with PENABLE = 1 in SETUP phase (protocol violation) ( Generate PSLVERR, go to IDLE state, display error) (output changes at next edges and writing operation still continues )

    if($test$plusargs("RST_CHECK")) begin

      @(posedge PCLK); PSEL = 0; PENABLE = 0;

      // Setup phase
      @(posedge PCLK); PSEL = 1; PWRITE = 1; PADDR = 8'b11001010; PWDATA = 8'b01010101;

      // Enable phase
      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0; PADDR = 8'b00110111; PWDATA = 8'b10101010;

      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);

      @(posedge PCLK); PENABLE = 0; PADDR = 8'b10110001; PWDATA = 8'b00001111;

      @(posedge PCLK); PENABLE = 1;

      wait(PREADY==1'b1);


      // checking memory after write and before reset
      for(i = 0; i < 256; i = i + 1) begin
        $display("@%0h => Data = %0h", i, dut.mem[i]);
      end

      // now making reset low
      @(posedge PCLK); RSTN = 0;
      @(posedge PCLK);

      // check memory data after reset
      for(i = 0; i < 256; i = i + 1) begin
        $display("@%0h => Data = %0h", i, dut.mem[i]);
      end


      @(posedge PCLK); RSTN = 1;

    end


    // Check all final memory address data
    if ($test$plusargs("FINAL_MEM")) begin

      for( i=0; i<256; i=i+1 ) begin

        $display("@%0b => Data = %0b", i, dut.mem[i]);

      end

    end


    // Trying to writing data into memory when PENABLE = 1 at IDLE Phase


    if ($test$plusargs("WRITE_PENAB1_AT_IDLE")) begin

      @(posedge PCLK); PSEL = 0; PENABLE = 0;

      // Protocol violation: PENABLE = 1 too early
      @(posedge PCLK); PSEL = 1; PENABLE = 1; PWRITE = 1; PWDATA = 8'b01010101; PADDR = 8'b11001010;

      // Next cycles should be ignored if protocol_error is set
      @(posedge PCLK); PADDR = 8'b00110111; PWDATA = 8'b10101010;

      @(posedge PCLK); PADDR = 8'b10110001; PWDATA = 8'b00001111;

      @(posedge PCLK); 
    end


    // Trying to reading data from memory when PENABLE = 1 at Setup Phase

    if ($test$plusargs("READ_PENAB1_AT_IDLE")) begin

      // idle phase
      @(posedge PCLK); PSEL = 0; PENABLE = 0;

      // setup phase where i give psel=1 and penable also high. (protocol violation) so it should make protocol_error = 1 and stops write/read operation on next clock edge.
      // bug: still allow write for one clock
      @(posedge PCLK); PSEL = 1; PENABLE = 1; PWRITE = 0; PADDR = 8'b11001010;

      //$fatal("Protocol Error: PENABLE high in setup phase!");

      // now protocol_error = 1, and it will stops write/read operation from now.
      @(posedge PCLK); PADDR = 8'b00110111;

      @(posedge PCLK); PADDR = 8'b10110001;

      @(posedge PCLK); 

    end


    @(posedge PCLK); $finish;

  end

endmodule