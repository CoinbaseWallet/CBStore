package com.coinbase.wallet.store.models

/**
 * Helpers class to wrap optionals in Rx streams
 */
data class Optional<T>(val element: T?)
