package com.hsl.security_plugin_hsl_platform.utils.appverifier

import com.hsl.security_plugin_hsl_platform.utils.AppConstants
import com.google.gson.annotations.SerializedName
import java.util.ArrayList

data class IntegrityPayload(
        @SerializedName("requestDetails")
        var requestDetails: RequestDetails? = RequestDetails(),
        @SerializedName("appIntegrity")
        var appIntegrity: AppIntegrity? = AppIntegrity(),
        @SerializedName("deviceIntegrity")
        var deviceIntegrity: DeviceIntegrity? = DeviceIntegrity(),
        @SerializedName("accountDetails")
        var accountDetails: AccountDetails? = AccountDetails()
)

data class RequestDetails(
        @SerializedName("requestPackageName")
        var requestPackageName: String? = null,
        @SerializedName("timestampMillis")
        var timestampMillis: Long? = null,
        @SerializedName("nonce")
        var nonce: String? = null
)

data class AppIntegrity(
        @SerializedName("appRecognitionVerdict")
        var appRecognitionVerdict: String? = null,
        @SerializedName("packageName")
        var packageName: String? = null,
        @SerializedName("certificateSha256Digest")
        var certificateSha256Digest: ArrayList<String> = arrayListOf(),
        @SerializedName("versionCode")
        var versionCode: String? = null
)

data class DeviceIntegrity(
        @SerializedName("deviceRecognitionVerdict")
        var deviceRecognitionVerdict: ArrayList<String> = arrayListOf()
)

data class AccountDetails(
        @SerializedName("appLicensingVerdict")
        var appLicensingVerdict: String? = null
)

data class IntegrityStates(
        var mNonce: String = AppConstants.EMPTY_STRING,
        var mToken: String = AppConstants.EMPTY_STRING,
        var isRooted: Boolean = false,
        var isInProgress: Boolean = false,
        var shouldDecryptOnLocal: Boolean = true,
        var isFetchNonceSuccessful: Boolean = false,
        var isFetchTokenFromNonceSuccessful: Boolean = false
) {
    fun resetVariables() {
        mNonce = AppConstants.EMPTY_STRING
        mToken = AppConstants.EMPTY_STRING
        isInProgress = false // to verify if the api call is in porgress
        isRooted = false
        isFetchTokenFromNonceSuccessful = false // to verify if token has been successfully fetched from nonce
        isFetchNonceSuccessful = false // to verify if nonce has been successfully fetched
    }
}