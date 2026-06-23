# FSM Design Notes — Lecture Style

This follows the FSM design flow used in the Digital Technology lecture: word description, state diagram, state transition table, state encoding, next-state logic, and output logic.

## 1. CPU Control FSM

### Word description
The CPU control unit waits in `S_IDLE`. If the execute button is pressed in load mode, the FSM moves to `S_LOAD` and writes the signed two's-complement input value into the selected register. If the execute button is pressed in execute mode, the FSM moves to `S_START_ALU`, asserts `alu_start`, waits in `S_WAIT_ALU` until `alu_done=1`, then enters `S_WRITEBACK` to store the ALU result, remainder, and flags.

### State encoding
| State | Code |
|---|---:|
| S_IDLE | 000 |
| S_LOAD | 001 |
| S_START_ALU | 010 |
| S_WAIT_ALU | 011 |
| S_WRITEBACK | 100 |

### State transition table
| Q_cur | Inputs | Q_nxt | Outputs |
|---|---|---|---|
| S_IDLE | btn_exec=0 | S_IDLE | load_en=0, alu_start=0, writeback_en=0 |
| S_IDLE | btn_exec=1, mode=LOAD | S_LOAD | all 0 |
| S_IDLE | btn_exec=1, mode=EXECUTE | S_START_ALU | all 0 |
| S_LOAD | - | S_IDLE | load_en=1 |
| S_START_ALU | - | S_WAIT_ALU | alu_start=1 |
| S_WAIT_ALU | alu_done=0 | S_WAIT_ALU | writeback_en=0 |
| S_WAIT_ALU | alu_done=1 | S_WRITEBACK | writeback_en=0 |
| S_WRITEBACK | - | S_IDLE | writeback_en=1, store_flags=1 |

## 2. ALU Control FSM

### State encoding
| State | Code |
|---|---:|
| S_ALU_IDLE | 000 |
| S_ALU_ADD_SUB | 001 |
| S_ALU_START_MUL | 010 |
| S_ALU_WAIT_MUL | 011 |
| S_ALU_START_DIV | 100 |
| S_ALU_WAIT_DIV | 101 |
| S_ALU_DONE | 110 |

### State transition table
| Q_cur | Inputs | Q_nxt | Outputs |
|---|---|---|---|
| S_ALU_IDLE | alu_start=1, op=ADD/SUB | S_ALU_ADD_SUB | - |
| S_ALU_IDLE | alu_start=1, op=MUL | S_ALU_START_MUL | - |
| S_ALU_IDLE | alu_start=1, op=DIV | S_ALU_START_DIV | - |
| S_ALU_ADD_SUB | t>=1 | S_ALU_DONE | result_valid=1 |
| S_ALU_START_MUL | - | S_ALU_WAIT_MUL | mul_start=1 |
| S_ALU_WAIT_MUL | mul_done=1 | S_ALU_DONE | result_valid=1 |
| S_ALU_START_DIV | - | S_ALU_WAIT_DIV | div_start=1 |
| S_ALU_WAIT_DIV | div_done=1 | S_ALU_DONE | result_valid=1 |
| S_ALU_DONE | - | S_ALU_IDLE | alu_done=1 |

## 3. Multiplier FSM

### State encoding
| State | Code |
|---|---:|
| S_MUL_IDLE | 000 |
| S_MUL_LOAD | 001 |
| S_MUL_CALC | 010 |
| S_MUL_FINISH | 011 |

### State transition table
| Q_cur | Inputs | Q_nxt | Outputs |
|---|---|---|---|
| S_MUL_IDLE | mul_start=1 | S_MUL_LOAD | - |
| S_MUL_LOAD | - | S_MUL_CALC | load abs(A), abs(B), product sign |
| S_MUL_CALC | count<8 | S_MUL_CALC | shift/add step |
| S_MUL_CALC | count=8 | S_MUL_FINISH | - |
| S_MUL_FINISH | - | S_MUL_IDLE | mul_done=1, overflow checked |

## 4. Divider FSM

### State encoding
| State | Code |
|---|---:|
| S_DIV_IDLE | 000 |
| S_DIV_CHECK_ZERO | 001 |
| S_DIV_ERROR | 010 |
| S_DIV_LOAD | 011 |
| S_DIV_CALC | 100 |
| S_DIV_FINISH | 101 |

### State transition table
| Q_cur | Inputs | Q_nxt | Outputs |
|---|---|---|---|
| S_DIV_IDLE | div_start=1 | S_DIV_CHECK_ZERO | - |
| S_DIV_CHECK_ZERO | divisor=0 | S_DIV_ERROR | div_zero=1 |
| S_DIV_CHECK_ZERO | divisor!=0 | S_DIV_LOAD | - |
| S_DIV_LOAD | - | S_DIV_CALC | load abs(A), abs(B), q=0 |
| S_DIV_CALC | remainder>=divisor | S_DIV_CALC | rem-=divisor, q++ |
| S_DIV_CALC | remainder<divisor | S_DIV_FINISH | - |
| S_DIV_FINISH | - | S_DIV_IDLE | div_done=1, signs/display limits checked |
| S_DIV_ERROR | - | S_DIV_IDLE | div_done=1, display_error=1 |

## 5. Display FSM

### State encoding
| State | Code |
|---|---:|
| S_DISP_D0 | 00 |
| S_DISP_D1 | 01 |
| S_DISP_D2 | 10 |
| S_DISP_D3 | 11 |

### State transition table
| Q_cur | Inputs | Q_nxt | Outputs |
|---|---|---|---|
| S_DISP_D0 | refresh_tick | S_DISP_D1 | enable an[0] |
| S_DISP_D1 | refresh_tick | S_DISP_D2 | enable an[1] |
| S_DISP_D2 | refresh_tick | S_DISP_D3 | enable an[2] |
| S_DISP_D3 | refresh_tick | S_DISP_D0 | enable an[3] |
