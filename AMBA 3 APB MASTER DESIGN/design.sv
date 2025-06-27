// Code your design here
module apb_master(

  input PCLK, 
  input transfer, 
  input PRESETn,
  input [7:0] PRDATA_IN,
  input PREADY,
  input PSLVERR,
  input READ_WRITE,

  input [7:0] APB_WRITE_DATA,
  input [7:0] APB_WRITE_PADDR,
  input [7:0] APB_READ_PADDR,

  output reg [7:0] PADDR,
  output reg PSEL,
  output reg PENABLE,
  output reg PWRITE,
  output reg [7:0] PWDATA,
  output reg [7:0] PRDATA_OUT

);

  // fsm state
  parameter [1:0] IDLE = 2'b00,
  SETUP = 2'b01,
  ENABLE = 2'b10;

  reg [1:0] current_state, next_state;


  // state logic
  always @(posedge PCLK or negedge PRESETn) begin

    if(!PRESETn) begin

      current_state <= IDLE;

    end

    else begin

      current_state <= next_state;

    end

  end

  // fsm combinational block for state transition based on input
  always @(*) begin

    case(current_state)

      // in fsm next state transition, we give conditions based on inputs, not output.

      // if transfer = 1, then go for setup phase. and if transfer = 0, then remains in IDLE Phase.
      IDLE: next_state = transfer ? SETUP : IDLE;

      // setup phase remains only for one clock period, then goes to enable phase. (no condition here)
      SETUP: next_state = ENABLE;

      // if pready high, then complete the trasnsfer and go for setup for another transfer. if pready low, then stable in enable phase (wait). if no another transfer needed, make transfer = 0, it will go to IDLE Phase.
      ENABLE: next_state = PREADY ? SETUP : ENABLE;

      default: next_state = IDLE;

    endcase

  end

  always @(posedge PCLK or negedge PRESETn) begin

    // if active low reset, reset all output signals to zero.
    if(!PRESETn) begin

      PSEL <= 1'b0; PENABLE <= 1'b0; PADDR <= 8'h00; PWDATA <= 8'h00; PRDATA_OUT <= 8'h00;

    end

    // otherwise
    else begin

      // if no transfer, again make all output signals low.
      if(!transfer) begin

        PSEL <= 1'b0; PENABLE <= 1'b0; PADDR <= 8'h00; PWDATA <= 8'h00; PRDATA_OUT = 8'h00;

      end

      // if transfer = 1 then,
      else begin

        // if current state is IDLE, make PSEL and PENABLE LOW.
        if(current_state == IDLE) begin

          PSEL = 1'b0; PENABLE = 1'b0;

        end

        // if current state is SETUP, then make PSEL = 1 and PENABLE remains low.
        if(current_state==SETUP) begin

          PSEL <= 1'b1; PENABLE <= 1'b0;

          PWRITE <= READ_WRITE;

          if (READ_WRITE) begin

            PADDR <= APB_WRITE_PADDR;

          end

          else begin

            PADDR <= APB_READ_PADDR;

          end

          PWDATA <= APB_WRITE_DATA;

        end

        // if current state is enable, then provide output after checking condition of pready and read_write. make penable=1;
        if(current_state==ENABLE) begin

          PENABLE <= 1'b1;

          if (PREADY && !READ_WRITE) begin

            PRDATA_OUT <= PRDATA_IN;      

          end

        end

      end

    end

  end


endmodule