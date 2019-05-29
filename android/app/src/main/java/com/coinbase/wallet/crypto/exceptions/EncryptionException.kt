package com.coinbase.wallet.crypto.exceptions

class EncryptionException {
    class InvalidAES256GCMData : RuntimeException("Unable to encrypt data using AES256")
}