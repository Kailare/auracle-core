from __future__ import annotations

import hashlib
from dataclasses import dataclass
from typing import Callable, Optional, Sequence

from borsh_construct import Bytes, CStruct, U64
from solana.rpc.api import Client
from solana.transaction import AccountMeta, Transaction, TransactionInstruction
from spl.token.instructions import get_associated_token_address
from solders.keypair import Keypair
from solders.pubkey import Pubkey

_RESOLVE_EVENT_LAYOUT = CStruct(
    "event_id" / U64,
    "truth_signal" / Bytes(32),
    "transaction_fee_lamports" / U64,
)


def _resolve_event_discriminator() -> bytes:
    return hashlib.sha256(b"global:resolve_event").digest()[:8]


def _event_id_from_name(name: str) -> int:
    digest = hashlib.sha256(name.encode("utf-8")).digest()
    return int.from_bytes(digest[:8], "little", signed=False)


@dataclass
class AuracleClient:
    rpc_url: str
    program_id: str
    auracle_mint: str
    truth_signal_resolver: Optional[Callable[[int], bytes]] = None

    def __post_init__(self) -> None:
        self._client = Client(self.rpc_url)
        self._program_id = Pubkey.from_string(self.program_id)
        self._auracle_mint = Pubkey.from_string(self.auracle_mint)

    def _build_resolve_event_ix(
        self,
        event_id: int,
        truth_signal: bytes,
        transaction_fee_lamports: int,
        payer: Pubkey,
        payer_auracle_token_account: Pubkey,
        market_state: Pubkey,
    ) -> TransactionInstruction:
        data = (
            _resolve_event_discriminator()
            + _RESOLVE_EVENT_LAYOUT.build(
                {
                    "event_id": event_id,
                    "truth_signal": truth_signal,
                    "transaction_fee_lamports": transaction_fee_lamports,
                }
            )
        )
        accounts = [
            AccountMeta(payer, is_signer=True, is_writable=True),
            AccountMeta(market_state, is_signer=False, is_writable=True),
            AccountMeta(payer_auracle_token_account, is_signer=False, is_writable=True),
            AccountMeta(self._auracle_mint, is_signer=False, is_writable=False),
            AccountMeta(TOKEN_PROGRAM_ID, is_signer=False, is_writable=False),
            AccountMeta(SYSTEM_PROGRAM_ID, is_signer=False, is_writable=False),
        ]
        return TransactionInstruction(self._program_id, accounts, data)

    def _get_market_state_pda(self, event_id: int) -> Pubkey:
        seed = event_id.to_bytes(8, "little", signed=False)
        return Pubkey.find_program_address([b"market", seed], self._program_id)[0]

    def query_truth(
        self,
        event_id: int,
        payer: Keypair,
        payer_auracle_token_account: Optional[str] = None,
        truth_signal: Optional[bytes] = None,
    ) -> str:
        if truth_signal is None:
            if self.truth_signal_resolver is None:
                raise ValueError("truth_signal is required or set truth_signal_resolver.")
            truth_signal = self.truth_signal_resolver(event_id)
        if len(truth_signal) != 32:
            raise ValueError("truth_signal must be exactly 32 bytes.")

        payer_pubkey = payer.pubkey()
        if payer_auracle_token_account is None:
            payer_token_pubkey = get_associated_token_address(
                owner=payer_pubkey, mint=self._auracle_mint
            )
        else:
            payer_token_pubkey = Pubkey.from_string(payer_auracle_token_account)
        market_state = self._get_market_state_pda(event_id)

        # Build instruction with a placeholder fee to query actual network fee.
        ix = self._build_resolve_event_ix(
            event_id=event_id,
            truth_signal=truth_signal,
            transaction_fee_lamports=0,
            payer=payer_pubkey,
            payer_auracle_token_account=payer_token_pubkey,
            market_state=market_state,
        )

        blockhash = self._client.get_latest_blockhash().value.blockhash
        tx = Transaction(fee_payer=payer_pubkey, recent_blockhash=blockhash)
        tx.add(ix)
        fee_resp = self._client.get_fee_for_message(tx.compile_message())
        transaction_fee_lamports = fee_resp.value

        ix = self._build_resolve_event_ix(
            event_id=event_id,
            truth_signal=truth_signal,
            transaction_fee_lamports=transaction_fee_lamports,
            payer=payer_pubkey,
            payer_auracle_token_account=payer_token_pubkey,
            market_state=market_state,
        )
        tx = Transaction(fee_payer=payer_pubkey, recent_blockhash=blockhash)
        tx.add(ix)

        sig = self._client.send_transaction(tx, payer)
        return str(sig.value)


class NaturalLanguageOracle:
    def __init__(self, client: AuracleClient) -> None:
        self._client = client

    def verify_by_name(
        self,
        name: str,
        payer: Keypair,
        payer_auracle_token_account: Optional[str] = None,
        truth_signal: Optional[bytes] = None,
    ) -> str:
        event_id = _event_id_from_name(name)
        return self._client.query_truth(
            event_id=event_id,
            payer=payer,
            payer_auracle_token_account=payer_auracle_token_account,
            truth_signal=truth_signal,
        )


TOKEN_PROGRAM_ID = Pubkey.from_string("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
SYSTEM_PROGRAM_ID = Pubkey.from_string("11111111111111111111111111111111")

