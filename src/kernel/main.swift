@_silgen_name("kmain") public func kmain() {
	let vram = UnsafeMutablePointer<UInt16>(bitPattern: 0xB8000)
	let vramSize = 80 * 25

	var i = 0
	repeat {
		vram?[i] = 0x0F00 | 00 // clear screen
		i += 1
	} while i < vramSize

	vram?[0] = 0x0F53
	vram?[1] = 0x0F6E
	vram?[2] = 0x0F6F
	vram?[3] = 0x0F77
	vram?[4] = 0x0F57
	vram?[5] = 0x0F68
	vram?[6] = 0x0F69
	vram?[7] = 0x0F74
	vram?[8] = 0x0F65
	vram?[9] = 0x0F4F
	vram?[10] = 0x0F53

	let s: StaticString = "Hello, World!"

	i = 0
	var test = s.utf8CodeUnitCount

	while i < s.utf8CodeUnitCount {
		vram?[i] = UInt16(s.utf8Start[i]) | 0xA00
		i += 1
	}
}
