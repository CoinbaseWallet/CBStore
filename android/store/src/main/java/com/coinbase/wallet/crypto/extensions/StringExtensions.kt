package com.coinbase.wallet.crypto.extensions

import android.util.Base64
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

/**
 * Hash the string using sha256
 *
 * @throws `NoSuchAlgorithmException` when unable to sha256
 */
@Throws(NoSuchAlgorithmException::class)
fun String.sha256(): String {
    val md = MessageDigest.getInstance("SHA-256")
    md.update(this.toByteArray())
    return md.digest().toHexString()
}

/**
 * Parse AES256 GCM payload i.e. IV (12 bytes) + Auth Tag (16 bytes) + CiperText (rest of bytes)
 *
 * @returns Triple containing UV + Auth Tag + Cipher text
 */
fun String.parseAES256GMPayload(): Triple<ByteArray, ByteArray, ByteArray>? {
    val encryptedData = this.base64DecodedByteArray()
    val ivEndIndex = 12
    val authTagEndIndex = ivEndIndex + 16
    val iv = encryptedData.copyOfRange(0, ivEndIndex)
    val authTag = encryptedData.copyOfRange(ivEndIndex, authTagEndIndex)
    val cipherText = encryptedData.copyOfRange(authTagEndIndex, encryptedData.size)

    return Triple(iv, authTag, cipherText)
}

/**
 * Convert String to ByteArray
 *
 * @throws `IllegalArgumentException` if unable to convert to base64
 */
@Throws(IllegalArgumentException::class)
fun String.base64DecodedByteArray(): ByteArray {
    return Base64.decode(this, Base64.NO_WRAP)
}
