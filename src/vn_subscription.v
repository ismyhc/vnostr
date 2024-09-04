module vnostr

import rand

pub struct VNSubscription {
pub:
	id      string
	filters []VNFilter
}

pub fn new_subscription(id ?string, filters []VNFilter) VNSubscription {
	the_id := id or { rand.uuid_v4() }
	return VNSubscription{
		id:      the_id
		filters: filters
	}
}
