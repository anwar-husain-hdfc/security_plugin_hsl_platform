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
        
        // Perform advanced jailbreak checks
        if let advancedChecksResult = performAdvancedJailbreakChecks() {
            return advancedChecksResult
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
    
    // List of suspicious dynamic libraries (dylibs) typically associated with jailbreak or unauthorized modifications.
    private let suspiciousDylibs = [
        "/usr/lib/libshadow.dylib",
        "/usr/lib/Shadow.dylib",
        "/Library/MobileSubstrate/DynamicLibraries/Shadow.dylib",
        "/Library/MobileSubstrate/DynamicLibraries/libshadow.dylib"
    ]

    // List of file paths related to the Shadow framework, which is often used in unauthorized or jailbroken environments.
    private let shadowPaths = [
        "/Library/PreferenceBundles/ShadowPreferences.bundle",
        "/var/mobile/Library/Preferences/me.jjolano.shadow.plist",
        "/Library/MobileSubstrate/DynamicLibraries/Shadow.dylib"
    ]

    // List of environment variables that are often manipulated in unauthorized or compromised environments.
    private let suspiciousEnvVars = [
        "DYLD_INSERT_LIBRARIES",
        "DYLD_FORCE_FLAT_NAMESPACE"
    ]

    // List of hooking libraries that might be used to alter the behavior of system or application code.
    private let hookingLibraries = [
        "libhooker.dylib",
        "SubstrateBootstrap.dylib",
        "Substitute.dylib",
        "TSInject.dylib"
    ]

    // Utility function to check for the existence of files at specified paths.
    // Returns a CheckResult indicating success or failure, along with a message.
    private func checkFilesExistence(atPaths paths: [String], failureMessage: String) -> CheckResult {
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return (true, "\(failureMessage) found at path: \(path)")
            }
        }
        return (false, "")
    }

    // Check for the presence of suspicious dylibs related to unauthorized modifications or jailbreaks.
    private func shadowDylibCheck() -> CheckResult {
        return checkFilesExistence(atPaths: suspiciousDylibs, failureMessage: "Shadow Dylib Check failed. Suspicious dylib")
    }

    // Check for the presence of files associated with the Shadow framework, which may indicate a compromised environment.
    private func shadowFilesCheck() -> CheckResult {
        return checkFilesExistence(atPaths: shadowPaths, failureMessage: "Shadow Files Check failed. Shadow-related file")
    }

    // Check if the description method of NSObject has been swizzled, which could indicate tampering or unauthorized modifications.
    private func methodSwizzlingCheck() -> CheckResult {
        guard
            let originalMethod = class_getInstanceMethod(NSObject.self, #selector(NSObject.description)),
            let swizzledMethod = class_getInstanceMethod(NSObject.self, Selector(("shadow_description"))),
            method_getImplementation(originalMethod) != method_getImplementation(swizzledMethod)
        else {
            return (false, "")
        }
        return (true, "Method Swizzling Check failed. Description method has been swizzled.")
    }

    // Check if a debugger is attached to the current process, which may indicate unauthorized monitoring or debugging.
    private func debuggerCheck() -> CheckResult {
        var info = kinfo_proc()
        var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let sysctlResult = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        
        if sysctlResult == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
            return (true, "Debugger Check failed. A debugger is attached to the process.")
        }
        return (false, "")
    }

    // Check for the presence of suspicious environment variables that may be manipulated in compromised environments.
    private func environmentVariablesCheck() -> CheckResult {
        for varName in suspiciousEnvVars {
            if let value = getenv(varName), !String(cString: value).isEmpty {
                return (true, "Environment Variables Check failed. Suspicious environment variable found: \(varName)")
            }
        }
        return (false, "")
    }

    // Test the sandbox integrity by attempting to write to a protected directory.
    // If writing is successful, it indicates a breach of the sandbox.
    private func sandboxIntegrityCheck() -> CheckResult {
        let testFilePath = "/private/var/mobile/Library/SandboxTest.txt"
        
        do {
            try "Sandbox Test".write(toFile: testFilePath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testFilePath)
            return (true, "Sandbox Integrity Check failed. Writing to a protected directory was successful.")
        } catch {
            return (false, "")
        }
    }

    // Check the integrity of system frameworks by attempting to load a critical framework (UIKit) and verify its contents.
    // Returns a CheckResult indicating if the framework has been tampered with or is missing essential components.
    private func systemFrameworkIntegrityCheck() -> CheckResult {
        guard let handle = dlopen("/System/Library/Frameworks/UIKit.framework/UIKit", RTLD_NOW) else {
            return (true, "System Framework Integrity Check failed. Unable to load UIKit framework.")
        }
        
        defer {
            dlclose(handle)
        }
        
        let expectedSymbol = dlsym(handle, "UIApplicationMain")
        if expectedSymbol == nil {
            return (true, "System Framework Integrity Check failed. UIApplicationMain symbol is missing or tampered.")
        }
        
        return (false, "")
    }

    // Check for the presence of known hooking libraries that may alter the behavior of the application or system.
    // Returns a CheckResult indicating if any hooking libraries were detected.
    private func hookingLibrariesCheck() -> CheckResult {
        for library in hookingLibraries {
            if let handle = dlopen(library, RTLD_NOW) {
                dlclose(handle)
                return (true, "Hooking Libraries Check failed. Detected hooking library: \(library)")
            }
        }
        return (false, "")
    }

    // Perform multiple checks using the fork system call to detect if the process has been tampered with.
    // Returns a CheckResult indicating if any of the checks failed.
    private func multipleForkChecks() -> CheckResult {
        for _ in 0..<5 {
            let result = forkTestResult()
            if result.failed {
                return result
            }
        }
        return (false, "")
    }
    
    private func libertyCheck() -> CheckResult {
        let libertyPaths = [
            "/usr/lib/liberty.dylib",
            "/Library/MobileSubstrate/DynamicLibraries/Liberty.dylib",
            "/Library/MobileSubstrate/DynamicLibraries/LibertyLite.dylib"
        ]
        
        for path in libertyPaths {
            if FileManager.default.fileExists(atPath: path) {
                return (true, "Liberty Check failed. Detected Liberty files at path: \(path)")
            }
        }
        return (false, "")
    }

    private func objectionCheck() -> CheckResult {
        // Checking for the presence of Frida gadgets
        let objectionFiles = [
            "/usr/lib/frida-gadget.dylib",
            "/Library/MobileSubstrate/DynamicLibraries/frida.dylib"
        ]
        
        for path in objectionFiles {
            if FileManager.default.fileExists(atPath: path) {
                return (true, "Objection Check failed. Detected Frida gadget or objection-related files at path: \(path)")
            }
        }
        return (false, "")
    }
    
    private func fridaCheck() -> CheckResult {
        // Check for common Frida-related libraries that may be injected into the app
        let fridaLibraries = [
            "FridaGadget", // Frida Gadget is a common injection point
            "frida-agent"  // Another common Frida component
        ]
        
        for library in fridaLibraries {
            if let handle = dlopen(library, RTLD_NOW) {
                dlclose(handle)
                return (true, "Frida Check failed. Detected loaded Frida library: \(library)")
            }
        }
        
        // Check for Frida symbols in the app’s memory
        let fridaSymbols = [
            "frida_version",  // Frida version symbol
            "gum_interceptor_begin_transaction" // A function used by Frida’s GumJS to intercept method calls
        ]
        
        for symbol in fridaSymbols {
            if dlsym(UnsafeMutableRawPointer(bitPattern: -2), symbol) != nil {
                return (true, "Frida Check failed. Detected Frida symbol in memory: \(symbol)")
            }
        }
        
        return (false, "")
    }
    
    private func shadowConfigCheck() -> CheckResult {
        let shadowConfigPaths = [
            "/var/mobile/Library/Preferences/me.jjolano.shadow.plist",
            "/Library/PreferenceLoader/Preferences/Shadow.plist"
        ]
        
        for path in shadowConfigPaths {
            if FileManager.default.fileExists(atPath: path) {
                return (true, "Shadow Configuration Check failed. Detected Shadow configuration file at path: \(path)")
            }
        }
        return (false, "")
    }
    
    private func shadowHooksCheck() -> CheckResult {
        // Check if known methods that Shadow might hook into have been tampered with.
        // This example checks if a common method has been replaced or altered.

        let originalMethod = class_getInstanceMethod(NSObject.self, #selector(NSObject.description))
        let shadowedMethod = class_getInstanceMethod(NSObject.self, Selector(("shadow_description")))
        
        if let originalMethod = originalMethod, let shadowedMethod = shadowedMethod {
            if method_getImplementation(originalMethod) != method_getImplementation(shadowedMethod) {
                return (true, "Shadow Hooks Check failed. NSObject description method has been swizzled by Shadow.")
            }
        }
        
        return (false, "")
    }

    // Execute a series of advanced jailbreak checks, including system integrity, debugger detection, environment variable checks, and more.
    // Returns the first CheckResult that fails, or nil if all checks pass.
    private func performAdvancedJailbreakChecks() -> CheckResult? {
        let checks: [() -> CheckResult] = [
            debuggerCheck,
            environmentVariablesCheck,
            sandboxIntegrityCheck,
            systemFrameworkIntegrityCheck,
            hookingLibrariesCheck,
            multipleForkChecks,
            shadowDylibCheck,
            shadowFilesCheck,
            shadowConfigCheck,
            shadowHooksCheck,
            methodSwizzlingCheck,
            libertyCheck, // Liberty detection
            objectionCheck, // Objection detection
            fridaCheck // Optimized Frida detection
        ]
        
        for check in checks {
            let result = check()
            if result.failed {
                return result
            }
        }
        return nil
    }
    
}
