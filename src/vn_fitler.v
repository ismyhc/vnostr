module vnostr

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

pub fn new_filter(ids ?[]string, authors ?[]string, kinds ?[]u16, since ?u64, until ?u64, limit ?u32, tags ?[][]string) VNFilter {
	return VNFilter{
		ids:     ids
		authors: authors
		kinds:   kinds
		since:   since
		until:   until
		limit:   limit
		tags:    tags
	}
}
