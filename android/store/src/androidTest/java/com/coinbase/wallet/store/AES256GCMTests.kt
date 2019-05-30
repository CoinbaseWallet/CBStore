package com.coinbase.wallet.store

import android.support.test.runner.AndroidJUnit4
import android.util.Base64
import com.coinbase.wallet.crypto.algorithms.AES256GCM
import com.coinbase.wallet.crypto.extensions.base64EncodedString
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class AES256GCMTests {
    @Test
    fun encryptionDecryption() {
        val data = "Needs encryption".toByteArray()
        val key = "c9db0147e942b2675045e3f61b247692".toByteArray()
        val iv = "123456789012".toByteArray()
        val (encryptedData, authTag) = AES256GCM.encrypt(data, key, iv)

        println(Base64.encodeToString(encryptedData, Base64.NO_WRAP))
        val decryptedData = AES256GCM.decrypt(encryptedData, key, iv, authTag)

        Assert.assertEquals(data.base64EncodedString(), decryptedData.base64EncodedString())
    }
}