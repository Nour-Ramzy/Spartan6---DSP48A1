module tb_DSP48A1 ();
// parameters
    parameter A0REG = 0;
    parameter A1REG = 1;
    parameter B0REG = 0;
    parameter B1REG = 1;
    parameter CREG = 1;
    parameter DREG = 1;
    parameter PREG = 1;
    parameter MREG = 1;
    parameter CARRYINREG = 1;
    parameter CARRYOUTREG = 1;
    parameter OPMODEREG = 1;
    parameter CARRYINSEL = "OPMODE5";
    parameter B_INPUT = "DIRECT";
    parameter RSTTYPE = "SYNC";
    //connect
    reg [17:0] A,B,D,BCIN;
    reg [47:0] C,PCIN;
    reg [7:0] OPMODE;
    reg clk ,CARRYIN;
    reg RSTA,RSTB,RSTC,RSTD,RSTM,RSTP,RSTCARRYIN,RSTOPMODE;
    reg CEA,CEB,CEC,CED,CEM,CEP,CECARRYIN,CEOPMODE;
    wire [47:0] PCOUT,P;
    wire [17:0] BCOUT;
    wire [35:0] M;
    wire CARRYOUT ,CARRYOUTF;
   /* reg [47:0] P_exp,PCOUT_EXP;
    reg [17:0] BCOUT_EXP;
    reg [35:0] M_exp;
    reg CARRYOUT_exp ,CARRYOUTF_exp;*/
    // DUT
    DSP48A1_1 dsp1(.*);
    //clock generation
    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end
    initial begin
        A=18'd5; B=18'd10; D=18'd18; BCIN=18'd6; C=40; PCIN=55; OPMODE=7; CARRYIN=0;
        // reset all
        RSTA=1; RSTB=1; RSTC=1; RSTD=1; RSTM=1; RSTP=1; RSTCARRYIN=1; RSTOPMODE=1;
        CEA=0; CEB=0; CEC=0; CED=0; CEM=0; CEP=0; CECARRYIN=0; CEOPMODE=0;
         repeat (4) @(negedge clk);
         // release reset
         RSTA = 0; RSTB = 0; RSTC = 0; RSTD = 0;
        RSTM = 0; RSTP = 0; RSTCARRYIN = 0; RSTOPMODE = 0;
        CEA = 1; CEB = 1; CEC = 1; CED = 1; CEM = 1; CEP = 1; 
        CECARRYIN = 1; CEOPMODE = 1;
        //test cases

        // Test 1: Simple Multiply A * B
        OPMODE = 8'b00000001; // Corresponds to multi
        repeat (4) @(negedge clk);
        if(P != A*B) begin
       $display("error-test1 P=%d , ex=%d", P,(A*B));
       $stop;
    end
    
    
    
    // Test 5: Reset behavior
        RSTP = 1;
        repeat (4) @(negedge clk);
        if(P != 0) begin
       $display("error-test5 P=%d , ex=%d", P,0);
       $stop;
    end
    // Test 6: Multiplication with Registers
        RSTP = 0;
        A = 18'd3;
        B = 18'd7;
        repeat (4) @(negedge clk);
        if(P != A*B) begin
       $display("error-test6 P=%d , ex=%d", P,(A*B));
       $stop;
    end
    //PRE-ADDER 
    OPMODE = 8'b0011_0001;
    D = 18'd10;
    B = 18'd7;
    A = 18'd3;
    repeat (4) @(negedge clk);
  if(P != 48'd51 ) begin
       $display("error-test3 P=%d , ex=%d", P,48'd51);
       $stop;
    end
    //POST-SUBTRACT
    OPMODE = 8'b1000_1101;
    C = 48'd100;
    A = 18'd5;
    B = 18'd4; 
    repeat (4) @(negedge clk);
    if(P != 48'd80 ) begin
       $display("error-test4 P=%d , ex=%d", P,48'd80);
       $stop;
    end
    
    $stop;
    end

endmodule //tb_DSP48A1