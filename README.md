# FPGA UART Command Parser

A UART-based command interface with bidirectional serial communication. The system receives ASCII commands over serial, parses them through an FSM, executes LED operations, and transmits responses back.

**Board used:** [Nexys A7](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual) (Artix-7 100T)  
**Language:** Verilog HDL  
**Tool:** Vivado Design Suite


## File Structure

```
.
├── rtl/
│   ├── top.v            
│   ├── uart_rx.v        
│   ├── uart_tx.v        
│   └── command_parser.v
└── sim/waveforms/
|   ├── command_parser_tb_behav.wcfg        
|   └── uart_tb_behav.wcfg 
└── tb/
    ├── uart_tb.v          
    └── command_parser_tb.v
```

**Modules:**
- `top.v` - Top-level integration
- `uart_rx.v` - UART receiver with metastability protection
- `uart_tx.v` - UART transmitter
- `command_parser.v` - FSM-based command processor

## Architecture

```
PC Terminal ──► UART RX ──► Command Parser ──► LED Control
                                  │
                                  └──► UART TX ──► PC Terminal
```

## Commands

| Command | Hex  | Function              |
|---------|------|-----------------------|
| `'0'`   | 0x30 | Turn LED[0] OFF       |
| `'1'`   | 0x31 | Turn LED[0] ON        |
| `'2'`   | 0x32 | Turn LED[1] ON        |
| `'L'`   | 0x4C | Toggle LED[0]         |
| `'R'`   | 0x52 | Read LED[0] status    |

**Response:** Command `'R'` returns `'1'` if LED[0] is ON, `'0'` if OFF.

## Configuration

Configure baud rate by setting `CLKS_PER_BIT` parameter:

```verilog
CLKS_PER_BIT = Clock_Frequency / Baud_Rate
```

**Examples:**
- 100 MHz @ 19200 baud: `CLKS_PER_BIT = 5208`
- 100 MHz @ 115200 baud: `CLKS_PER_BIT = 868`
- 10 MHz @ 115200 baud: `CLKS_PER_BIT = 87`

## Simulation

### UART Module Test

Tests basic UART TX/RX functionality:
- Transmits `0xAB` via TX
- Receives `0x3F` via RX
- Verifies correct byte capture

<img width="1397" height="847" alt="Screenshot 2025-12-14 120345" src="https://github.com/user-attachments/assets/b6b06cb4-f981-49c2-afcb-e3a44b9d4cb1" />

*TX transmits 0xAB, RX receives 0x3F with proper timing at 115200 baud*

### Command Parser Test

Tests complete system with all commands:
1. Send `'1'` → LED[0] turns ON
2. Send `'0'` → LED[0] turns OFF
3. Send `'L'` → LED[0] toggles ON
4. Send `'L'` → LED[0] toggles OFF
5. Send `'2'` → LED[1] turns ON

<img width="1398" height="845" alt="Screenshot 2025-12-14 121930" src="https://github.com/user-attachments/assets/4aa1052f-bfb2-4a9d-b234-fa4cc813c0de" />

*LED array responds to command sequence: 00 → 01 → 00 → 01 → 00 → 02*

## FSM State Diagrams

**UART RX States:**
```
IDLE → RX_START_BIT → RX_DATA_BITS → RX_STOP_BIT → CLEANUP → IDLE
```

**UART TX States:**
```
IDLE → TX_START_BIT → TX_DATA_BITS → TX_STOP_BIT → CLEANUP → IDLE
```

**Command Parser States:**
```
IDLE → DECODE → EXECUTE → [RESPOND → WAIT_TX] → IDLE
```

## Features

**UART Implementation:**
- Standard 8N1 protocol (8 data bits, no parity, 1 stop bit)
- Double-register synchronizer for metastability protection
- Mid-bit sampling for noise immunity
- Configurable baud rate via parameter

**Command Parser:**
- FSM-based design with 5 states: IDLE → DECODE → EXECUTE → RESPOND → WAIT_TX
- Response capability for read operations
- Invalid command rejection
- Non-blocking state transitions

## On real hardware

Configure terminal emulator (PuTTY):
- **Baud Rate:** 19200 (or configured value)
- **Data Bits:** 8
- **Parity:** None
- **Stop Bits:** 1
- **Flow Control:** None

Send commands:
```
> 1         # Turn LED[0] ON
> L         # Toggle LED[0] OFF
> R         # Query LED[0] status
< 0         # Response: LED[0] is OFF
> 2         # Turn LED[1] ON
```
