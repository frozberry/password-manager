package main

import "core:fmt"
import "core:mem"
import "core:crypto/md5"
import "core:crypto/chacha20poly1305"

// Global (mutable) values used for encryption/decryption
TAG   : [chacha20poly1305.TAG_SIZE]byte
KEY   : [chacha20poly1305.KEY_SIZE]byte
NONCE : [chacha20poly1305.NONCE_SIZE]byte

// These would be the raw sequences stored in the database file
stored_master   := []byte{ 148, 161, 112, 132, 136, 42, 120, 180, 97, 68, 134, 55, 133, 183, 124, 147 }
stored_password := []byte{ 9, 198, 56, 8, 182, 196, 99, 205, 24, 0, 163, 231, 83, 212, 33, 228, 184, 73, 134, 84, 129, 99, 109 }

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

main :: proc() {
   // Verify that the user given master password is the same as our stored one
   master_password   := "given_by_the_user!" // Modify to fail the check
   user_input_master := md5.hash_string(master_password)

   // If applicable, apply any shuffling to the user given key before checking if it matches the stored master key

   assert(hashes_match(user_input_master[:], stored_master[:]), "Invalid master password!")

   // Setup nonce and key. These must remain the same between runs otherwise we can't decrypt our stored data
   copy(NONCE[:], []byte{ 0xCA, 0xFE, 0xBE, 0xEF/*, ... */ }) // Setup our program-specific nonce, could also be set when we create it above

   // If applicable, unshuffle the stored/user given master key here

   copy(KEY[:], user_input_master[:]) // Make the hashed password the decryption key
                                      // (could also use stored_master since it's known to be the same at this point in the program)

   // If the user wants to store a new password: convert it to bytes (with transmute) first
   new_password_raw   := "this!!is_my.password994"
   new_password_bytes := transmute([]byte)new_password_raw // This does not allocate, we're just asking Odin to "reinterpret" the string as an array of bytes
   fmt.println(" Original:", hex_string(new_password_bytes))

   // Used when storing a password
   encrypted := encrypt(new_password_bytes) // Can also apply any shuffling here
   assert(hashes_match(encrypted[:], stored_password[:]), "Stored password and encrypted password did not match!")

   fmt.println("Encrypted:", hex_string(encrypted))

   // Used when retrieving a password
   decrypted := decrypt(encrypted) // Can also unshuffle here
   fmt.println("Decrypted:", hex_string(decrypted))
   fmt.println(" Contents:", string(decrypted[:]))

   assert(hashes_match(decrypted[:], new_password_bytes[:]), "Decrypted password did not match the original!")
}

// Utility proc for turning byte arrays into hex strings
hex_string :: proc(bytes: []byte, allocator := context.temp_allocator) -> string {
    lut : [16]byte = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
    buf := make([]byte, len(bytes) * 2, allocator);

    for i: i32 = 0; i < i32(len(bytes)); i += 1 {
        buf[i * 2 + 0] = lut[bytes[i] >> 4 & 0xF];
        buf[i * 2 + 1] = lut[bytes[i]      & 0xF];
    }

    return string(buf);
}

// Utility proc for checking if byte arrays (usually hashes) are exactly the same
hashes_match :: #force_inline proc "contextless"(lhs: []byte, rhs: []byte) -> bool {
   return mem.compare(lhs, rhs) == 0
}