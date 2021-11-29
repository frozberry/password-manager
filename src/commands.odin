package main
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"


new :: proc(website: string, username: string, password: string) {
	// I convert between bytes and string multiple times here, gross
	// How does encrypt change a global variable???

	password_bytes := string_to_bytes(password)
	encrytped_password := encrypt(password_bytes[:])
	encrytped_password_string := bytes_to_string(encrytped_password)
	entry_bytes := input_to_bytes(website, username, encrytped_password_string)



	db := read_db()
	entries := parse_entries(db[:])

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

	// Should I use the "found" found, or test for empty an Entry?
	if found {
		password_bytes := string_to_bytes(entry.password)
		// Currently only works if I disable checking tag
		decrypted := decrypt(password_bytes[:])

		fmt.println(bytes_to_string(decrypted))
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

	for e in entries {
		if !(e.website == website && e.username == username) {
			append(&new_entries, e)
		}
	}

	new_entries_bytes := [dynamic]u8{}

	// Copy master password
	for i in 0..15 {
		append(&new_entries_bytes, db[i])
	}

	for e in new_entries {
		bytes := input_to_bytes(e.website, e.username, e.password)
		for b in bytes {
			append(&new_entries_bytes, b)
		}
	}

	os.write_entire_file("db", new_entries_bytes[:])
}