package main
import "core:fmt"
import "core:os"


main :: proc() {
    args := os._alloc_command_line_arguments()
    fmt.println(args)

}
