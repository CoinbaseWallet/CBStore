package com.coinbase.wallet.crypto.exceptions

class EncryptionException {
    /**
     * Thrown when unable to encrypt value using AES256 GCM
     */
    class InvalidAES256GCMData : RuntimeException("Unable to encrypt data using AES256 GCM")
}
