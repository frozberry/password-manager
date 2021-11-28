package main
import "core:fmt"
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

	password_hash := hash(password)
	new_entry := Entry{website, username, password_hash}
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

read_db :: proc() -> []u8 {
	bytes, success := os.read_entire_file("db")
	if !success {
		fmt.println("There was an error reading the db file")
		}
	return bytes
}

parse_entries :: proc(bytes: []u8) -> []Entry {
	c:= []int{1, 2, 3, 4, 5}
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
