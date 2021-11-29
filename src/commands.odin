package main
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"


new :: proc(website: string, username: string, password: string) {
	entry_bytes := input_to_bytes(website, username, password)

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

	for e in entries {
		if !(e.website == website && e.username == username) {
			append(&new_entries, e)
		}
	}

	new_entries_bytes := [dynamic]u8{}

	for e in new_entries {
		bytes := input_to_bytes(e.website, e.username, e.password_hash)
		for b in bytes {
			append(&new_entries_bytes, b)
		}
	}

	os.write_entire_file("db", new_entries_bytes[:])
}