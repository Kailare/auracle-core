import { createHash } from "crypto";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import {
  Connection,
  Keypair,
  PublicKey,
  SystemProgram,
  Transaction,
  TransactionInstruction,
} from "@solana/web3.js";
import { getAssociatedTokenAddress } from "@solana/spl-token";
import { struct, u64, blob } from "@coral-xyz/borsh";
import BN from "bn.js";

const env = z.object({
  RPC_URL: z.string().min(1),
  PROGRAM_ID: z.string().min(1),
  AURACLE_MINT: z.string().min(1),
  WALLET_SECRET_KEY: z.string().min(1),
});

const config = env.parse(process.env);
const connection = new Connection(config.RPC_URL, "confirmed");
const programId = new PublicKey(config.PROGRAM_ID);
const auracleMint = new PublicKey(config.AURACLE_MINT);
const wallet = Keypair.fromSecretKey(
  Uint8Array.from(JSON.parse(config.WALLET_SECRET_KEY))
);

const resolveLayout = struct([
  u64("event_id"),
  blob(32, "truth_signal"),
  u64("transaction_fee_lamports"),
]);

function discriminator(name: string): Buffer {
  return createHash("sha256").update(`global:${name}`).digest().subarray(0, 8);
}

function parseTruthSignal(input?: string): Buffer {
  if (!input) {
    return Buffer.alloc(32);
  }
  const normalized = input.startsWith("0x") ? input.slice(2) : input;
  if (/^[0-9a-fA-F]{64}$/.test(normalized)) {
    return Buffer.from(normalized, "hex");
  }
  return Buffer.from(input, "base64");
}

async function buildResolveEventIx(
  eventId: number,
  truthSignal: Buffer,
  transactionFeeLamports: number
): Promise<TransactionInstruction> {
  const [marketState] = PublicKey.findProgramAddressSync(
    [Buffer.from("market"), Buffer.from(new BN(eventId).toArray("le", 8))],
    programId
  );
  const payerTokenAccount = await getAssociatedTokenAddress(
    auracleMint,
    wallet.publicKey,
    false
  );

  const data = Buffer.alloc(8 + resolveLayout.span);
  discriminator("resolve_event").copy(data, 0);
  resolveLayout.encode(
    {
      event_id: new BN(eventId),
      truth_signal: truthSignal,
      transaction_fee_lamports: new BN(transactionFeeLamports),
    },
    data,
    8
  );

  return new TransactionInstruction({
    programId,
    keys: [
      { pubkey: wallet.publicKey, isSigner: true, isWritable: true },
      { pubkey: marketState, isSigner: false, isWritable: true },
      { pubkey: payerTokenAccount, isSigner: false, isWritable: true },
      { pubkey: auracleMint, isSigner: false, isWritable: false },
      { pubkey: TOKEN_PROGRAM_ID, isSigner: false, isWritable: false },
      { pubkey: SystemProgram.programId, isSigner: false, isWritable: false },
    ],
    data,
  });
}

const server = new McpServer({
  name: "auracle-mcp",
  version: "0.1.0",
});

server.tool(
  "get_balance",
  {
    type: "object",
    properties: {},
    required: [],
  },
  async () => {
    const tokenAccount = await getAssociatedTokenAddress(
      auracleMint,
      wallet.publicKey,
      false
    );
    const [lamports, tokenBalance] = await Promise.all([
      connection.getBalance(wallet.publicKey),
      connection.getTokenAccountBalance(tokenAccount).catch(() => null),
    ]);

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(
            {
              wallet: wallet.publicKey.toBase58(),
              lamports,
              aura: tokenBalance?.value?.uiAmount ?? 0,
            },
            null,
            2
          ),
        },
      ],
    };
  }
);

server.tool(
  "resolve_event",
  {
    type: "object",
    properties: {
      event_id: { type: "number" },
      truth_signal: { type: "string", description: "Hex (64) or base64." },
    },
    required: ["event_id"],
  },
  async ({ event_id, truth_signal }) => {
    const signal = parseTruthSignal(truth_signal);
    if (signal.length !== 32) {
      throw new Error("truth_signal must decode to 32 bytes.");
    }

    const ix = await buildResolveEventIx(event_id, signal, 0);
    const blockhash = await connection.getLatestBlockhash();
    const tx = new Transaction({
      feePayer: wallet.publicKey,
      recentBlockhash: blockhash.blockhash,
    }).add(ix);

    const feeLamports = await connection.getFeeForMessage(tx.compileMessage());
    const finalIx = await buildResolveEventIx(event_id, signal, feeLamports);
    const finalTx = new Transaction({
      feePayer: wallet.publicKey,
      recentBlockhash: blockhash.blockhash,
    }).add(finalIx);

    const sig = await connection.sendTransaction(finalTx, [wallet]);

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(
            {
              signature: sig,
              event_id,
              fee_lamports: feeLamports,
            },
            null,
            2
          ),
        },
      ],
    };
  }
);

const TOKEN_PROGRAM_ID = new PublicKey(
  "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
);

async function main(): Promise<void> {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});

