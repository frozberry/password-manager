package main
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"

input_to_bytes :: proc(website: string, username: string, password: string) -> []u8 {
	// Stylistically, is it better to just do this all inline?
	w_len := u8(len(website))
	u_len := u8(len(username))
	p_len := u8(len(password))

	entry := [dynamic]u8{w_len, u_len, p_len}

	w_bytes := string_to_bytes(website)
	u_bytes := string_to_bytes(username)
	p_bytes := string_to_bytes(password)

	// Is there an easier way to combine two arrays? In rust I can call .flatten()
	for b in w_bytes {
		append(&entry, b)
	}
	for b in u_bytes {
		append(&entry, b)
	}
	for b in p_bytes {
		append(&entry, b)
	}

	return entry[:]
}

// Is this supposed to be a lib function now?
string_to_bytes :: proc(s: string)  -> [dynamic]u8 {
	pointer := strings.ptr_from_string(s)
	bytes := [dynamic]u8{}

	for i in 0..<len(s) {
		append(&bytes, pointer^)
		pointer = (cast(^u8)(uintptr(pointer) + 1 ))
	}

	return bytes
} 

// Is this supposed to be a lib function?
bytes_to_string :: proc(bytes: []u8 ) -> string {
	return strings.string_from_ptr(&bytes[0], len(bytes))
}