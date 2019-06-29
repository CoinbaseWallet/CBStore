package com.coinbase.wallet.store.exceptions

internal open class StoreException(message: String? = null) : RuntimeException(message ?: "") {
    class UnableToCreateObserver : StoreException("Unable to create a store value observer")
    class StoreDestroyed : StoreException("Store destroyed")
}
