defmodule LedgerCore.CryptoBridge do
  @moduledoc """
  Bridges Elixir to the underlying Rust + Inline Assembly hardware scrambler.
  """
  use Rustler, otp_app: :ledger_core, crate: "crypto_kernel"

  # When the NIF loading succeeds, this native function replaces the placeholder below.
  def hardware_scramble(_data, _secret_mask), do: :erlang.nif_error(:nif_not_loaded)
end
