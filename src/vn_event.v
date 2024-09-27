module vnostr

import encoding.hex
import json
import x.json2
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
	return '["EVENT", "${subscription_id}", ${json.encode(e)}]'
}

pub fn (e &VNEvent) event_client_message() string {
	return '["EVENT", ${json.encode(e)}]'
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

pub struct RelayMessageEvent {
	pub:
		subscription_id string
		event 			VNEvent
}

pub struct RelayMessageOK {
	pub:
		event_id	string
		accepted	bool
		message		string
}

pub struct RelayMessageEOSE {
	pub:
		subscription_id string
}

pub struct RelayMessageClosed {
	pub:
		subscription_id string
		message			string
}

pub struct RelayMessageNotice {
	pub:
		message			string
}

pub type RelayMessage = RelayMessageEvent | RelayMessageOK | RelayMessageEOSE | RelayMessageClosed | RelayMessageNotice

pub fn get_relay_message(msg []u8) !RelayMessage {
	data := json2.raw_decode(msg.bytestr()) or { 
		return err
	}
	data_array := data.arr()
	if data_array.len == 0 {
		return error("Invalid Relay Message")
	}

	event_message_type := data_array[0].str()
	
	match event_message_type {
		"EVENT" {
			if data_array.len == 3 {
				ev := data_array[2].str()
				event := json.decode(VNEvent, ev) or {
					return err
				}
				return vnostr.RelayMessageEvent{
					subscription_id: data_array[1].str() 
					event: event
				}
			}
		}
		"OK" {
			if data_array.len == 4 {
				return vnostr.RelayMessageOK{
					event_id: data_array[1].str()
					accepted: data_array[2].bool()
					message: data_array[3].str()
				}
			}
		}
		"EOSE" {
			if data_array.len == 2 {
				return vnostr.RelayMessageEOSE{
					subscription_id: data_array[1].str()
				}
			}
		}
		"CLOSED" {
			if data_array.len == 3 {
				return vnostr.RelayMessageClosed{
					subscription_id: data_array[1].str()
					message: data_array[2].str()
				}
			}
		}
		"NOTICE" {
			if data_array.len == 2 {
				return vnostr.RelayMessageNotice{
					message: data_array[1].str()
				}
			}
		}
		else {
			return error("Invalid Relay Message")
		}
	}

	return error("Invalid Relay Message")
}
