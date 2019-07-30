package com.coinbase.wallet.crypto.extensions

import android.util.Base64

/**
 * Convert ByteArray to base64 String
 */
fun ByteArray.base64EncodedString(): String {
    return Base64.encodeToString(this, Base64.NO_WRAP)
}
