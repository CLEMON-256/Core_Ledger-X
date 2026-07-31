package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

// Transaction defines the rigid payload format for our polyglot system.
type Transaction struct {
	ID        string  `json:"transaction_id"`
	Sender    string  `json:"sender_id"`
	Receiver  string  `json:"receiver_id"`
	Amount    float64 `json:"amount"`
	RawPayload uint64 `json:"raw_payload"`
}

// Response handles structural output serialization back to the client.
type Response struct {
	Status    string `json:"status"`
	Message   string `json:"message"`
	Timestamp int64  `json:"timestamp_ns"`
}

func validateTransaction(tx Transaction) error {
	if tx.ID == "" || tx.Sender == "" || tx.Receiver == "" {
		return fmt.Errorf("missing structural transaction metadata identifiers")
	}
	if tx.Amount <= 0 {
		return fmt.Errorf("transaction amount must be greater than zero")
	}
	return nil
}

func transactionHandler(w http.ResponseWriter, r *http.Request) {
	// Enforce strict HTTP POST verb guidelines
	if r.Method != http.MethodPost {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Response{Status: "error", Message: "Only POST actions permitted"})
		return
	}

	var tx Transaction
	if err := json.NewDecoder(r.Body).Decode(&tx); err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Status: "error", Message: "Malformed JSON structure"})
		return
	}

	if err := validateTransaction(tx); err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusUnprocessableEntity)
		json.NewEncoder(w).Encode(Response{Status: "error", Message: err.Error()})
		return
	}

	// Concurrently dispatch payload downstream without blocking the client loop
	go func(t Transaction) {
		log.Printf("[GATEWAY Ingestion Node] Concurrently streaming Tx %s [Payload Chunk: %d] to Elixir cluster...", t.ID, t.RawPayload)
		// Downstream bridge socket logic goes here in the integration phase
	}(tx)

	// Send an immediate async receipt acknowledgment back to the web user
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	json.NewEncoder(w).Encode(Response{
		Status:    "accepted",
		Message:   "Transaction verified and buffered for hardware-level assembly encoding.",
		Timestamp: time.Now().UnixNano(),
	})
}

func main() {
	port := ":8080"
	http.HandleFunc("/api/v1/settle", transactionHandler)

	log.Printf("[CORE INGESTION ENGINE] Go API Gateway listening intently on port %s", port)
	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatalf("Gateway server initialization crash failure: %v", err)
	}
}
