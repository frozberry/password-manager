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

		case "list": {
			list()
		}

		case "delete": {
			if len(args) != 5 {
					fmt.println("Usage: delete <website>")
				} else {
					delete(args[2])
				}
			}
		
		case: {
			fmt.println("Subcommands: new, delete, list")
		}
	}
}

new :: proc(website: string, username: string, password: string) {
	fmt.println("new")

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


	db := read_db()
	for b in entry {
		append(&db, b)
	}
}

list :: proc() {
	fmt.println("list")
}

delete :: proc(website: string) {
	fmt.println("delete")
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
	e := Entry{"website", "username", "pass"}
	todo := []Entry{e}
	return todo
}

// Is this supposed to be a lib function for now?
string_to_bytes :: proc(s: string)  -> [dynamic]u8 {
	pointer := strings.ptr_from_string(s)
	bytes := [dynamic]u8{}

	for i in 0..<len(s) {
		append(&bytes, pointer^)
		pointer = (cast(^u8)(uintptr(pointer) + 1 ))
	}

	return bytes
} 
