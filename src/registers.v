module cpuid

import strings

struct Registers {
pub mut:
	eax u32
	ebx u32
	ecx u32
	edx u32
}

[inline]
fn (r Registers) str() string {
	return r.stringify('abcd')
}

[inline]
fn (r Registers) bytes() []u8 {
	return r.str().bytes()
}

fn (r Registers) stringify(reg_order string) string {
	mut str := ''
	if reg_order.len > 4 {
		println('Error: "${reg_order}" is an invalid string. It must be less than 5 characters in length.')
	}
	for val in reg_order {
		match val {
			`a` { str += u32_to_bytes(r.eax).reverse().bytestr() }
			`b` { str += u32_to_bytes(r.ebx).reverse().bytestr() }
			`c` { str += u32_to_bytes(r.ecx).reverse().bytestr() }
			`d` { str += u32_to_bytes(r.edx).reverse().bytestr() }
			else { println('Error: "${reg_order}" is an invalid string. It must only contain a, b, c, or d.') }
		}
	}
	return str
}

fn (r Registers) stringify_opt(reg_order string) !string {
	if reg_order.len > 4 {
		return error('"${reg_order}" is an invalid string. It must be less than 5 characters in length.')
	}

	mut str := ''
	mut dupl_checker := []u8{cap: 4}
	for val in reg_order.to_lower() {
		// check if there are duplicates in reg_order
		if val in dupl_checker {
			return error('"${reg_order}" is an invalid string. It cannot contain repeating characters.')
		}
		dupl_checker << val

		match val {
			`a` { str += u32_to_bytes(r.eax).reverse().bytestr() }
			`b` { str += u32_to_bytes(r.ebx).reverse().bytestr() }
			`c` { str += u32_to_bytes(r.ecx).reverse().bytestr() }
			`d` { str += u32_to_bytes(r.edx).reverse().bytestr() }
			else { return error('"${reg_order}" is an invalid string. It must only contain a, b, c, or d.') }
		}
	}
	return str
}

// u32_to_bytes converts the value of an unsigned integer to 4 bytes.
fn u32_to_bytes(x u32) []u8 {
	mut bytes := []u8{cap: 4}
	for i := 24; i >= 8; i -= 8 {
		bytes << u8((x >> i) & 0xff)
	}
	bytes << u8(x & 0xff)
	return bytes //.reverse()
}

// u32_to_bits converts the values of each bit to an integer.
fn u32_to_bits(x u32) []bool {
	mut bits := []bool{cap: 32}
	for pos in 0 .. 32 {
		bits << if get_bits(x, pos, 1) == 1 { true } else { false }
	}
	return bits
}

// get_bits returns the value beginning at `pos` to `amount`. Least significant bit.
[inline]
fn get_bits(src u32, pos int, amount int) int {
	return int(((1 << amount) - 1) & (src >> pos))
}

fn print_bits(x u32) {
	mut bldr := strings.new_builder(36)
	bits := u32_to_bits(x)
	for i, bit in bits {
		if i % 8 == 0 && i != 0 {
			bldr.write_string(' ')
		}
		bldr.write_string(if bit { '1' } else { '0' })
	}
	println(bldr.str())
}
