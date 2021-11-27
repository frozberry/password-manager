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
    fmt.println(args)

    if len(args) < 2 {
        fmt.println("Subcommands: new, delete, list")
        return
    } 
    
    switch args[1] {
        case "new": {
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
}

list :: proc() {
    fmt.println("list")
}

delete :: proc(website: string) {
    fmt.println("delete")
}