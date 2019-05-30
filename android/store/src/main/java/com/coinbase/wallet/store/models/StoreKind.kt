package com.coinbase.wallet.store.models

enum class StoreKind {
    /**
     * Stores plaintext key/value entries in Android's SharedPreferences
     */
    SHARED_PREFERENCES,

    /**
     * Stores plaintext key/value entries in memory. Mainly used as a simple caching solution
     */
    MEMORY,

    /**
     * Stores encrypted value in Android's SharedPreferences using Android KeyStore
     */
    ENCRYPTED_SHARED_PREFERENCES
}