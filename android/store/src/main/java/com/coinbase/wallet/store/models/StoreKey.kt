package com.coinbase.wallet.store.models

/*
 * Constructor for creating a custom store key
 *
 * @param id Key unique name
 * @param uuid Optional unique identifier
 * @param kind Type of value to store
 * @param syncNow Determine whether to persist to disk immediately or do it in the background
 *
 * @return A new `StoreKey` instance
 */
open class StoreKey<T>(
    id: String,
    uuid: String? = null,
    val syncNow: Boolean = false,
    val kind: StoreKind,
    val clazz: Class<T>
) {
    val name: String = listOfNotNull(
            kind.name,
            id,
            uuid,
            clazz.simpleName
        )
        .joinToString("_")
}
