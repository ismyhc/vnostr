module vnostr

import json

pub struct VNEvent {
pub:
	id         string
	pubkey     string
	created_at u64
	kind       u16
	tags       [][]string
	content    string
	sig        string
}

pub fn (e &VNEvent) event_relay_message(subscription_id string) string {
	return '["EVENT", "${subscription_id}", ' + json.encode(e) + ']'
}
