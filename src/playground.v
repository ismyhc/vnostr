// module main

// import vnostr

// // This is a playground file. It is not compiled with the rest of the project.
// fn main() {
// 	kp := vnostr.VNKeyPair.new() or { return }

// 	evt := vnostr.VNEvent.new(vnostr.VNEventParams{
// 		pubkey:     kp.public_key_hex
// 		created_at: 1234567890
// 		kind:       1
// 		tags:       [['tag1', 'tag2']]
// 		content:    'Hello, world!'
// 	})

// 	signed_evet := evt.sign(kp) or { return }

// 	println(signed_evet.valid_signature())

// 	dump(signed_evet.stringify())

// 	bing := ret() or {
// 		println(err.str())
// 		return
// 	}
// }

// fn ret() !string {
// 	if 0 == 1 {
// 		return 'hello'
// 	}
// 	return error('fuck you')
// }
