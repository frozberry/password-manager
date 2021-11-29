package main
import "core:fmt"
import "core:strings"
import "core:slice"
import "core:os"
import "core:crypto/md5"
import "core:crypto/chacha20poly1305"
import "core:mem"



encrypt :: proc(plaintext: []byte) -> []byte {
   given_ciphertext := make([]byte, len(plaintext)) // Allocate enough memory for our ciphertext

   chacha20poly1305.encrypt(
      given_ciphertext[:],
      TAG[:],
      KEY[:],
      NONCE[:],
      nil,
      plaintext,
   )

   return given_ciphertext
}

decrypt :: proc(ciphertext: []byte) -> []byte {
   given_plaintext := make([]byte, len(ciphertext)) // Allocate enough memory for our decrypted message

   chacha20poly1305.decrypt(
      given_plaintext[:],
      TAG[:],
      KEY[:],
      NONCE[:],
      nil,
      ciphertext[:],
   )

   return given_plaintext
}

hashes_match :: #force_inline proc "contextless"(lhs: []byte, rhs: []byte) -> bool {
   return mem.compare(lhs, rhs) == 0
}