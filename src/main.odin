package main
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"
import "core:crypto/md5"
import "core:crypto/chacha20poly1305"
import "core:mem"

TAG   : [chacha20poly1305.TAG_SIZE]byte
KEY   : [chacha20poly1305.KEY_SIZE]byte
NONCE : [chacha20poly1305.NONCE_SIZE]byte

Entry :: struct {
	website: string,
	username: string,
	password: string,
}

main :: proc() {
	args := os._alloc_command_line_arguments()
	args = args[1:]
	if len(args) < 1 {
		fmt.println("Subcommands: new, delete, list")
		return
	}

	check_db_exists()

	fmt.println("Master password:")
	input_password := get_user_input()
	input_hash := md5.hash_string(input_password)
	saved_password_hash := parse_saved_password_hash()
	assert(hashes_match(saved_password_hash, input_hash[:]), "Incorrect master password")

	copy_slice(KEY[:], input_hash[:])

	switch args[1] {
	case "new":{
		if len(args) != 4 {
			fmt.println("Usage: new <website> <username> <password>")
		} else {
			// Overwrite previous entries if they exist
			delete(args[1], args[2])
			new(args[1], args[2], args[3])
		}
	}

	case "get":{
		if len(args) != 3 {
			fmt.println("Usage: get <website> <username>")
		} else {
			get(args[1], args[2])
		}
	}

	case "list": {
		list()
	}

	case "delete": {
		if len(args) != 3 {
				fmt.println("Usage: delete <website> <username>")
			} else {
				delete(args[1], args[2])
			}
		}
	
	case: {
		fmt.println("Subcommands: new, delete, list")
	}}
}