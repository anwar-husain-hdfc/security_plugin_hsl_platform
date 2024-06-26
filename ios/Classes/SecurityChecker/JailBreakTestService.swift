//
//  JailBreakTestService.swift
//  Runner
//
//  Created by Keshav Raj on 10/06/24.
//  Copyright © 2024 The Chromium Authors. All rights reserved.
//

import Foundation

internal struct JailBreakTestService {
    typealias CheckResult = (failed: Bool, msg: String)
    
    ///Tests if the device is jail broken. This method performs all the security checks and should be called from client. Currently we are performing writing to private directory, searching for suspicious file paths, fork and checking if the suspicious apps are installed.
    ///- Returns: True if jailBroken else false
    
    func isJailBroken() -> CheckResult {
        
        //1. Check if we can write to private paths
        let privatePathWriteTestResult = privatePathWriteTestResult()
        if privatePathWriteTestResult.failed {
            return privatePathWriteTestResult
        }
        
        //2. Check if suspicious files are present
        let suspiciousFilesExistenceTestResult = suspiciousFilesExistenceTestResult()
        if suspiciousFilesExistenceTestResult.failed {
            return suspiciousFilesExistenceTestResult
        }
        
        //3. Check if we can fork
        if !SimulatorChecker().amIRunInSimulator() {
            let forkTestResult = forkTestResult()
            if forkTestResult.failed {
                return forkTestResult
            }
        } else {
            debugPrint("App is running in simulator skipping the fork check.")
        }
        
        //4. Check for presence of suspicious apps
        let suspiciousAppPresenceTestResult = suspiciousAppPresenceTestResult()
        if suspiciousAppPresenceTestResult.failed {
            return suspiciousAppPresenceTestResult
        }
        
        return (false, "All the jail break tests passed")
    }
    
    /// Tests if we can write to private paths
    /// - Returns: True if we can write else false
    private func privatePathWriteTestResult() -> CheckResult {
        let paths = [
            "/",
            "/root/",
            "/private/",
            "/jb/"
        ]
        
        // If library won't be able to write to any restricted directory the return(true, ...) is never reached
        // because of catch{} statement
        for path in paths {
            do {
                let pathWithSomeRandom = path + UUID().uuidString
                try "AmIJailbroken?".write(
                    toFile: pathWithSomeRandom,
                    atomically: true,
                    encoding: String.Encoding.utf8
                )
                // clean if succesfully written
                try FileManager.default.removeItem(atPath: pathWithSomeRandom)
                return (true, "Private path Write test result failed. Wrote to restricted path: \(path)")
            } catch {}
        }
        return (false, "")
    }
    
