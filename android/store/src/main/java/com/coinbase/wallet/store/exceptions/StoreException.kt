package com.coinbase.wallet.store.exceptions

internal class StoreException {
    class UnableToCreateObserver : RuntimeException("Unable to create a store value observer")
}
