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

	db, db_exists := os.read_entire_file("db")

	if !db_exists {
		fmt.println("Create a master password:")

		master_password := get_user_input()
		master_hash := md5.hash_string(master_password)

		db = master_hash[:]

		os.write_entire_file("db", master_hash[:])
	} else {
		fmt.println("Enter your master password:")
		password_input := get_user_input()
		hashed_input := md5.hash_string(password_input)
		saved_password_hash := db[:16]

		assert(hashes_match(saved_password_hash, hashed_input[:]), "Incorrect master password")
	}

	copy_slice(KEY[:], db[:16])

	switch args[0] {
	case "new":{
		if len(args) != 4 {
			fmt.println("Usage: new <website> <username> <password>")
		} else {
			// Overwrite previous entries if they exist
			delete_entry(args[1], args[2])
			new_entry(args[1], args[2], args[3])
		}
	}

	case "get":{
		if len(args) != 3 {
			fmt.println("Usage: get <website> <username>")
		} else {
			get(db, args[1], args[2])
		}
	}

	case "list": {
		list(db)
	}

	case "delete": {
		if len(args) != 3 {
				fmt.println("Usage: delete <website> <username>")
			} else {
				delete_entry(args[1], args[2])
			}
		}
	
	case: {
		fmt.println("Subcommands: new, delete, list")
	}}
}