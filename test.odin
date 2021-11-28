package main
import "core:fmt"
import "core:os"

main :: proc() {
	                                  bytes, err := os.read_entire_file("foo.txt")
	                                              fmt.println(bytes)
	                                                          fmt.println(err)
                                                          }
