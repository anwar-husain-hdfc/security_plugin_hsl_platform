package com.hsl.security_plugin_hsl_platform.utils.appverifier

import android.annotation.SuppressLint
import android.content.Context
import android.util.Base64
import com.hsl.security_plugin_hsl_platform.BuildConfig
import com.hsl.security_plugin_hsl_platform.utils.AppConstants
import com.hsl.security_plugin_hsl_platform.utils.appverifier.IntegrityAPIProvider.Constant.UTF_8
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import com.google.gson.Gson
import io.reactivex.Observable
import io.reactivex.ObservableEmitter
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import org.jose4j.jwe.JsonWebEncryption
import org.jose4j.jws.JsonWebSignature
import org.jose4j.jwx.JsonWebStructure
import java.security.KeyFactory
import java.security.spec.X509EncodedKeySpec
import javax.crypto.spec.SecretKeySpec

interface OnIntegrityProviderCallback {
    fun onSuccess(verdict: ArrayList<String>)
    fun onError(throwable: Throwable)
}

class IntegrityAPIProvider(private val context: Context) {

    private val integrityStates = IntegrityStates()
    private lateinit var mDisposable: Disposable

    companion object {
        private lateinit var mIntegrityAPIProvider: IntegrityAPIProvider
        fun getInstance(context: Context): IntegrityAPIProvider {
            if (Companion::mIntegrityAPIProvider.isInitialized.not()) {
                mIntegrityAPIProvider = IntegrityAPIProvider(context = context)
            }
            return mIntegrityAPIProvider
        }
    }

    object Constant {
        const val OFFSET = 0
        const val LENGTH = 32
        const val ALGORITHM = "AES"
        const val KEY_FACTORY_ALGORITHM = "EC"
        const val UTF_8 = "UTF-8"
        const val ALPHABET_A = 'A'
        const val ALPHABET_Z = 'Z'
        const val ALPHABET_a = 'a'
        const val ALPHABET_z = 'z'
        const val CHARACTER_0 = '0'
        const val CHARACTER_9 = '9'
    }