    /// Tests if suspicious file paths are present
    /// - Returns: True if present else false
    private func suspiciousFilesExistenceTestResult() -> CheckResult {
        var paths = [
            "/var/mobile/Library/Preferences/ABPattern", // A-Bypass
            "/usr/lib/ABDYLD.dylib", // A-Bypass,
            "/usr/lib/ABSubLoader.dylib", // A-Bypass
            "/usr/sbin/frida-server", // frida
            "/etc/apt/sources.list.d/electra.list", // electra
            "/etc/apt/sources.list.d/sileo.sources", // electra
            "/.bootstrapped_electra", // electra
            "/usr/lib/libjailbreak.dylib", // electra
            "/jb/lzma", // electra
            "/.cydia_no_stash", // unc0ver
            "/.installed_unc0ver", // unc0ver
            "/jb/offsets.plist", // unc0ver
            "/usr/share/jailbreak/injectme.plist", // unc0ver
            "/etc/apt/undecimus/undecimus.list", // unc0ver
            "/var/lib/dpkg/info/mobilesubstrate.md5sums", // unc0ver
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/jb/jailbreakd.plist", // unc0ver
            "/jb/amfid_payload.dylib", // unc0ver
            "/jb/libjailbreak.dylib", // unc0ver
            "/usr/libexec/cydia/firmware.sh",
            "/var/lib/cydia",
            "/etc/apt",
            "/private/var/lib/apt",
            "/private/var/Users/",
            "/var/log/apt",
            "/Applications/Cydia.app",
            "/private/var/stash",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/cache/apt/",
            "/private/var/log/syslog",
            "/private/var/tmp/cydia.log",
            "/Applications/Icy.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/blackra1n.app",
            "/Applications/SBSettings.app",
            "/Applications/FakeCarrier.app",
            "/Applications/WinterBoard.app",
            "/Applications/IntelliScreen.app",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/Library/MobileSubstrate/CydiaSubstrate.dylib",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/Applications/Sileo.app",
            "/var/binpack",
            "/Library/PreferenceBundles/LibertyPref.bundle",
            "/Library/PreferenceBundles/ShadowPreferences.bundle",
            "/Library/PreferenceBundles/ABypassPrefs.bundle",
            "/Library/PreferenceBundles/FlyJBPrefs.bundle",
            "/Library/PreferenceBundles/Cephei.bundle",
            "/Library/PreferenceBundles/SubstitutePrefs.bundle",
            "/Library/PreferenceBundles/libhbangprefs.bundle",
            "/usr/lib/libhooker.dylib",
            "/usr/lib/libsubstitute.dylib",
            "/usr/lib/substrate",
            "/usr/lib/TweakInject",
            "/var/binpack/Applications/loader.app", // checkra1n
            "/Applications/FlyJB.app", // Fly JB X
            "/Applications/Zebra.app", // Zebra
            "/Library/BawAppie/ABypass", // ABypass
            "/Library/MobileSubstrate/DynamicLibraries/SSLKillSwitch2.plist", // SSL Killswitch
            "/Library/MobileSubstrate/DynamicLibraries/PreferenceLoader.plist", // PreferenceLoader
            "/Library/MobileSubstrate/DynamicLibraries/PreferenceLoader.dylib", // PreferenceLoader
            "/Library/MobileSubstrate/DynamicLibraries", // DynamicLibraries directory in general
            "/var/mobile/Library/Preferences/me.jjolano.shadow.plist"
        ]
        
        // These files can give false positive in the emulator
        if !SimulatorChecker().amIRunInSimulator() {
            paths += [
                "/bin/bash",
                "/usr/sbin/sshd",
                "/usr/libexec/ssh-keysign",
                "/bin/sh",
                "/etc/ssh/sshd_config",
                "/usr/libexec/sftp-server",
                "/usr/bin/ssh"
            ]
        }
        let fileManager = FileManager.default
        for aPath in paths {
            //If any of the file is present then return true. Returning will break the loop as well.
            if fileManager.fileExists(atPath: aPath) {
                return (true, "Suspicious File exist test failed. Suspicious file present at path:- \(aPath)")
            }
        }
        //If for loop terminates return false
        return (false, "")
    }
    
    /// Tests if we are able to fork process.
    /// - Returns: True if we were able to fork else returns false
    private func forkTestResult() -> CheckResult {
        let pointerToFork = UnsafeMutableRawPointer(bitPattern: -2)
        let forkPtr = dlsym(pointerToFork, "fork")
        typealias ForkType = @convention(c) () -> pid_t
        let fork = unsafeBitCast(forkPtr, to: ForkType.self)
        let forkResult = fork()
        
        if forkResult >= 0 {
            if forkResult > 0 {
                kill(forkResult, SIGTERM)
            }
            return (true, "Fork Test failed. Fork was able to create a new process (sandbox violation)")
        }
        
        return (false, "")
    }
    
    /// Tests if any of the suspicious apps are present. Already these url schemes have been defined in info.plist. While modifying here make sure that it is added to info.plist as well.
    /// - Returns: True if suspicious apps are present else false
    private func suspiciousAppPresenceTestResult() -> CheckResult {
        let urlSchemes = [
            "undecimus://",
            "sileo://",
            "zbra://",
            "filza://",
            "cydia://"
        ]
        for aScheme in urlSchemes {
            if let url = URL(string: aScheme) {
                if UIApplication.shared.canOpenURL(url) {
                    //Suspicious app is present. Returning true.
                    return (true, "Suspicious app presence Test failed. Suspicious app present with url scheme:- \(url)")
                }
            }
        }
        return (false, "")
    }
}
