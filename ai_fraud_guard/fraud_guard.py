import os
import time
import re
import pandas as pd
import numpy as np
from sklearn.ensemble import IsolationForest

# Define tracking targets
LOG_FILE_PATH = "/workspaces/Core_Ledger-X/cobol_ledger/ledger_audit.log"

def generate_synthetic_training_data():
    """Simulates historic safe banking streams to baseline our AI detector."""
    np.random.seed(42)
    # Generate 500 standard transaction amounts (typically between $10 and $5,000)
    normal_txs = np.random.exponential(scale=1500, size=500)
    df = pd.DataFrame(normal_txs, columns=["amount"])
    return df

def train_fraud_model():
    """Trains an Isolation Forest model to detect outliers."""
    print("[AI INITIALIZATION] Training Isolation Forest model on historical baselines...")
    training_data = generate_synthetic_training_data()
    
    # contamination=0.01 means we expect roughly 1% anomalous behavior structurally
    model = IsolationForest(contamination=0.01, random_state=42)
    model.fit(training_data)
    return model

def parse_log_line(line):
    """Extracts numeric amounts from strict COBOL log formats."""
    # Pattern looks for the monetary amount in fields like: PROCESSED TX:    250,000.00
    match = re.search(r"PROCESSED TX:\s+([0-9,.]+)", line)
    if match:
        clean_num = match.group(1).replace(",", "")
        return float(clean_num)
    return None

def monitor_ledger_stream(model):
    """Performs continuous log-tailing and applies live AI analysis."""
    print(f"[SECURITY ACTIVE] Watching ledger logs at: {LOG_FILE_PATH}")
    
    # Wait for the ledger engine to run at least once and create the file
    while not os.path.exists(LOG_FILE_PATH):
        print("[WAITING] Awaiting COBOL ledger initialization file generation...")
        time.sleep(2)
        
    with open(LOG_FILE_PATH, "r") as f:
        # Move pointer to the end of the existing file to capture new streams
        f.seek(0, os.SEEK_END)
        
        while True:
            line = f.readline()
            if not line:
                time.sleep(1)  # Sleep briefly to avoid high CPU polling loops
                continue
                
            amount = parse_log_line(line)
            if amount is not None:
                # Format payload vector for Scikit-Learn evaluation matrix
                features = np.array([[amount]])
                prediction = model.predict(features)[0]
                
                # Isolation Forest outputs -1 for anomalies, 1 for normal data
                if prediction == -1:
                    print(f"🚨 [CRITICAL ALERT] Fraud Guard flagged anomaly! Amount: ${amount:,.2f} exceeds threshold patterns.")
                else:
                    print(f"✅ [AUDIT SAFE] Transaction verified via AI model. Amount: ${amount:,.2f}")

if __name__ == "__main__":
    ai_brain = train_fraud_model()
    monitor_ledger_stream(ai_brain)
