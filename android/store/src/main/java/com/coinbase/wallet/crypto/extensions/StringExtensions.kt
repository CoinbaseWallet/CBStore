package com.coinbase.wallet.crypto.extensions

import android.util.Base64

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
