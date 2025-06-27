module apb_slave(

  input RSTN, 
  input PCLK,
  input PWRITE,
  input PSEL,
  input PENABLE,
  input [7:0] PADDR,
  input [7:0] PWDATA,
  output reg PREADY,
  output reg [7:0] PRDATA,
  output reg PSLVERR

);

  // memory array (256 locations of 8-bit)
  reg [7:0] mem [0:255];

  // FSM state variables
  reg [1:0] current_state, next_state;

  parameter [1:0] IDLE = 0,
  SETUP = 1,
  ENABLE = 2;

  // invalid address condition
  wire invalid_addr;
  assign invalid_addr = ((PADDR > 8'hF1) || (PADDR < 8'h05));

  // protocol violation variable
  wire  protocol_error;
  assign protocol_error = (current_state == IDLE && PENABLE) || (current_state == SETUP && PENABLE && !PSEL) || (!PSEL && PENABLE);

  integer k;

  // state changing when high reset and no protocol erorr
  always @(posedge PCLK) begin

    if (!RSTN) begin

      current_state <= IDLE;

    end

    else if (!protocol_error) begin

      current_state <= next_state; // freeze state on error

    end 

    else begin

      current_state <= IDLE; // recover to IDLE on error

    end

  end

  // fsm next state logic
  always @(*) begin

    next_state = current_state;

    case (current_state)

      // if PSEL is high and PENABLE is low, then it should go in setup phase
      IDLE: next_state = (PSEL && !PENABLE) ? SETUP : IDLE;

      // If PSEL is high and PENABLE is high, then it should go into enable phase 
      SETUP: next_state = (PSEL && PENABLE) ? ENABLE : SETUP;

      // if all PSEL, PENABLE, AND PREADY is high, then it should go into setup phase for new transfer. PENABLE and PSEL should be de-asserted after one transfer is completed in enable phase.
      ENABLE: next_state = (PSEL && PENABLE && PREADY) ? SETUP : ENABLE;

      default: next_state = IDLE;

    endcase

  end

  // Memory read/write + PREADY + PSLVERR logic
  always @(posedge PCLK or negedge RSTN) begin

    // if reset is low, then clear all memory data and make PREADY, PRDATA, and PSLVERR at low.
    if (!RSTN) begin

      for (k = 0; k < 256; k = k + 1) begin

        mem[k] <= 8'h00;

      end

      PREADY <= 1'b0;
      PRDATA <= 8'h00;
      PSLVERR <= 1'b0;

    end

    else begin

      // default values
      PREADY <= 1'b0;
      PRDATA <= 8'h00;
      PSLVERR <= 1'b0;

      // if protocol_eroror comes, make pready and pslverr high
      if (protocol_error) begin

        PREADY   <= 1'b1;  
        PSLVERR  <= 1'b1;

      end 

      // enable phase
      else if (current_state==ENABLE) begin

        // if invalid address is found, then pready should be high, and slave error get, and no memory access. and make invalid_addr = 1
        if (invalid_addr) begin

          PREADY  <= 1'b1;
          PSLVERR <= 1'b1;

        end

        else begin

          PREADY  <= 1'b1;
          PSLVERR <= 1'b0;

          // if pwrite = 1, then write operation, otherwise read operation.
          if (PWRITE) begin

            mem[PADDR] <= PWDATA; 

          end

          else begin

            PRDATA <= mem[PADDR]; 

          end

        end
      end
    end
  end


endmodule
