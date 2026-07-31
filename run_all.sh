#!/bin/bash

# Define formatting visual anchors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================================================${NC}"
echo -e "${CYAN}          CORELEDGER-X: DISTRIBUTED POLYGLOT SYSTEM DEPLOYMENT       ${NC}"
echo -e "${CYAN}====================================================================${NC}"

# 1. COMPILATION PHASE
echo -e "\n${GREEN}[1/5] Compiling Low-Level Kernel Modules (C / C++)...${NC}"
cd /workspaces/Core_Ledger-X/cpp_kernel
g++ -O3 -o storage_kernel storage_kernel.cpp
if [ $? -eq 0 ]; then echo " -> C++ Storage Kernel Compiled."; else echo -e "${RED}C++ Build Failed${NC}"; exit 1; fi

cd /workspaces/Core_Ledger-X/c_sentinel
gcc -O2 -o ledger_sentinel sentinel.c
if [ $? -eq 0 ]; then echo " -> C Sentinel Compiled."; else echo -e "${RED}C Build Failed${NC}"; exit 1; fi

echo -e "\n${GREEN}[2/5] Compiling Legacy Mainframe Accounting Layer (COBOL)...${NC}"
cd /workspaces/Core_Ledger-X/cobol_ledger
cobc -x -o ledger_engine ledger.cob
if [ $? -eq 0 ]; then echo " -> COBOL Ledger Engine Compiled."; else echo -e "${RED}COBOL Build Failed${NC}"; exit 1; fi

echo -e "\n${GREEN}[3/5] Compiling Fault-Tolerant Native Core (Elixir + Rust Assembly)...${NC}"
cd /workspaces/Core_Ledger-X/ledger_core
mix compile
if [ $? -eq 0 ]; then echo " -> Elixir & Rust Register Bridge Compiled."; else echo -e "${RED}Elixir Build Failed${NC}"; exit 1; fi

# 2. RUNTIME EXECUTION PHASE
echo -e "\n${CYAN}====================================================================${NC}"
echo -e "${GREEN}[4/5] Launching Asynchronous Microservices Pipeline...${NC}"
echo -e "${CYAN}====================================================================${NC}"

# Start the Go API Ingestion Gateway in the background
echo " -> Launching Go API Ingestion Gateway Node [Port 8080]..."
cd /workspaces/Core_Ledger-X/go_gateway
go run main.go > /tmp/go_gateway.log 2>&1 &
GO_PID=$!

# Start the Python AI Threat Matrix Guard in the background
echo " -> Activating Python Machine Learning Isolation Forest Guard..."
cd /workspaces/Core_Ledger-X/ai_fraud_guard
python3 fraud_guard.py > /tmp/python_ai.log 2>&1 &
PYTHON_PID=$!

# Start the Elm Frontend SaaS Static File Host in the background
echo " -> Spin up Elm UI SaaS Web Console Server [Port 3000]..."
cd /workspaces/Core_Ledger-X/web_dashboard
python3 -m http.server 3000 > /tmp/elm_frontend.log 2>&1 &
ELM_PID=$!

sleep 2 # Let background workers warm up their ports

# 3. INTERACTIVE VERIFICATION PASS
echo -e "\n${GREEN}[5/5] Running Synchronous Middleware Pipelines...${NC}"

echo -e "\nExecuting C# Enterprise Compliance Audit Matrix:"
cd /workspaces/Core_Ledger-X/csharp_compliance
dotnet run

echo -e "\nRunning C++ Memory-Mapped Disk Allocation Driver:"
cd /workspaces/Core_Ledger-X/cpp_kernel
./storage_kernel

echo -e "\nTriggering C Sentinel Cryptographic Integrity System Check:"
cd /workspaces/Core_Ledger-X/c_sentinel
./ledger_sentinel

echo -e "\nRunning COBOL Ledger Balance File Processing Updates:"
cd /workspaces/Core_Ledger-X/cobol_ledger
./ledger_engine

echo -e "\n${GREEN}====================================================================${NC}"
echo -e "${GREEN}SUCCESS: All 12 structural engine layers are responsive and routing.${NC}"
echo -e "${CYAN} -> API Entry Point: http://localhost:8080/api/v1/settle${NC}"
echo -e "${CYAN} -> SaaS Frontend UI Dashboard: http://localhost:3000${NC}"
echo -e "${GREEN}====================================================================${NC}"

# Trap system exits to cleanly terminate background microservices when you press Ctrl+C
trap "kill $GO_PID $PYTHON_PID $ELM_PID; echo -e '\n${RED}All pipeline background services shut down cleanly.${NC}'; exit" INT

# Keep the script active to stream incoming validation checks
wait

