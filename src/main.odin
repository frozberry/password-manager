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
	if len(args) < 2 {
		fmt.println("Subcommands: new, delete, list")
		return
	}

	check_db_exists()

	fmt.println("Master password:")
	input_password := get_user_input()
	fmt.println("input_password", input_password)
	input_hash := md5.hash_string(input_password)
	copy_slice(KEY[:], input_hash[:])

	saved_password_hash := parse_saved_password_hash()

	assert(hashes_match(saved_password_hash, input_hash[:]), "Incorrect master password")

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