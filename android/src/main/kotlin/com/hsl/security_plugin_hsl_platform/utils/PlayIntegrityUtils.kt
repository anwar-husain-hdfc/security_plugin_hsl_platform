package com.hsl.security_plugin_hsl_platform.utils

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyInfo
import android.security.keystore.KeyProperties
import android.util.Log
import androidx.annotation.RequiresApi
import java.math.BigInteger
import java.security.KeyFactory
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.spec.RSAKeyGenParameterSpec
import java.util.Date
import javax.security.auth.x500.X500Principal

// Constants
private const val TEST_KEY_ALIAS = "testKeyAlias"
private const val KEY_SIZE = 2048
private const val CERTIFICATE_SUBJECT = "CN=test"
private const val ONE_YEAR_MILLIS = 1000L * 60 * 60 * 24 * 365
const val LOG_TAG_PLAY_INTEGRITY = "PLAY_INTEGRITY"
// Constants for integrity check keys
const val MEETS_STRONG_INTEGRITY_KEY = "MEETS_STRONG_INTEGRITY"

@RequiresApi(Build.VERSION_CODES.S)
fun supportsHardwareBackedAttestation(): Boolean {
    return try {
        // Generate a key pair in the Android Keystore
        val keyPairGenerator = KeyPairGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_RSA, "AndroidKeyStore"
        )
        keyPairGenerator.initialize(
            KeyGenParameterSpec.Builder(
                TEST_KEY_ALIAS,
                KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
            )
                .setAlgorithmParameterSpec(
                    RSAKeyGenParameterSpec(
                        KEY_SIZE,
                        RSAKeyGenParameterSpec.F4
                    )
                )
                .setCertificateSubject(X500Principal(CERTIFICATE_SUBJECT))
                .setCertificateSerialNumber(BigInteger.ONE)
                .setCertificateNotBefore(Date(System.currentTimeMillis() - ONE_YEAR_MILLIS))
                .setCertificateNotAfter(Date(System.currentTimeMillis() + ONE_YEAR_MILLIS))
                .setDigests(KeyProperties.DIGEST_SHA256)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_RSA_OAEP)
                .setSignaturePaddings(KeyProperties.SIGNATURE_PADDING_RSA_PKCS1)
                .build()
        )
        val keyPair = keyPairGenerator.generateKeyPair()

        // Retrieve the private key from the keystore
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)
        val privateKey = keyStore.getKey(TEST_KEY_ALIAS, null) as java.security.PrivateKey

        // Get KeyInfo
        val keyFactory = KeyFactory.getInstance(privateKey.algorithm, "AndroidKeyStore")
        val keyInfo = keyFactory.getKeySpec(privateKey, KeyInfo::class.java)

        // Delete the test key
        keyStore.deleteEntry(TEST_KEY_ALIAS)

        // Check the security level
        val isHardwareBackedAttestationSupport =
            keyInfo.securityLevel == KeyProperties.SECURITY_LEVEL_TRUSTED_ENVIRONMENT || keyInfo.securityLevel == KeyProperties.SECURITY_LEVEL_STRONGBOX
        Log.d(
            LOG_TAG_PLAY_INTEGRITY,
            "isHardwareBackedAttestationSupport: $isHardwareBackedAttestationSupport"
        )
        isHardwareBackedAttestationSupport
    } catch (e: Exception) {
        Log.d(LOG_TAG_PLAY_INTEGRITY, "Exception during hardware-backed attestation check", e)
        false
    }
}