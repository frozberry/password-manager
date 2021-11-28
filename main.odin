package main
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"

Entry :: struct {
	website: string,
	username: string,
	password_hash: string,
}

main :: proc() {
	args := os._alloc_command_line_arguments()

	if len(args) < 2 {
		fmt.println("Subcommands: new, delete, list")
		return
	}

	switch args[1] {
		case "new":{
			if len(args) != 5 {
				fmt.println("Usage: new <website> <username> <password>")
			} else {
				new(args[2], args[3], args[4])
			}
		}

		case "get":{
			if len(args) != 4 {
				fmt.println("Usage: get <website> <username>")
			} else {
				get(args[2], args[3])
			}
		}

		case "list": {
			list()
		}

		case "delete": {
			if len(args) != 4 {
					fmt.println("Usage: delete <website> <username>")
				} else {
					delete(args[2], args[3])
				}
			}
		
		case: {
			fmt.println("Subcommands: new, delete, list")
		}
	}
}

new :: proc(website: string, username: string, password: string) {
	fmt.println("new")

	entry_bytes := input_to_bytes(website, username, password)

	db := read_db()
	for b in entry_bytes {
		append(&db, b)
	}
	os.write_entire_file("db", db[:])
}

get :: proc(website: string, username: string) {
	db := read_db()
	entries := parse_entries(db[:])

	// Duplicate entries should be overwritten by the last match
	entry: Entry
	found := false
	for e in entries {
		if e.website == website && e.username == username {
			entry = e
			found = true
		}
	}

	// Should introduce a the "found", or test for empty Entry?
	if found {
		fmt.println(entry.password_hash)
	} else {
		fmt.println("Website / username combination not found")
	}
}

list :: proc() {
	db := read_db()
	entries := parse_entries(db[:])
	
	for entry in entries {
		fmt.printf("Site: %s, Username: %s\n", entry.website, entry.username)
	}
}

delete :: proc(website: string, username: string) {
	db := read_db()
	entries := parse_entries(db[:])

	new_entries := [dynamic]Entry{}
	exists := false

	for e in entries {
		if !(e.website == website && e.username == username) {
			append(&new_entries, e)
		} else {
			exists = true
		}
	}

	new_entries_bytes := [dynamic]u8{}

	for e in new_entries {
		bytes := input_to_bytes(e.website, e.username, e.password_hash)
		for b in bytes {
			append(&new_entries_bytes, b)
		}
	}

	if (exists) {
		fmt.printf("Succesfully deleted %s %s\n", website, username)
	} else {
		fmt.printf("%s %s does not exist\n", website, username)
	}



	os.write_entire_file("db", new_entries_bytes[:])
}

hash :: proc(password: string) -> string {
	return password
}

read_db :: proc() -> [dynamic]u8 {
	bytes, success := os.read_entire_file("db")
	if !success {
		fmt.println("There was an error reading the db file")
		}
	// When to use to_dyanmic() vs into_dynamic()
	return slice.to_dynamic(bytes)
}

parse_entries :: proc(bytes: []u8) -> []Entry {
	entries := [dynamic]Entry{}

	// Can't assign to proc param
	buffer := bytes

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