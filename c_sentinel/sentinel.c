#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>

// Standard CRC32 polynomial definition used in network packets and file systems
#define CRC32_POLYNOMIAL 0xEDB88320

// Generates a lookup table at runtime to accelerate bitwise evaluation speed
void generate_crc32_table(uint32_t *table) {
    for (uint32_t i = 0; i < 256; i++) {
        uint32_t crc = i;
        for (int j = 0; j < 8; j++) {
            if (crc & 1) {
                crc = (crc >> 1) ^ CRC32_POLYNOMIAL;
            } else {
                crc >>= 1;
            }
        }
        table[i] = crc;
    }
}

// Computes the hardware-velocity file checksum using unmanaged byte tracking
uint32_t compute_file_crc32(const char *filepath, uint32_t *table) {
    int fd = open(filepath, O_RDONLY);
    if (fd == -1) {
        perror("[C SENTINEL] CRITICAL ERROR: Could not access ledger stream file");
        return 0;
    }

    uint32_t crc = 0xFFFFFFFF;
    uint8_t buffer[4096];
    ssize_t bytes_read;

    // Use raw POSIX read operations to bypass language runtime wrappers
    while ((bytes_read = read(fd, buffer, sizeof(buffer))) > 0) {
        for (ssize_t i = 0; i < bytes_read; i++) {
            uint8_t lookup_index = (crc ^ buffer[i]) & 0xFF;
            crc = (crc >> 8) ^ table[lookup_index];
        }
    }

    close(fd);
    return crc ^ 0xFFFFFFFF;
}

int main() {
    const char *target_file = "/workspaces/Core_Ledger-X/cobol_ledger/tx_input.dat";
    uint32_t crc32_table[256];

    printf("[C SENTINEL] Initializing unmanaged hardware file validator...\n");
    generate_crc32_table(crc32_table);

    printf("[C SENTINEL] Calculating live checksum for: %s\n", target_file);
    uint32_t checksum = compute_file_crc32(target_file, crc32_table);

    if (checksum != 0) {
        printf("[C SENTINEL] Integrity verification passed. CRC32 Checksum: 0x%08X\n", checksum);
    } else {
        printf("[C SENTINEL] Warning: File was empty or inaccessible.\n");
    }

    return 0;
}
