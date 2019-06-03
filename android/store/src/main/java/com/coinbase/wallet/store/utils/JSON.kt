package com.coinbase.wallet.store.utils

import com.coinbase.wallet.store.jsonadapters.BigDecimalAdapterAdapter
import com.coinbase.wallet.store.jsonadapters.BigIntegerAdapterAdapter
import com.coinbase.wallet.store.jsonadapters.URLAdapterAdapter
import com.squareup.moshi.JsonAdapter
import com.squareup.moshi.Moshi
import java.math.BigDecimal
import java.math.BigInteger
import java.net.URL

/**
 * JSON parser
 */
object JSON {
    private var entries = mutableMapOf<Class<*>, JsonAdapter<*>>()

    /**
     * Moshi singleton instance
     */
    var moshi: Moshi = buildMoshi()
        private set

    /**
     * Converts given json string to an instance of T
     *
     * @param jsonString JSON string
     *
     * @return An instance of T or null if invalid JSON string
     */
    inline fun <reified T> fromJsonString(jsonString: String): T? {
        val adapter = moshi.adapter<T>(T::class.java)
        return adapter.fromJson(jsonString)
    }

    /**
     * Converts give T instance to json string representation
     *
     * @param instance Instance of T
     *
     * @return A json string based on T instance
     */
    inline fun <reified T> toJsonString(instance: T): String {
        val adapter = moshi.adapter<T>(T::class.java)
        return adapter.toJson(instance)
    }

    /**
     * Add new custom adapter
     *
     * @param clazz Class type to convert to/from JSON
     * @param adapter Adapter used to convert the JSON
     */
    fun <T> add(clazz: Class<T>, adapter: JsonAdapter<T>) {
        entries[clazz] = adapter
        moshi = buildMoshi()
    }

    // Helpers

    private fun buildMoshi(): Moshi {
        val builder = Moshi.Builder()
            .add(URL::class.java, URLAdapterAdapter())
            .add(BigDecimal::class.java, BigDecimalAdapterAdapter())
            .add(BigInteger::class.java, BigIntegerAdapterAdapter())

        entries.forEach { builder.add(it.key, it.value) }

        return builder.build()
    }
}
