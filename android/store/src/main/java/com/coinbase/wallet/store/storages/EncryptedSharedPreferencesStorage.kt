package com.coinbase.wallet.store.storages

import android.content.Context
import android.content.SharedPreferences
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import com.coinbase.wallet.crypto.algorithms.AES256GCM
import com.coinbase.wallet.crypto.extensions.base64EncodedString
import com.coinbase.wallet.crypto.extensions.parseAES256GMPayload
import com.coinbase.wallet.store.interfaces.Storage
import com.coinbase.wallet.store.models.StoreKey
import com.squareup.moshi.Moshi
import java.io.IOException
import java.security.KeyStore
import java.security.KeyStoreException
import java.security.NoSuchAlgorithmException
import java.security.UnrecoverableEntryException
import java.security.cert.CertificateException
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey

internal class EncryptedSharedPreferencesStorage(context: Context) : Storage {
    private val preferences = context.getSharedPreferences("CBStore.encrypted", Context.MODE_PRIVATE)
    private val moshi = Moshi.Builder().build()

    companion object {
        private const val KEYSTORE = "AndroidKeyStore"
        private const val ALIAS = "com.coinbase.wallet.CBStore"
    }

    override fun <T> set(key: StoreKey<T>, value: T?) {
        val editor: SharedPreferences.Editor = if (value == null) {
            preferences.edit().remove(key.name)
        } else {
            val adapter = moshi.adapter<T>(key.clazz)
            val jsonString = adapter.toJson(value)
            val encrypted = encrypt(jsonString)
            preferences.edit().putString(key.name, encrypted)
        }

        if (key.syncNow) {
            editor.commit()
        } else {
            editor.apply()
        }
    }

    override fun <T> get(key: StoreKey<T>): T? {
        val jsonString = preferences.getString(key.name, null) ?: return null
        val decrypted = decrypt(jsonString) ?: return null
        val adapter = moshi.adapter<T>(key.clazz)

        return adapter.fromJson(decrypted)
    }

    private fun encrypt(value: String): String {
        val tuple = AES256GCM.encrypt(data = value.toByteArray(), secretKey = getSecretKey())
        val encrypteData = tuple.first + tuple.second + tuple.third

        return encrypteData.base64EncodedString()
    }

    private fun decrypt(value: String): String? {
        val (iv, authTag, data) = value.parseAES256GMPayload() ?: return null
        val decrypted = AES256GCM.decrypt(data = data, iv = iv, authTag = authTag, secretKey = getSecretKey())

        return decrypted.toString(Charsets.UTF_8)
    }

    @Throws(
        KeyStoreException::class,
        IOException::class,
        NoSuchAlgorithmException::class,
        CertificateException::class,
        UnrecoverableEntryException::class
    )
    private fun getSecretKey(): SecretKey {
        // Attempt to fetch existing stored secret key from Android KeyStore
        val keyStore = KeyStore.getInstance(KEYSTORE)

        keyStore.load(null)

        val entry = keyStore.getEntry(ALIAS, null) as? KeyStore.SecretKeyEntry
        val secretKey = entry?.secretKey

        if (secretKey != null) {
            return secretKey
        }

        // At this point, no secret key is stored so generate a new one.
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            KEYSTORE
        )

        val spec = KeyGenParameterSpec.Builder(
                ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .build()

        keyGenerator.init(spec)

        return keyGenerator.generateKey()
    }
}
