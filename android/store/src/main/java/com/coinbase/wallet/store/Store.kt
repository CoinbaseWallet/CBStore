package com.coinbase.wallet.store

import android.content.Context
import com.coinbase.wallet.store.exceptions.StoreException
import com.coinbase.wallet.store.interfaces.Storage
import com.coinbase.wallet.store.interfaces.StoreInterface
import com.coinbase.wallet.store.models.Optional
import com.coinbase.wallet.store.models.StoreKey
import com.coinbase.wallet.store.models.StoreKind
import com.coinbase.wallet.store.storages.EncryptedSharedPreferencesStorage
import com.coinbase.wallet.store.storages.MemoryStorage
import com.coinbase.wallet.store.storages.SharedPreferencesStorage
import io.reactivex.Observable
import io.reactivex.subjects.BehaviorSubject
import java.util.concurrent.locks.ReentrantReadWriteLock
import kotlin.concurrent.read
import kotlin.concurrent.write

class Store(context: Context) : StoreInterface {
    private val prefsStorage = SharedPreferencesStorage(context)
    private val encryptedPrefsStorage = EncryptedSharedPreferencesStorage(context)
    private val memoryStorage = MemoryStorage()
    private val changeObservers = mutableMapOf<String, Any>()
    private val accessLock = ReentrantReadWriteLock()
    private val changeObserversLock = ReentrantReadWriteLock()

    var isDestroyed: Boolean = false
        private set

    override fun <T> set(key: StoreKey<T>, value: T?) {
        var hasObserver = false
        accessLock.read {
            hasObserver = hasObserver(key.name)

            if (isDestroyed) return

            storageForKey(key).set(key, value)
        }

        if (hasObserver && isDestroyed) {
            observer(key).onError(StoreException.StoreDestroyed())
        } else if (!isDestroyed) {
            observer(key).onNext(Optional(value))
        }
    }

    override fun <T> get(key: StoreKey<T>): T? = accessLock.read {
        return storageForKey(key).get(key)
    }

    override fun <T> has(key: StoreKey<T>): Boolean = accessLock.read {
        return get(key) != null
    }

    override fun <T> observe(key: StoreKey<T>): Observable<Optional<T>> = accessLock.read {
        return observer(key).hide()
    }

    override fun destroy() = accessLock.write {
        if (isDestroyed) return

        isDestroyed = true
        deleteAllEntries(kinds = StoreKind.values())
    }

    override fun removeAll(kinds: Array<StoreKind>) = accessLock.write {
        if (isDestroyed) return

        deleteAllEntries(kinds = StoreKind.values())
    }

    // Private helpers

    private fun deleteAllEntries(kinds: Array<StoreKind>) {
        kinds.forEach { kind ->
            when (kind) {
                StoreKind.SHARED_PREFERENCES -> prefsStorage.destroy()
                StoreKind.ENCRYPTED_SHARED_PREFERENCES -> encryptedPrefsStorage.destroy()
                StoreKind.MEMORY -> memoryStorage.destroy()
            }
        }
    }

    private fun <T> storageForKey(key: StoreKey<T>): Storage {
        return when (key.kind) {
            StoreKind.SHARED_PREFERENCES -> prefsStorage
            StoreKind.ENCRYPTED_SHARED_PREFERENCES -> encryptedPrefsStorage
            StoreKind.MEMORY -> memoryStorage
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun <T> observer(key: StoreKey<T>): BehaviorSubject<Optional<T>> {
        // Check if we have an observer registered in concurrent mode
        var currentObserver: BehaviorSubject<Optional<T>>? = null
        changeObserversLock.read {
            currentObserver = changeObservers[key.name] as? BehaviorSubject<Optional<T>>
        }

        val anObserver = currentObserver
        if (anObserver != null) {
            return anObserver
        }

        // If we can't find an observer, enter serial mode and check or create new observer
        var newObserver: BehaviorSubject<Optional<T>>? = null
        val value = get(key)

        changeObserversLock.write {
            changeObservers[key.name]?.let { return it as BehaviorSubject<Optional<T>> }

            val observer = BehaviorSubject.create<Optional<T>>()
            changeObservers[key.name] = observer
            newObserver = observer

            observer.onNext(Optional(value))
        }

        return newObserver ?: throw StoreException.UnableToCreateObserver()
    }

    private fun hasObserver(keyName: String): Boolean = changeObserversLock.read {
        changeObservers[keyName] != null
    }
}
