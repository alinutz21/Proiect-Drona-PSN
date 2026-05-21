# 🚁 Drone Mission Sequencer — VHDL FSM

> Autonomous drone mission controller implemented as a Moore FSM in VHDL, deployed on the Nexys A7-100T FPGA board.

**Course:** Proiectarea Sistemelor Numerice (PSN) — UTCN, Faculty of Automation and Computer Science  
**Hardware:** Digilent Nexys A7-100T (Xilinx Artix-7 FPGA)  
**Grade:** Maximum score ✓

---

## Overview

This project implements a **9-state Moore Finite State Machine** that manages the complete lifecycle of an autonomous drone mission — from pre-flight checks and takeoff, through navigation and payload execution, to landing and emergency handling.

The system is decomposed into two subsystems following the **UC/UE (Control Unit / Execution Unit)** design methodology:

- **UC (Unitatea de Control):** Decision logic — the FSM itself
- **UE (Unitatea de Executie):** Time measurement — frequency divider + countdown timer

User interaction is handled via physical buttons and switches on the board. All inputs are processed through **MPG (Mono-Pulse Generator)** modules for debouncing and edge detection. System status is displayed via 5 LEDs and a 7-segment display showing remaining time in `MM.SS` format alongside the current FSM state code.

---

## FSM States

| Code | State | Binary |
|------|-------|--------|
| S0 | IDLE | `0000` |
| S1 | PRE_CHECK | `0001` |
| S2 | TAKEOFF | `0010` |
| S3 | NAV (Navigation) | `0011` |
| S4 | EXEC (Target Execution) | `0100` |
| S5 | RETURN | `0101` |
| S6 | LAND | `0110` |
| S7 | EMERGENCY | `0111` |
| S8 | AVOID (Obstacle Avoidance) | `1000` |

**Emergency priority:** `baterie_scazuta` and `pierdere_GPS` trigger immediate transition to `EMERGENCY` from any active state.

---

## System I/O

### Inputs

| Signal | Device | Function |
|--------|--------|----------|
| `clk` | 100 MHz clock | System clock |
| `rst` | BTND | Global reset |
| `start_misiune` | BTNC | Start mission |
| `resetare_manuala` | BTNU | Manual reset from EMERGENCY |
| `confirmare_aterizare` | BTNL | Landing confirmation |
| `cerere_intoarcere` | BTNR | Voluntary return request |
| `tinta_atinsa` | SW0 | Target reached |
| `baza_atinsa` | SW1 | Base reached |
| `baterie_scazuta` | SW2 | Low battery (critical priority) |
| `obstacol_detectat` | SW3 | Obstacle detected |
| `pierdere_GPS` | SW4 | GPS signal lost (max priority) |

### Outputs

| Signal | Device | Function |
|--------|--------|----------|
| `activare_motoare` | LED0 | Motors active |
| `activare_navigatie` | LED1 | Navigation active |
| `activare_sarcina_utila` | LED2 | Payload active |
| `mod_intoarcere` | LED3 | Return mode |
| `alarma` | LED4 (blinking) | Emergency alarm |
| `anod[7:0]`, `catod[6:0]`, `dp` | SSD | Time remaining + state code |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    drone_mission_top                     │
│                                                          │
│  Buttons/Switches → [MPG x9] → ┐                        │
│                                 ↓                        │
│              ┌──────────────────────────┐                │
│              │    Unitatea de Control   │ → LEDs         │
│              │    (Moore FSM, 9 states) │                │
│              └───────┬──────────┬───────┘                │
│              EN_Timer │  T_Done  │ Reset_Timer            │
│              Valoare_Max         │                        │
│                       ↓          │                        │
│              ┌──────────────────────────┐                │
│              │   Unitatea de Executie   │                │
│              │  [Freq Divider] + [Timer]│ → SSD          │
│              └──────────────────────────┘                │
└─────────────────────────────────────────────────────────┘
```

### UC ↔ UE Communication Signals

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `EN_Timer` | UC → UE | 1 bit | Enable countdown |
| `Reset_Timer` | UC → UE | 1 bit | Reset timer to Valoare_Max |
| `Valoare_Max` | UC → UE | integer (0–999) | Duration in seconds for current state |
| `T_Done` | UE → UC | 1 bit | Timer expired, transition allowed |

---

## Module Breakdown

| Module | Role |
|--------|------|
| `freq_divider` | Divides 100 MHz → 1 Hz tick (`tick_sec`) |
| `MPG` | Debouncer + edge detector for all physical inputs |
| `numarator_timp` | Countdown timer; generates `T_Done`, `Valoare_Sec`, `Valoare_Min` |
| `control_unit` | Moore FSM — 3-process architecture (state register, next-state logic, output logic) |
| `bcd_converter` | Converts binary time/state values to BCD digits for display |
| `ssd` | Multiplexed 7-segment display driver (modified for `dp` decimal point control) |
| `drone_mission_top` | Top-level: instantiates all modules, wires signals, implements alarm blink logic |

---

## Simulation Scenarios

Four testbench scenarios were defined:

1. **Normal mission** — Full sequence IDLE → PRE_CHECK → TAKEOFF → NAV → EXEC → RETURN → LAND → IDLE
2. **Obstacle mid-flight** — Obstacle detected in NAV triggers AVOID; if unresolved after timeout → RETURN
3. **Landing timeout** — Landing confirmation not received in time → EMERGENCY → manual reset
4. **GPS loss** — GPS lost during NAV → immediate EMERGENCY (max priority override)

---

## Key Design Decisions

**Moore vs Mealy FSM**  
Moore was chosen for output stability — outputs depend only on current state, not inputs. This prevents glitches when input signals have noise, which is critical for a control system.

**Countdown vs Count-up Timer**  
Countdown was chosen so the display shows *time remaining* until next transition — more intuitive for the operator and simplifies T_Done detection (trigger when counter reaches 0).

**`Valoare_Max` as integer (seconds) vs bit vector (minutes)**  
Integer in seconds allows any duration (e.g., 30s, 90s), not just minute multiples. Range `0 to 999` supports up to ~16 minutes.

---

## File Structure

```
drone-mission-sequencer/
├── src/
│   ├── freq_divider.vhd
│   ├── mpg.vhd
│   ├── numarator_timp.vhd
│   ├── control_unit.vhd
│   ├── bcd_converter.vhd
│   ├── ssd.vhd
│   ├── drone_mission_top.vhd
│   └── constraints.xdc
├── docs/
│   └── Proiect_PSN_Drona.pdf
└── README.md
```

---

## How to Run

1. Open Vivado and create a new project targeting **xc7a100tcsg324-1** (Nexys A7-100T)
2. Add all `.vhd` source files from `src/`
3. Add the constraints file `constraints.xdc`
4. Run **Synthesis → Implementation → Generate Bitstream**
5. Connect the board via USB and program via **Hardware Manager**
6. Press **BTND** to reset the system to `S0_IDLE`
7. Follow the [usage guide in the documentation](docs/Proiect_PSN_Drona.pdf)

---

## Possible Extensions

- **Buzzer alarm** — The Nexys A7 has a PWM audio amplifier; a tone could be generated during EMERGENCY for audio feedback
- **Auto-demo mode** — A sub-FSM that automatically drives all inputs through a predefined scenario for hands-free demonstration

---

## Author

**Oniga Alin Nicolae** — Grupa 2  
UTCN, Facultatea de Automatică și Calculatoare  
Îndrumător: Erika Melinda Kali
