module DSP48A1_1 #(
    parameter A0REG = 0,
    parameter A1REG = 1,
    parameter B0REG = 0,
    parameter B1REG = 1,
    parameter CREG = 1,
    parameter DREG = 1,
    parameter PREG = 1,
    parameter MREG = 1,
    parameter CARRYINREG = 1,
    parameter CARRYOUTREG = 1,
    parameter OPMODEREG = 1,
    parameter CARRYINSEL = "OPMODE5",
    parameter B_INPUT = "DIRECT",
    parameter RSTTYPE = "SYNC"
)(
    input [17:0] A,B,D,BCIN,
    input [47:0] C,PCIN,
    input [7:0] OPMODE,
    input clk ,CARRYIN,
    input RSTA,RSTB,RSTC,RSTD,RSTM,RSTP,RSTCARRYIN,RSTOPMODE,
    input CEA,CEB,CEC,CED,CEM,CEP,CECARRYIN,CEOPMODE,
    output [47:0] PCOUT,P,
    output [17:0] BCOUT,
    output [35:0] M,
    output CARRYOUT ,CARRYOUTF
);
//internal
reg [17:0] B_active;
wire [17:0] pre_mux_out;
wire [17:0] D_out;
wire [17:0] B0_out;
wire [17:0] A0_out;
wire [47:0] C_out;
wire [17:0] B1_out;
wire [17:0] A1_out;
wire [35:0] M_out;
wire [7:0] OPMODE_out;
wire CARRY_out;
wire [17:0] pre_as;
wire [47:0] post_as;
wire cout_post;
wire [35:0] mul_out;
reg [47:0] mux_Xout;
reg [47:0] mux_Zout;
reg carry_mux;
// assign muxes
always @(*) begin
    if (B_INPUT=="DIRECT") begin
        B_active = B;
    end
    else if (B_INPUT=="CASCADE") begin
        B_active = BCIN;
    end
    else begin
        B_active = 0;
    end
end
//CARRY
always @(*) begin
    if (CARRYINSEL == "OPMODE5") begin
        carry_mux = OPMODE_out[5];
    end
    else if (CARRYINSEL == "CARRYIN") begin
        carry_mux = CARRYIN;
    end
    else begin
         carry_mux = 0;
    end
end
assign pre_mux_out = (OPMODE_out[4])? pre_as : B0_out;
//x
always @(*) begin
    case (OPMODE_out[1:0])
    0: mux_Xout = 0;
    1: mux_Xout = M_out;
    2: mux_Xout = P;
    3: mux_Xout = {D_out[11:0],A1_out[17:0],B1_out[17:0]};
    endcase
end
//z
always @(*) begin
    case (OPMODE_out[3:2])
        0: mux_Zout = 0;
        1: mux_Zout = PCIN;
        2: mux_Zout = P;
        3: mux_Zout = C_out;
    endcase
end
//assign math
assign pre_as = (OPMODE_out[6])? (D_out - B0_out) : (D_out + B0_out);
assign mul_out = A1_out * B1_out;
assign {cout_post,post_as} = (OPMODE_out[7])? (mux_Zout-(mux_Xout+CARRY_out)) : (mux_Zout + mux_Xout);
//OUTPUT ASSIGN
 assign CARRYOUTF = CARRYOUT;
 assign PCOUT = P;
 assign M = ~(~M_out);
 assign BCOUT = B1_out;

//instantiation
 REG_MUX #(
    .IO_WIDTH(18),
    .RSTTYPE(RSTTYPE),
    .REG_E(DREG)
 ) D_REG (
    .in(D),
    .clk(clk),
    .rst(RSTD),
    .CE(CED),
    .mux_out(D_out)
 );

 REG_MUX #(
    .IO_WIDTH(18),
    .RSTTYPE(RSTTYPE),
    .REG_E(B0REG)
 ) B0_REG (
    .in(B_active),
    .clk(clk),
    .rst(RSTB),
    .CE(CEB),
    .mux_out(B0_out)
 );

 REG_MUX #(
    .IO_WIDTH(18),
    .RSTTYPE(RSTTYPE),
    .REG_E(A0REG)
 ) A0_REG (
    .in(A),
    .clk(clk),
    .rst(RSTA),
    .CE(CEA),
    .mux_out(A0_out)
 );

 REG_MUX #(
    .IO_WIDTH(48),
    .RSTTYPE(RSTTYPE),
    .REG_E(CREG)
 ) C_REG (
    .in(C),
    .clk(clk),
    .rst(RSTC),
    .CE(CEC),
    .mux_out(C_out)
 );

 REG_MUX #(
    .IO_WIDTH(18),
    .RSTTYPE(RSTTYPE),
    .REG_E(B1REG)
 ) B1_REG (
    .in(pre_mux_out),
    .clk(clk),
    .rst(RSTB),
    .CE(CEB),
    .mux_out(B1_out)
 );

 REG_MUX #(
    .IO_WIDTH(18),
    .RSTTYPE(RSTTYPE),
    .REG_E(A1REG)
 ) A1_REG (
    .in(A0_out),
    .clk(clk),
    .rst(RSTA),
    .CE(CEA),
    .mux_out(A1_out)
 );

 REG_MUX #(
    .IO_WIDTH(36),
    .RSTTYPE(RSTTYPE),
    .REG_E(MREG)
 ) M_REG (
    .in(mul_out),
    .clk(clk),
    .rst(RSTM),
    .CE(CEM),
    .mux_out(M_out)
 );

 REG_MUX #(
    .IO_WIDTH(8),
    .RSTTYPE(RSTTYPE),
    .REG_E(OPMODEREG)
 ) OPMODE_REG (
    .in(OPMODE),
    .clk(clk),
    .rst(RSTOPMODE),
    .CE(CEOPMODE),
    .mux_out(OPMODE_out)
 );

 REG_MUX #(
    .IO_WIDTH(1),
    .RSTTYPE(RSTTYPE),
    .REG_E(CARRYINREG)
 ) CYI (
    .in(carry_mux),
    .clk(clk),
    .rst(RSTCARRYIN),
    .CE(CECARRYIN),
    .mux_out(CARRY_out)
 );

REG_MUX #(
    .IO_WIDTH(48),
    .RSTTYPE(RSTTYPE),
    .REG_E(PREG)
 ) P_REG (
    .in(post_as),
    .clk(clk),
    .rst(RSTP),
    .CE(CEP),
    .mux_out(P)
 );

 REG_MUX #(
    .IO_WIDTH(1),
    .RSTTYPE(RSTTYPE),
    .REG_E(CARRYOUTREG)
 ) CYO (
    .in(cout_post),
    .clk(clk),
    .rst(RSTCARRYIN),
    .CE(CECARRYIN),
    .mux_out(CARRYOUT)
 );

 





endmodule //DSP48A1