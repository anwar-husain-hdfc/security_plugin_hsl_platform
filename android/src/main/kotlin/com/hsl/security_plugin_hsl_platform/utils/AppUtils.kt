package com.hsl.security_plugin_hsl_platform.utils

import android.util.Base64
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

object AppUtils {
    private const val DECRYPTION_DIVIDER = ','
    private const val DECRYPTION_ALGORITHM = "AES"
    private const val DECRYPTION_TRANSFORMATION = "AES/CBC/PKCS5Padding"

    private fun hexStringToByteArray(hexString: String): ByteArray {
        val result = ByteArray(hexString.length / 2)
        for (i in hexString.indices step 2) {
            val hexDigit = hexString.substring(i, i + 2)
            result[i / 2] = hexDigit.toInt(16).toByte()
        }
        return result
    }

    fun decryptOpenSSLEncryptedData(data: String): String {
        val split = data.split(DECRYPTION_DIVIDER)
        if (split.size < 3) return AppConstants.EMPTY_STRING
        val cipher = Cipher.getInstance(DECRYPTION_TRANSFORMATION)
        val key = hexStringToByteArray(split[1])
        val iv = hexStringToByteArray(split[2])
        cipher.init(Cipher.DECRYPT_MODE, SecretKeySpec(key, DECRYPTION_ALGORITHM), IvParameterSpec(iv))
        val original = cipher.doFinal(Base64.decode(split[0], Base64.DEFAULT))
        return String(original)
    }
}
