package com.coinbase.wallet.store.models

class MemoryStoreKey<T>(
    id: String,
    uuid: String? = null,
    syncNow: Boolean = false,
    clazz: Class<T>
) : StoreKey<T>(id, uuid, syncNow, StoreKind.MEMORY, clazz)
