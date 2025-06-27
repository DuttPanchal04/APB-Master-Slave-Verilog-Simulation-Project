// Code your testbench here
// or browse Examples
module apb_master_tb;

  reg PCLK, PRESETn, PREADY, PSLVERR, READ_WRITE, transfer;
  reg [7:0] PRDATA_IN, APB_WRITE_DATA, APB_WRITE_PADDR, APB_READ_PADDR;
  wire PSEL, PENABLE, PWRITE;
  wire [7:0] PADDR, PWDATA, PRDATA_OUT;


  apb_master dut(

    .PCLK(PCLK),
    .transfer(transfer),
    .PRESETn(PRESETn),
    .PRDATA_IN(PRDATA_IN),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR),
    .READ_WRITE(READ_WRITE),
    .APB_WRITE_DATA(APB_WRITE_DATA),
    .APB_WRITE_PADDR(APB_WRITE_PADDR),
    .APB_READ_PADDR(APB_READ_PADDR),
    .PADDR(PADDR),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .PRDATA_OUT(PRDATA_OUT)

  );

  initial begin

    PCLK = 0;    
    forever #5 PCLK = ~PCLK;

  end

  initial begin

    $monitor("Time = %t | PRESETn = %b | Transfer = %b | READ_WRITE = %b | APB_WRITE_DATA_IN = %b | APB_WRITE_PADDR_IN =%b | APB_READ_PADDR_IN = %b | PADDR_OUT = %b | PSEL = %b | PENABLE = %b | PWRITE_OUT = %b | PWDATA_OUT = %b | PRDATA_IN = %b | PRDATA_OUT = %b | PREADY = %b | Current_state = %b | Next_state = %b", $time, PRESETn, transfer, READ_WRITE, APB_WRITE_DATA, APB_WRITE_PADDR, APB_READ_PADDR, PADDR, PSEL, PENABLE, PWRITE, PWDATA, PRDATA_IN, PRDATA_OUT, PREADY, dut.current_state, dut.next_state);

    // initially make reset and transfer = 0
    PRESETn = 1'b0; transfer = 1'b0; 


    // this input read data will be send from slave to master. here there is no slave. this is just for check
    // PRDATA_IN = 8'haa;

    @(posedge PCLK); PRESETn = 1'b1;

    // testcase for single write operation
    if($test$plusargs("SINGLE_WRITE")) begin

      @(posedge PCLK); transfer = 1'b1;

      @(posedge PCLK);

      @(posedge PCLK); READ_WRITE = 1'b1; APB_WRITE_DATA = 8'haa; APB_WRITE_PADDR = 8'h01;

      @(posedge PCLK); PREADY = 1'b1;
      @(posedge PCLK);

      @(posedge PCLK); transfer = 1'b0; PREADY = 1'b0;

    end

    // testcase for single read operation. 
    // here you will get receive data (PRDATA_OUT) as X because it will be send by Slave (RAM). here slave is not include.
    if ($test$plusargs("SINGLE_READ")) begin

      @(posedge PCLK); transfer = 1'b1;

      @(posedge PCLK);

      @(posedge PCLK); READ_WRITE = 1'b0; APB_READ_PADDR = 8'h01;

      @(posedge PCLK); PREADY = 1'b1;
      @(posedge PCLK);

      @(posedge PCLK); transfer = 1'b0; PREADY = 1'b0;

    end

    // trying to writing into slave when pready is low
    if($test$plusargs("WRITE_AT_PREADY_LOW")) begin

      @(posedge PCLK); transfer = 1'b1;

      @(posedge PCLK);

      @(posedge PCLK); READ_WRITE = 1'b1; APB_WRITE_DATA = 8'haa; APB_WRITE_PADDR = 8'h01;

      @(posedge PCLK);

      @(posedge PCLK); transfer = 1'b0; PREADY = 1'b0;

    end

    // trying to read data from slave when pready is low
    if ($test$plusargs("READ_AT_PREADY_LOW")) begin

      @(posedge PCLK); transfer = 1'b1;

      @(posedge PCLK);

      @(posedge PCLK); READ_WRITE = 1'b0; APB_READ_PADDR = 8'h01;

      @(posedge PCLK);

      @(posedge PCLK); transfer = 1'b0; PREADY = 1'b0;

    end

    // when psel at low and pready high then?
    /*
    if($test$plusargs("PSEL_LOW_AND_PREADY_HIGH")) begin

      @(posedge PCLK); transfer = 1'b1;

      @(posedge PCLK);

      @(posedge PCLK); READ_WRITE = 1'b1; APB_WRITE_DATA = 8'haa; APB_WRITE_PADDR = 8'h01;

      @(posedge PCLK); PREADY = 1'b1;
      @(posedge PCLK);

      @(posedge PCLK); transfer = 1'b0; PREADY = 1'b0;

    end
    */

    // When Transfer is permenently at low.
    if($test$plusargs("TRANSFER_LOW")) begin

      @(posedge PCLK); transfer = 1'b0;

      @(posedge PCLK);

      @(posedge PCLK); READ_WRITE = 1'b1; APB_WRITE_DATA = 8'haa; APB_WRITE_PADDR = 8'h01;

      @(posedge PCLK); PREADY = 1'b1;
      @(posedge PCLK);

      @(posedge PCLK); PREADY = 1'b0;

    end

    // check reset functionality
    if ($test$plusargs("RST_CHECK")) begin

      @(posedge PCLK); transfer = 1'b1;

      @(posedge PCLK);

      @(posedge PCLK); READ_WRITE = 1'b1; APB_WRITE_DATA = 8'haa; APB_WRITE_PADDR = 8'h01;

      @(posedge PCLK); PRESETn = 1'b0; // reset here before pready becomes high, data will not send to slave.

      @(posedge PCLK); PREADY = 1'b1;
      @(posedge PCLK);

      @(posedge PCLK); transfer = 1'b0; PREADY = 1'b0;

    end

    // Random address and data for write/read
    if ($test$plusargs("RANDOM_WRITE")) begin

      @(posedge PCLK); transfer = 1'b1;

      @(posedge PCLK);

      @(posedge PCLK); READ_WRITE = $random; APB_WRITE_DATA = $random; APB_WRITE_PADDR = $random;

      @(posedge PCLK); PREADY = 1'b1;
      @(posedge PCLK);

      @(posedge PCLK); transfer = 1'b0; PREADY = 1'b0;

    end

    if($test$plusargs("WRITE_CONT")) begin

      // 1st
      @(posedge PCLK); transfer = 1'b1;
      @(posedge PCLK);

      @(posedge PCLK); READ_WRITE = 1'b1; APB_WRITE_DATA = 8'haa; APB_WRITE_PADDR = 8'h01;

      @(posedge PCLK); PREADY = 1'b1;
      @(posedge PCLK);

      @(posedge PCLK); PREADY = 1'b0;


      // 2nd
      @(posedge PCLK); APB_WRITE_DATA = 8'hbb; APB_WRITE_PADDR = 8'h02;

      @(posedge PCLK); PREADY = 1'b1;
      @(posedge PCLK);

      @(posedge PCLK); PREADY = 1'b0;

      // 3rd
      @(posedge PCLK); APB_WRITE_DATA = 8'hcc; APB_WRITE_PADDR = 8'h03;

      @(posedge PCLK); PREADY = 1'b1;
      @(posedge PCLK);

      @(posedge PCLK); PREADY = 1'b0;

    end

    #10; $finish;

  end

endmodule