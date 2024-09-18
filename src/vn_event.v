module vnostr

import encoding.hex
import json
import crypto.sha256
import ismyhc.vsecp256k1

@[params]
pub struct VNEventParams {
pub:
	pubkey     string
	created_at u64
	kind       u16
	tags       [][]string
	content    string
}

pub struct VNEvent {
pub:
	id         string     @[required]
	pubkey     string     @[required]
	created_at u64        @[required]
	kind       u16        @[required]
	tags       [][]string @[required]
	content    string     @[required]
	sig        string     @[required]
}

// Use this for creating a new VNEvent that has not been signed yet.
pub fn VNEvent.new(p VNEventParams) VNEvent {
	return VNEvent{
		id:         ''
		pubkey:     p.pubkey
		created_at: p.created_at
		kind:       p.kind
		tags:       p.tags
		content:    p.content
		sig:        ''
	}
}

pub fn (e &VNEvent) event_relay_message(subscription_id string) string {
	return '["EVENT", "${subscription_id}", ' + json.encode(e) + ']'
}

pub fn (e VNEvent) filter_tags_by_name(tag_name string) [][]string {
	return e.tags.filter(it.len > 0 && it[0] == tag_name)
}

pub fn (e &VNEvent) stringify() string {
	return json.encode(e)
}

pub fn (e &VNEvent) data_for_signature() []u8 {
	return '[0,"${e.pubkey}",${e.created_at},${e.kind},${json.encode(e.tags)},"${e.content}"]'.bytes()
}

pub fn (e &VNEvent) valid_id() bool {
	data := e.data_for_signature()
	return sha256.sum(data).hex() == e.id
}

pub fn (e &VNEvent) pow_difficulty() int {
	bytes := hex.decode(e.id) or {
		println('Invalid hex string')
		return -1
	}

	mut leading_zero_bits := 0

	for b in bytes {
		for i := 7; i >= 0; i-- {
			if (b & (1 << i)) == 0 {
				leading_zero_bits++
			} else {
				return leading_zero_bits
			}
		}
	}

	return leading_zero_bits
}

pub fn (e &VNEvent) valid_signature() bool {
	data := e.data_for_signature()
	id := sha256.sum(data)
	if id.hex() != e.id {
		return false
	}
	pubkey_bytes := hex.decode(e.pubkey) or { return false }
	ctx := vsecp256k1.create_context() or { return false }
	defer {
		ctx.destroy()
	}
	x_pubkey := ctx.create_xonly_pubkey_from_pubkey_bytes(pubkey_bytes) or { return false }
	sig_bytes := hex.decode(e.sig) or { return false }
	return ctx.verify_schnorr(sig_bytes, data, x_pubkey)
}

pub fn (e &VNEvent) sign(kp VNKeyPair) !VNEvent {
	data := e.data_for_signature()
	id := sha256.sum(data).hex()
	sig := kp.sign(data) or { return error('Failed to sign') }
	return VNEvent{
		id:         id
		pubkey:     e.pubkey
		created_at: e.created_at
		kind:       e.kind
		tags:       e.tags
		content:    e.content
		sig:        sig.hex()
	}
}
