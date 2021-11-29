package main
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"
import "core:crypto/md5"
import "core:crypto/chacha20poly1305"

TAG   : [chacha20poly1305.TAG_SIZE]byte
KEY   : [chacha20poly1305.KEY_SIZE]byte
NONCE : [chacha20poly1305.NONCE_SIZE]byte

Entry :: struct {
	website: string,
	username: string,
	password_hash: string,
}

main :: proc() {
	args := os._alloc_command_line_arguments()
	
	db := read_db()
	if len(db) < 16 {
		fmt.println("Please enter a new master password: ")
		input := "hunter2"

		master_hash := md5.hash_string(input)
		os.write_entire_file("db", master_hash[:])
	}

	if len(args) < 2 {
		fmt.println("Subcommands: new, delete, list")
		return
	}

	switch args[1] {
	case "new":{
		if len(args) != 5 {
			fmt.println("Usage: new <website> <username> <password>")
		} else {
			// Overwrite previous entries if they exist
			delete(args[2], args[3])
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
	}}
}