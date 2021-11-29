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

check_db_exists :: proc() {
	db := read_db()

	if len(db) < 16 {
		fmt.println("Please enter a new master password: ")
		input_password := get_user_input()

		master_hash := md5.hash_string(input_password)
		os.write_entire_file("db", master_hash[:])
	}
}

get_user_input :: proc() -> string {
	buff: [255]u8
    len, err := os.read(os.stdin, buff[:])
	// fmt.println("buffer", buff[:])
	// fmt.println("buffer", buff[:len - 1])
	// fmt.println(bytes_to_string(buff[:len - 1]))
	return bytes_to_string(buff[:len - 1])
}

parse_saved_password_hash :: proc() -> []u8 {
	db := read_db()
	return db[:16]
}

parse_entries :: proc(bytes: []u8) -> []Entry {
	entries := [dynamic]Entry{}
	if len(bytes) == 16 {
		return []Entry{}
	}

	// Can't assign to proc param
	buffer := bytes

	// Ignore master password bytes
	buffer = buffer[16:]

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