    @SuppressLint("CheckResult")
    fun initiateIntegrityDetection(callback: OnIntegrityProviderCallback) {

        if (integrityStates.isInProgress) {
            return
        }

        mDisposable = getNonceFromServer().doOnSubscribe {
            integrityStates.isInProgress = true
        }.flatMap { nonce ->
            return@flatMap initiateIntegrityAPI(nonce = nonce)
        }.flatMap { token ->
            return@flatMap if (integrityStates.shouldDecryptOnLocal) decryptIntegrityTokenLocally(token = token) else decryptIntegrityTokenRemotely(token = token)
        }.subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    getResultFromPayload(it, callback)
                    if (::mDisposable.isInitialized) {
                        mDisposable.dispose()
                    }
                }, { error ->
                    integrityStates.resetVariables()
                    callback.onError(error)
                    if (::mDisposable.isInitialized) {
                        mDisposable.dispose()
                    }
                })
    }

    @Suppress("MagicNumber")
    private fun generateNonce(): String {
        val charset = (Constant.ALPHABET_a..Constant.ALPHABET_z) + (Constant.ALPHABET_A..Constant.ALPHABET_Z) +
                (Constant.CHARACTER_0..Constant.CHARACTER_9)
        var nonce = AppConstants.EMPTY_STRING
        for (i in 0..30) {
            nonce += charset.random()
        }
        integrityStates.mNonce = Base64.encodeToString(nonce.toByteArray(charset(UTF_8)), Base64.DEFAULT)
        return (integrityStates.mNonce)
    }

    private fun initiateIntegrityAPI(nonce: String): Observable<String> {

        val observable = Observable.create { emitter: ObservableEmitter<String> ->
            if (integrityStates.isFetchTokenFromNonceSuccessful) {
                emitter.onNext(integrityStates.mToken)
            } else {
                IntegrityManagerFactory.create(context.applicationContext)
                        .requestIntegrityToken(IntegrityTokenRequest.builder().setNonce(nonce).build())
                        .addOnSuccessListener { integrityToken ->
                            kotlin.runCatching {
                                val token = integrityToken.token()
                                integrityStates.isFetchTokenFromNonceSuccessful = true
                                integrityStates.mToken = token
                                return@runCatching emitter.onNext(token)
                            }.getOrElse { exception ->
                                emitter.onError(exception)
                            }
                        }.addOnFailureListener { exception ->
                            emitter.onError(exception)
                        }
            }
        }
        return observable
    }

    private fun getResultFromPayload(decryptedPayload: String, callback: OnIntegrityProviderCallback) {
        kotlin.runCatching {
            val gson = Gson()
            val mPayload = gson.fromJson(decryptedPayload, IntegrityPayload::class.java)

            val requestPackageName = mPayload.requestDetails?.requestPackageName
            val nonce = mPayload.requestDetails?.nonce
            val deviceRecognitionVerdict = mPayload.deviceIntegrity?.deviceRecognitionVerdict
                    ?: arrayListOf()

            if (requestPackageName.equals(context.packageName) &&
                    integrityStates.mNonce.contains(nonce ?: AppConstants.EMPTY_STRING)) {
                callback.onSuccess(deviceRecognitionVerdict)
            } else {
                callback.onError(Throwable("Integrity token is invalid"))
            }
            integrityStates.resetVariables()
        }.onFailure {
            callback.onError(it)
        }
    }

    private fun decryptIntegrityTokenLocally(token: String): Observable<String> {
        return kotlin.runCatching {
            var decryptionKeyBytes = Base64.decode(BuildConfig.INTEGRITY_DECRYPTION_KEY, Base64.DEFAULT)
            if (context.packageName == "com.hsl.investright") {
                decryptionKeyBytes = Base64.decode(BuildConfig.INTEGRITY_DECRYPTION_KEY_IR, Base64.DEFAULT)
            } else {
                decryptionKeyBytes = Base64.decode(BuildConfig.INTEGRITY_DECRYPTION_KEY, Base64.DEFAULT)
            }

            // Deserialized encryption (symmetric) key.
            val decryptionKey = SecretKeySpec(
                    decryptionKeyBytes,
                Constant.OFFSET,
                Constant.LENGTH,
                Constant.ALGORITHM
            )

            // Base64OfEncodedVerificationKey is provided through Play Console or over email.
            var encodedVerificationKey = Base64.decode(BuildConfig.INTEGRITY_VERIFICATION_KEY, Base64.DEFAULT)
            if (context.packageName == "com.hsl.investright") {
                encodedVerificationKey = Base64.decode(BuildConfig.INTEGRITY_VERIFICATION_KEY_IR, Base64.DEFAULT)
            } else {
                Base64.decode(BuildConfig.INTEGRITY_VERIFICATION_KEY, Base64.DEFAULT)
            }


            val verificationKey = KeyFactory.getInstance(Constant.KEY_FACTORY_ALGORITHM).generatePublic(X509EncodedKeySpec(encodedVerificationKey))

            /**
             * The JWE needs 2 levels of Decryption before getting plain text payload.
             * So first for JWE to JWS. then from JWS to JWT after verifying signature. below code will do that.
             */
            val jsonWebEncryption = JsonWebStructure.fromCompactSerialization(token) as JsonWebEncryption
            jsonWebEncryption.key = decryptionKey
            val compactJws = jsonWebEncryption.payload
            val jsonWebSignature = JsonWebStructure.fromCompactSerialization(compactJws) as JsonWebSignature
            jsonWebSignature.key = verificationKey
            val payload = jsonWebSignature.payload
            return@runCatching Observable.just(payload)
        }.getOrElse {
            Observable.error(it)
        }
    }

    private fun decryptIntegrityTokenRemotely(token: String): Observable<String> {
        return Observable.just(token)
    }

    @SuppressLint("CheckResult")
    private fun getNonceFromServer(): Observable<String> {
        if (integrityStates.isFetchNonceSuccessful) {
            return Observable.just(integrityStates.mNonce)
        }
        kotlin.runCatching {
            integrityStates.isFetchNonceSuccessful = true
            return Observable.just(generateNonce())
        }.onFailure {
            return Observable.error(it)
        }
        return Observable.just(AppConstants.EMPTY_STRING)
    }
}