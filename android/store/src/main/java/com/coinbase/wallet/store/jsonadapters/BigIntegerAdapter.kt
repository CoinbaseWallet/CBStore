package com.coinbase.wallet.store.jsonadapters

import com.squareup.moshi.FromJson
import com.squareup.moshi.JsonAdapter
import com.squareup.moshi.JsonReader
import com.squareup.moshi.JsonWriter
import com.squareup.moshi.ToJson
import java.io.IOException
import java.math.BigInteger

class BigIntegerAdapterAdapter : JsonAdapter<BigInteger>() {
    @FromJson
    @Throws(IOException::class)
    override fun fromJson(reader: JsonReader): BigInteger? {
        if (reader.peek() == JsonReader.Token.NULL) return reader.nextNull()
        return BigInteger(reader.nextString())
    }

    @ToJson
    override fun toJson(writer: JsonWriter, value: BigInteger?) {
        if (value == null) writer.value(null as String?)
        else writer.value(value.toString())
    }
}

