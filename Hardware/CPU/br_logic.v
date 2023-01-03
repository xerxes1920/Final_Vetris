module br_logic_unit (zeroF, negF, eqF, opcode, br_cond_met);

  // Inputs
  input [5:0] opcode;
  input zeroF;
  input negF;
  input eqF;

  // Outputs
  output reg br_cond_met;

  always @ ( * ) begin
    br_cond_met = 0;
    case (opcode)
      6'b001110: br_cond_met = eqF; // BEQ
      6'b001111: br_cond_met = ~eqF; // BNEQ
      6'b010000: br_cond_met = negF | zeroF; // BLEZ
      6'b010001: br_cond_met = ~negF & ~zeroF; // BGTZ
      default: br_cond_met = 0; // not branch instruction
    endcase
  end

endmodule // branch_logic_unit
