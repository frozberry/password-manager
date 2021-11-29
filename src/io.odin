package main
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"
import "core:crypto/md5"
import "core:crypto/chacha20poly1305"

read_db :: proc() -> [dynamic]u8 {
	bytes, success := os.read_entire_file("db")
	if !success {
		fmt.println("db file is missing")
		}
	// When to use to_dyanmic() vs into_dynamic()
	return slice.to_dynamic(bytes)
}

parse_entries :: proc(bytes: []u8) -> []Entry {
	entries := [dynamic]Entry{}
	if len(bytes) == 0 {
		return []Entry{}
	}

	// Can't assign to proc param
	buffer := bytes

	master_bytes := buffer[:16]
	buffer = buffer[16:]

	// Incomplete
	// if !hashes_match(master_bytes, md5.hash_string(user_input_master)) {
	// 	fmt.println("Incorrect password, prog should re-prompt")
	// }

	// I'm guessing there's a library for this?
	for true {
		w_len := buffer[0]
		u_len := buffer[1]
		p_len := buffer[2]

		buffer = buffer[3:]

		w_bytes := buffer[:w_len]
		buffer = buffer[w_len:]

		u_bytes := buffer[:u_len]
		buffer = buffer[u_len:]

		p_bytes := buffer[:p_len]
		buffer = buffer[p_len:]

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