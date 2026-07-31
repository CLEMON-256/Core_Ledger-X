#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <cstdint> // Added the missing exact-width integer type header

// Every raw ledger block entry must follow a strict structural layout
struct TransactionBlock {
    char tx_id[16];      // Fixed size array layout to accept character streams
    char sender[16];     // Fixed size array layout
    char receiver[16];   // Fixed size array layout
    uint64_t raw_payload; // Now recognized perfectly by the compiler
};

int main() {
    const char* filepath = "/workspaces/Core_Ledger-X/cobol_ledger/tx_input.dat";
    size_t file_size = sizeof(TransactionBlock);

    std::cout << "[C++ KERNEL] Initializing storage buffer..." << std::endl;

    // 1. Ensure the underlying destination file exists and matches size requirements
    int fd = open(filepath, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
    if (fd == -1) {
        std::cerr << "CRITICAL ERROR: Failed to open transaction target file." << std::endl;
        return 1;
    }

    // Allocate exact space bounds on physical disk layout
    if (ftruncate(fd, file_size) == -1) {
        std::cerr << "CRITICAL ERROR: Failed to allocate hardware block footprint memory space." << std::endl;
        close(fd);
        return 1;
    }

    // 2. Establish the memory map (mmap) directly to virtual memory space
    void* map = mmap(nullptr, file_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (map == MAP_FAILED) {
        std::cerr << "CRITICAL ERROR: Kernel memory-mapping alignment assignment failed." << std::endl;
        close(fd);
        return 1;
    }

    // 3. Directly write the incoming transaction data structure into memory addresses
    TransactionBlock* tx_slot = static_cast<TransactionBlock*>(map);
    
    std::strncpy(tx_slot->tx_id, "TX-A8829", 16);
    std::strncpy(tx_slot->sender, "ACC-01", 16);
    std::strncpy(tx_slot->receiver, "ACC-02", 16);
    tx_slot->raw_payload = 18446743315045949439ULL; // Output value from your Inline Assembly block!

    std::cout << "[C++ KERNEL] Transaction binary record memory-mapped to disk successfully." << std::endl;

    // 4. Synchronize memory changes back down onto disk and clean up resources safely
    msync(map, file_size, MS_SYNC);
    munmap(map, file_size);
    close(fd);

    return 0;
}
