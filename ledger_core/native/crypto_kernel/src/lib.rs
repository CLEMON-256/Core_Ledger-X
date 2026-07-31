use std::arch::asm;

// ==========================================
// ELIXIR NIF REGISTRATION (Modern Rustler Syntax)
// ==========================================

// In Rustler 0.36+, pass ONLY the Elixir module name string as a single argument.
rustler::init!("Elixir.LedgerCore.CryptoBridge");

#[rustler::nif]
pub fn hardware_scramble(data: u64, secret_mask: u64) -> u64 {
    let mut result: u64 = data;

    unsafe {
        asm!(
            // 1. XOR the input data with our enterprise secret security mask
            "xor {0}, {1}",
            
            // 2. Rotate bits left by 13 positions (Bitwise circular shift)
            "rol {0}, 13",
            
            // 3. Perform a fast bitwise NOT operation to flip all active states
            "not {0}",
            
            inout(reg) result,
            in(reg) secret_mask,
            options(nostack, nomem, pure)
        );
    }

    result
}

// ==========================================
// TEST SUITE
// ==========================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_crypto_scramble_execution() {
        let raw_tx_chunk: u64 = 0xDEADBEEF12345678;
        let secret_key: u64   = 0xAA55AA55AA55AA55;
        
        let encrypted = hardware_scramble(raw_tx_chunk, secret_key);
        
        println!("Raw Tx Data:   0x{:X}", raw_tx_chunk);
        println!("Encrypted Out: 0x{:X}", encrypted);
        
        assert_ne!(raw_tx_chunk, encrypted);
    }
}
