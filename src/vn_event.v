module vnostr

import json

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

pub fn (e &VNEvent) event_relay_message(subscription_id string) string {
	return '["EVENT", "${subscription_id}", ' + json.encode(e) + ']'
}

pub fn (e &VNEvent) stringify() string {
	return json.encode(e)
}
