package com.coinbase.wallet.store.storages

import android.content.Context
import android.content.SharedPreferences
import com.coinbase.wallet.store.interfaces.Storage
import com.coinbase.wallet.store.models.StoreKey
import com.coinbase.wallet.store.utils.JSON

internal class SharedPreferencesStorage(context: Context) : Storage {
    private val preferences = context.getSharedPreferences("CBStore.plaintext", Context.MODE_PRIVATE)

    override fun <T> set(key: StoreKey<T>, value: T?) {
        val editor: SharedPreferences.Editor = if (value == null) {
            preferences.edit().remove(key.name)
        } else {
            when (key.clazz.javaClass::class.java) {
                String::class.java -> preferences.edit().putString(key.name, value as String)
                Int::class.java -> preferences.edit().putInt(key.name, value as Int)
                Boolean::class.java -> preferences.edit().putBoolean(key.name, value as Boolean)
                Float::class.java -> preferences.edit().putFloat(key.name, value as Float)
                Long::class.java -> preferences.edit().putLong(key.name, value as Long)
                else -> {
                    val adapter = JSON.moshi.adapter<T>(key.clazz)
                    val jsonString = adapter.toJson(value)
                    preferences.edit().putString(key.name, jsonString)
                }
            }
        }

        if (key.syncNow) {
            editor.commit()
        } else {
            editor.apply()
        }
    }

    @Suppress("UNCHECKED_CAST")
    override fun <T> get(key: StoreKey<T>): T? {
        if (!preferences.contains(key.name)) {
            return null
        }

        return when (key.clazz.javaClass::class.java) {
            String::class.java -> preferences.getString(key.name, null) as? T
            Int::class.java -> preferences.getInt(key.name, 0) as? T
            Boolean::class.java -> preferences.getBoolean(key.name, false) as? T
            Float::class.java -> preferences.getFloat(key.name, 0f) as? T
            Long::class.java -> preferences.getLong(key.name, 0L) as? T
            else -> {
                val jsonString = preferences.getString(key.name, null) ?: return null
                val adapter = JSON.moshi.adapter<T>(key.clazz)
                return adapter.fromJson(jsonString)
            }
        }
    }
}
