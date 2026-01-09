# Auracle Python SDK

Headless client for submitting `resolve_event` instructions and querying truth signals.

## Install (editable)

```
pip install -e .
```

## Usage

```python
from solders.keypair import Keypair
from auracle import AuracleClient, NaturalLanguageOracle

client = AuracleClient(
    rpc_url="https://api.mainnet-beta.solana.com",
    program_id="AuracLE111111111111111111111111111111111",
    auracle_mint="AURA_MINT_PUBKEY",
)

def resolve_truth(event_id: int) -> bytes:
    return b"\x00" * 32

client.truth_signal_resolver = resolve_truth

signature = client.query_truth(event_id=42, payer=Keypair())
print(signature)

nl = NaturalLanguageOracle(client)
signature = nl.verify_by_name("usdc_depeg_2026_01_01", payer=Keypair())
```

