module vnostr
import x.json2

// VNFilterParams is a struct that holds the parameters for creating a new `VNFilter` with the static function `VNFilter.new`.
@[params]
pub struct VNFilterParams {
pub:
	ids     ?[]string
	authors ?[]string
	kinds   ?[]u16
	since   ?u64
	until   ?u64
	limit   ?u32
	tags    ?[][]string
}

// VNFilter is a struct that holds the filter for events.
pub struct VNFilter {
pub:
	ids     ?[]string
	authors ?[]string
	kinds   ?[]u16
	since   ?u64
	until   ?u64
	limit   ?u32
	tags    ?[][]string
}

// VNFilter.new creates a new VNFilter.
// It takes a `VNFilterParams` struct as a parameter but also allows you to pass only the fields you want to set.
// For example, you can create a new `VNFilter` with only the `ids` field set like this:
// ```
// filter := VNFilter.new(ids: ['1', '2'])
// ```
// This will create a new `VNFilter` with the `ids` field set to `['1', '2']` and all other fields set to `none`.
pub fn VNFilter.new(p VNFilterParams) VNFilter {
	return VNFilter{
		ids:     p.ids
		authors: p.authors
		kinds:   p.kinds
		since:   p.since
		until:   p.until
		limit:   p.limit
		tags:    p.tags
	}
}

pub fn (f VNFilter) json_str() string {
	mut data := map[string]json2.Any
	if ids := f.ids {
		arr := []json2.Any{ids}
		data['ids'] = arr
	}
	if authors := f.authors {
		arr := []json2.Any{authors}
		data['authos'] = arr
	}
	if kinds := f.kinds {
		arr := []json2.Any{kinds}
		data['kinds'] = arr
	}
	if since := f.since {
		data['since'] = since
	}
	if until := f.until {
		data['until'] = until
	}
	if limit := f.limit {
		data['limit'] = limit
	}
	if tags := f.tags {
		for tag in tags {
			if tag.len > 0 {
				tag_key := '${tag[0]}'
				if tag.len == 1 {
					data[tag_key] = json2.encode(['']) // TODO: Not sure about this
				} else {
					data[tag_key] = json2.encode(tag[1..])
				}
			}
		}
	}

	return json2.encode(data)
}