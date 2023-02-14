module Error_Inject_top
  (input  i_Clk,       // Main Clock
   input  i_Switch_1, 
   input  i_Switch_2,
   input  i_UART_RX,   // UART RX Data
   output o_UART_TX,   // UART TX Data
   // Segment1 is upper digit, Segment2 is lower digit
   output o_Segment1_A,
   output o_Segment1_B,
   output o_Segment1_C,
   output o_Segment1_D,
   output o_Segment1_E,
   output o_Segment1_F,
   output o_Segment1_G,
   //
   output o_Segment2_A,
   output o_Segment2_B,
   output o_Segment2_C,
   output o_Segment2_D,
   output o_Segment2_E,
   output o_Segment2_F,
   output o_Segment2_G,
   output o_LED_1,
   output o_LED_2   
   ); 
 
  wire w_RX_DV;
  wire [7:0] w_RX_Byte;
  wire w_TX_Active, w_TX_Serial;
  wire w_Segment1_A, w_Segment2_A;
  wire w_Segment1_B, w_Segment2_B;
  wire w_Segment1_C, w_Segment2_C;
  wire w_Segment1_D, w_Segment2_D;
  wire w_Segment1_E, w_Segment2_E;
  wire w_Segment1_F, w_Segment2_F;
  wire w_Segment1_G, w_Segment2_G;
   
  // 25,000,000 / 115,200 = 217
  UART_RX #(.CLKS_PER_BIT(217)) UART_RX_Inst
  (.i_Clock(i_Clk),
   .i_RX_Serial(i_UART_RX),
   .o_RX_DV(w_RX_DV),
   .o_RX_Byte(w_RX_Byte));
    
  UART_TX #(.CLKS_PER_BIT(217)) UART_TX_Inst
  (.i_Clock(i_Clk),
   .i_TX_DV(w_RX_DV),      // Pass RX to TX module for loopback
   .i_TX_Byte(connect3),  // Pass RX to TX module for loopback
   .o_TX_Active(w_TX_Active),
   .o_TX_Serial(w_TX_Serial),
   .o_TX_Done());
   
  // Drive UART line high when transmitter is not active
  assign o_UART_TX = w_TX_Active ? w_TX_Serial : 1'b1; 
   
   
  // Binary to 7-Segment Converter for Upper Digit
  Binary_To_7Segment SevenSeg1_Inst
  (.i_Clk(i_Clk),
   .i_Binary_Num(w_RX_Byte[7:4]),
   .o_Segment_A(w_Segment1_A),
   .o_Segment_B(w_Segment1_B),
   .o_Segment_C(w_Segment1_C),
   .o_Segment_D(w_Segment1_D),
   .o_Segment_E(w_Segment1_E),
   .o_Segment_F(w_Segment1_F),
   .o_Segment_G(w_Segment1_G));
    
  assign o_Segment1_A = ~w_Segment1_A;
  assign o_Segment1_B = ~w_Segment1_B;
  assign o_Segment1_C = ~w_Segment1_C;
  assign o_Segment1_D = ~w_Segment1_D;
  assign o_Segment1_E = ~w_Segment1_E;
  assign o_Segment1_F = ~w_Segment1_F;
  assign o_Segment1_G = ~w_Segment1_G;
   
   
  // Binary to 7-Segment Converter for Lower Digit
  Binary_To_7Segment SevenSeg2_Inst
  (.i_Clk(i_Clk),
   .i_Binary_Num(w_RX_Byte[3:0]),
   .o_Segment_A(w_Segment2_A),
   .o_Segment_B(w_Segment2_B),
   .o_Segment_C(w_Segment2_C),
   .o_Segment_D(w_Segment2_D),
   .o_Segment_E(w_Segment2_E),
   .o_Segment_F(w_Segment2_F),
   .o_Segment_G(w_Segment2_G));
   
  assign o_Segment2_A = ~w_Segment2_A;
  assign o_Segment2_B = ~w_Segment2_B;
  assign o_Segment2_C = ~w_Segment2_C;
  assign o_Segment2_D = ~w_Segment2_D;
  assign o_Segment2_E = ~w_Segment2_E;
  assign o_Segment2_F = ~w_Segment2_F;
  assign o_Segment2_G = ~w_Segment2_G;
  
  wire [11:0] connect1; 
  wire [11:0] connect2;
  wire [7:0]  connect3;
  
  reg  r_LED_1    = 1'b0;
  reg  r_LED_2    = 1'b0;
  reg  r_Switch_1 = 1'b0;
  reg  r_Switch_2 = 1'b0;
  wire w_Switch_1;
  wire w_Switch_2;
 
  hamm_enc enc_uart
  (.out(connect1),
   .input_on(r_LED_2),
   .in(w_RX_Byte),
   .reset());
  
  
  hamm_dec dec_UART
  (.out(connect3),
  .input_on(r_LED_2),
   .in(connect2),
   .reset());
   
   Single_Bit_Error error_uart
  (.i_Clock(i_Clk),
   .input_on(r_LED_1),
   .data_in(connect1),
   .data_out(connect2));
   
   Debounce_Switch Debounce_Inst
  (.i_Clk(i_Clk), 
   .i_Switch1(i_Switch_1),
   .o_Switch1(w_Switch_1),
   .i_Switch2(i_Switch_2),
   .o_Switch2(w_Switch_2));
   

 
 
   // Purpose: Toggle LED output when w_Switch_1 is released.
  always @(posedge i_Clk)
  begin
    r_Switch_1 <= w_Switch_1;         // Creates a Register
    r_Switch_2 <= w_Switch_2; 
    // This conditional expression looks for a falling edge on w_Switch_1.
    // Here, the current value (i_Switch_1) is low, but the previous value
    // (r_Switch_1) is high.  This means that we found a falling edge.
    if (w_Switch_1 == 1'b0 && r_Switch_1 == 1'b1)
    begin
      r_LED_1 <= ~r_LED_1;         // Toggle LED output
    end
	if (w_Switch_2 == 1'b0 && r_Switch_2 == 1'b1)
    begin
      r_LED_2 <= ~r_LED_2;         // Toggle LED output
    end
	
  end
 
   
   assign o_LED_1 = r_LED_1;
  assign o_LED_2 = r_LED_2;
  
  
endmodule
