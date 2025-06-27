# 🚀 APB Master-Slave Verilog Design

Welcome to the **APB (Advanced Peripheral Bus) Master-Slave** implementation in Verilog RTL! 🎯 This project demonstrates the full APB protocol including master and slave FSM-based logic with memory operations, protocol error detection, address range validation, and extensive modular testbenches.

> 💡 Built as part of my self-learning and internship experience in the field of VLSI Design Verification using EDA Playground.

---

## 📚 Table of Contents

- [📁 Project Structure](#-project-structure)
- [🧠 What is APB?](#-what-is-apb)
- [🧩 Features](#-features)
- [🧪 Simulation Guide](#-simulation-guide)
- [🔬 Testcase Scenarios](#-testcase-scenarios)
- [📈 Waveform Debugging](#-waveform-debugging)
- [📌 Learning Outcomes](#-learning-outcomes)
- [🚧 Future Enhancements](#-future-enhancements)
- [👨‍💻 Author](#-author)
- [📄 License](#-license)

---

## 🧠 What is APB?
APB (Advanced Peripheral Bus) is part of the AMBA protocol suite from ARM, ideal for connecting low-power peripherals such as timers, UART, GPIOs.

### 🔌 Key Signals:

- PCLK – Clock
- PRESETn – Reset (active-low)
- PADDR – Address bus
- PWDATA – Write data
- PRDATA – Read data
- PWRITE – Write enable
- PSEL – Slave select
- PENABLE – Transfer phase control
- PREADY – Slave ready response
- PSLVERR – Slave Error indicator 🚨

## 🧩 Features

### 🧭 Master Design (apb_master.v)

- FSM with states: IDLE → SETUP → ENABLE
- Accepts transfer signal to start transactions
- Supports both read (READ_WRITE=0) and write (READ_WRITE=1) operations
- Transfers address and data only in correct state
- Receives read data when PREADY is high

### 🏗️ Slave Design (apb_slave.v)

- FSM: IDLE → SETUP → ENABLE
- Implements a 256-byte internal memory 🧠
- Valid address range: 0x05 to 0xF1
- Detects protocol violations (e.g., PENABLE high in SETUP)
- Responds with PSLVERR=1 for invalid address or protocol error
- Handles wait state using PREADY

## 🧪 Simulation Guide

### 🔗 EDA Playground

You can run this project on EDA Playground directly:

👉 Click Here to Simulate
(replace with your actual link)

## 🔬 Testcase Scenarios

Each scenario can be simulated using `$test$plusargs()`:

### 🧪 APB Slave Testbench (`apb_slave_tb.v`)

| Plusarg                 | Description                                               |
|-------------------------|-----------------------------------------------------------|
| `+WRITE_CONT`           | Continuous write to multiple valid addresses 📝           |
| `+READ_CONT`            | Continuous read from valid addresses 📖                   |
| `+WRITE_RANDOM`         | Random data and address write ✨                          |
| `+DEF_MEM_LOC`          | View default memory content after reset 🧼               |
| `+FINAL_MEM`            | Dump full memory after transactions 📊                   |
| `+PSLVERR_AT_WRITE`     | Invalid address write triggers PSLVERR 🚨                 |
| `+PSLVERR_AT_READ`      | Invalid address read triggers PSLVERR 🛑                  |
| `+WRITE_PENAB1_AT_IDLE` | Protocol error (PENABLE=1 during IDLE) ⚠️                |
| `+READ_PENAB1_AT_IDLE`  | Protocol error on read ⚠️                                |
| `+RST_CHECK`            | Check memory reset functionality and data clearance 🔁    |
| `+NO_XFER_PSEL_ONLY`    | PSEL toggled without PENABLE (no real transfers) ❌       |
| `+BURST_WRITE_INVALID`  | Back-to-back writes without deasserting PENABLE ❗        |

### 🧪 APB Master Testbench (`apb_master_tb.v`)

| Plusarg                | Description                                               |
|------------------------|-----------------------------------------------------------|
| `+SINGLE_WRITE`        | Single write transaction initiated by master ✍️           |
| `+SINGLE_READ`         | Single read transaction by master 🧐                      |
| `+WRITE_AT_PREADY_LOW` | Write attempt when PREADY is low (ignored) 🛑             |
| `+READ_AT_PREADY_LOW`  | Read attempt when PREADY is low (ignored) 🛑              |
| `+TRANSFER_LOW`        | Transfer signal permanently low (no transaction) ⛔       |
| `+RST_CHECK`           | Reset applied during active transfer (reset test) 🔄      |
| `+RANDOM_WRITE`        | Random address and data write from master 🎲             |
| `+WRITE_CONT`          | Continuous writes (3 back-to-back) from master 💾         |

---

## 📈 Waveform Debugging

Waveforms provide full signal trace visibility, such as:
- FSM transitions
- `PADDR`, `PWDATA`, `PRDATA`
- Timing of `PSEL`, `PENABLE`, `PREADY`
- Assertion of `PSLVERR` and `protocol_error` flags


---

## 📌 Learning Outcomes

✨ Designed and verified a full-fledged APB master-slave interface  
🛠️ Practiced FSM-based control logic in Verilog  
✅ Gained hands-on debugging with plusargs and `$monitor()`  
🧠 Understood protocol behavior and bus transactions  
🌊 Simulated and analyzed waveform using GTKWave

---

## 🚧 Future Enhancements

- ✅ Integrate APB Master + Slave in one top module
- ⌛ Add configurable wait states for PREADY
- 🔁 Add burst transfer support (APB 3.0 feature)
- 🛡️ Add assertion checks (SVA)
- 🔌 APB to AHB Bridge
- 🌍 Open-source toolchain integration

---

## Reference

- [AMBA APB PROTOCOL SPECIFICATION - ARM OFFICIAL](https://developer.arm.com/documentation/ihi0024/latest/)

## 👨‍💻 Author

**Dutt Panchal** 
- 🔗 [LinkedIn](https://www.linkedin.com/in/dattpanchal04/)  
- 🐱 [GitHub](https://github.com/DuttPanchal04)
- 🔗 [Email](dattpanchal2904@gmail.com)

### 🙌 Thanks for visiting! Happy Simulating ⚡

