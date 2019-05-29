package com.coinbase.wallet.stores.models

class SharedPrefsStoreKey<T>(
    id: String,
    uuid: String? = null,
    syncNow: Boolean = false,
    clazz: Class<T>
) : StoreKey<T>(id, uuid, syncNow, StoreKind.SHARED_PREFERENCES, clazz)