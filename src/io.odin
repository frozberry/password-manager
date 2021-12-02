package main
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"
import "core:crypto/md5"
import "core:crypto/chacha20poly1305"

get_user_input :: proc() -> string {
	// This caused a lot of pain, still don't fully understand the fix
	buff := make([]u8, 255, context.temp_allocator)
    len, _ := os.read(os.stdin, buff[:])
	return bytes_to_string(buff[:len - 1])
}


// I added an bool return value because you did in your example
// But is it really necesarry here? How would I handle an error occuring?
buff_reader :: proc(bytes: ^[]u8, length: u8) -> ([]u8, bool) {
	if len(bytes) <= 0 {
		return []u8{}, false
	}

	read := bytes[:length]
	bytes^ = bytes^[length:]
	return read, true
} 

parse_entries :: proc(bytes: []u8) -> []Entry {
	entries := [dynamic]Entry{}
	if len(bytes) == 16 {
		return []Entry{}
	}

	// Can't assign to proc param
	buffer := bytes

	// Ignore master password bytes
	_, _ = buff_reader(&buffer, 16)

	for true {
		w_len := buffer[0]
		u_len := buffer[1]
		p_len := buffer[2]

		buffer = buffer[3:]

		w_bytes, _ := buff_reader(&buffer, w_len)
		u_bytes, _ := buff_reader(&buffer, u_len)
		p_bytes, _ := buff_reader(&buffer, p_len)

		website := bytes_to_string(w_bytes)
		username := bytes_to_string(u_bytes)
		password := bytes_to_string(p_bytes)

		entry := Entry{website, username, password}
		append(&entries, entry)

		if len(buffer) == 0 {
			break
		}
	}

	return entries[:]
}