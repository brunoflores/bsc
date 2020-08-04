import Clocks::*;

// Clock periods
Integer p1 = 6;
Integer p2 = 4;

// This is like OneModule.bsv but it tests the handling of input and
// output clocks by passing one clock into a submodule and then into
// another submodule and then it sis returned as an output clock back
// up to the top-level where it is used.

(* synthesize *)
module sysOneModule_InputOutputClock2 ();
   Clock clk1 <- mkAbsoluteClock(p1, p1);
   Clock clk2 <- mkAbsoluteClock(p2, p2);

   SubIFC s <- mkOneModule_InputOutputClock2_Sub1(clk2);
   Clock clk2A = s.clk;

   // use RegU to avoid the need for a reset
   Reg#(Bit#(8)) rg1 <- mkRegU(clocked_by clk1);
   Reg#(Bit#(8)) rg2 <- mkRegU(clocked_by clk2A);

   // the initial value of the registers will be AA
   Bit#(8) init_val = 8'hAA;
   
   // function to make $stime the same for Bluesim and Verilog
   function ActionValue#(Bit#(32)) adj_stime(Integer p);
      actionvalue
	 let adj = (p + 1) / 2;
	 let t <- $stime();
	 if (genVerilog)
	    return (t + fromInteger(adj));
	 else
	    return t;
      endactionvalue
   endfunction

   rule r1;
      rg1 <= rg1 + 1;
      $display("(%d) rg1 = %h", adj_stime(p1), rg1);
   endrule
   
   rule r2;
      rg2 <= rg2 + 1;
      $display("(%d) rg2 = %h", adj_stime(p2), rg2);
   endrule

   rule stop (rg1 > (init_val + 17));
      $finish(0);
   endrule

endmodule

interface SubIFC;
   interface Clock clk;
endinterface

(* synthesize *)
module mkOneModule_InputOutputClock2_Sub1#(Clock c) (SubIFC);
   SubIFC s <- mkOneModule_InputOutputClock2_Sub2(c);
   interface clk = s.clk;
endmodule

(* synthesize *)
module mkOneModule_InputOutputClock2_Sub2#(Clock c) (SubIFC);
   interface clk = c;
endmodule
