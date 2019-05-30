package com.coinbase.wallet.store.models

class EncryptedSharedPrefsStoreKey<T>(
    id: String,
    uuid: String? = null,
    clazz: Class<T>
) : StoreKey<T>(id, uuid, true, StoreKind.ENCRYPTED_SHARED_PREFERENCES, clazz)
