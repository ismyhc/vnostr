module vnostr

import encoding.hex
import ismyhc.vsecp256k1
import ismyhc.vbech32

// VNKeyPair is a struct that holds the keypair for Nostr
pub struct VNKeyPair {
	keypair vsecp256k1.KeyPair
pub:
	private_key_bytes []u8
	private_key_hex   string
	private_key_nsec  string
	public_key_bytes  []u8
	public_key_hex    string
	public_key_npub   string
}

// VNKeyPair.new creates a new VNKeyPair
pub fn VNKeyPair.new() !VNKeyPair {
	ctx := vsecp256k1.create_context() or { return error('Failed to create context') }
	private_key_bytes := vsecp256k1.generate_private_key() or {
		ctx.destroy()
		return error('Failed to generate private key')
	}
	return keypair_from_bytes(private_key_bytes, ctx)
}

// VNKeyPair.from_private_key_hex creates a new VNKeyPair from a private key in hex format
pub fn VNKeyPair.from_private_key_hex(pkh string) !VNKeyPair {
	ctx := vsecp256k1.create_context() or { return error('Failed to create context') }
	private_key_bytes := hex.decode(pkh) or {
		ctx.destroy()
		return error('Failed to decode private key')
	}
	return keypair_from_bytes(private_key_bytes, ctx)
}

// VNKeyPair.from_private_key_nsec creates a new VNKeyPair from a private key in bech32 format
pub fn VNKeyPair.from_private_key_nsec(bpk string) !VNKeyPair {
	hrp, private_key_bytes := vbech32.decode_to_base256(bpk) or {
		return error('Failed to decode private key')
	}
	if hrp != 'nsec' {
		return error('Invalid HRP')
	}
	ctx := vsecp256k1.create_context() or { return error('Failed to create context') }
	return keypair_from_bytes(private_key_bytes, ctx)
}

pub fn valid_public_key_hex(pkx string) bool {
	pkb := hex.decode(pkx) or { return false }
	ctx := vsecp256k1.create_context() or { return false }
	if pkb.len != 32 {
		return false
	}
	defer {
		ctx.destroy()
	}
	_ := ctx.create_xonly_pubkey_from_pubkey_bytes(pkb) or { return false }
	return true
}

fn keypair_from_bytes(pkb []u8, ctx &vsecp256k1.Context) !VNKeyPair {
	defer {
		ctx.destroy()
	}
	keypair := ctx.create_keypair(pkb) or { return error('Failed to create keypair') }
	x_pubkey := ctx.create_xonly_pubkey_from_keypair(keypair) or {
		return error('Failed to create xonly pubkey')
	}
	x_pubkey_bytes := ctx.serialize_xonly_pubkey(x_pubkey) or {
		return error('Failed to serialize xonly pubkey')
	}
	bech32_private_key := vbech32.encode_from_base256('nsec', pkb) or {
		return error('Failed to encode private key')
	}
	bech32_public_key := vbech32.encode_from_base256('npub', x_pubkey_bytes) or {
		return error('Failed to encode public key')
	}
	return VNKeyPair{
		keypair:           keypair
		private_key_bytes: pkb
		private_key_hex:   hex.encode(pkb)
		private_key_nsec:  bech32_private_key
		public_key_bytes:  x_pubkey_bytes
		public_key_hex:    hex.encode(x_pubkey_bytes)
		public_key_npub:   bech32_public_key
	}
}

fn (kp VNKeyPair) sign(data []u8) ![]u8 {
	ctx := vsecp256k1.create_context() or { return error('Failed to create context') }
	defer {
		ctx.destroy()
	}
	return ctx.sign_schnorr(data, kp.keypair) or { return error('Failed to sign') }
}
