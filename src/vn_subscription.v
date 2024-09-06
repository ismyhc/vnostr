module vnostr

import rand

// VNSubscriptionParams is a struct that holds the parameters for creating a new `VNSubscription` with the static function `VNSubscription.new`.
@[params]
pub struct VNSubscriptionParams {
pub:
	id      ?string
	filters []VNFilter
}

// VNSubscription is a struct that holds the subscription for events.
pub struct VNSubscription {
pub:
	id      string
	filters []VNFilter
}

// VNSubscription.new creates a new VNSubscription.
// It takes a `VNSubscriptionParams` struct as a parameter but also allows you to pass only the fields you want to set.
pub fn VNSubscription.new(p VNSubscriptionParams) VNSubscription {
	the_id := p.id or { rand.uuid_v4() }
	return VNSubscription{
		id:      the_id
		filters: p.filters
	}
}
