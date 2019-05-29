package com.coinbase.wallet.crypto.extensions

import android.util.Base64

// Convert ByteArray to hex encoded string
fun ByteArray.toHexString(): String {
    val result = StringBuffer()
    for (byt in this) {
        val hex = Integer.toString((byt and 0xff) + 0x100, 16).substring(1)
        result.append(hex)
    }

    return result.toString()
}

// Convert ByteArray to base64 String
fun ByteArray.base64EncodedString(): String {
    return Base64.encodeToString(this, Base64.NO_WRAP)
}

private infix fun Byte.and(value: Int) = toInt() and value