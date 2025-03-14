import vnostr

fn test_vn_keypair_new() {
	kp := vnostr.VNKeyPair.new() or {
		assert false, 'Failed to create keypair: ${err}'
		return
	}

	assert kp.private_key_bytes.len == 32, 'Private key length should be 32 bytes'
	assert kp.private_key_hex.len == 64, 'Private key hex length should be 64 characters'
	assert kp.public_key_bytes.len == 32, 'Public key length should be 32 bytes'
	assert kp.public_key_hex.len == 64, 'Public key hex length should be 64 characters'
}
