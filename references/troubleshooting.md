# Troubleshooting Guide

Common issues and solutions when migrating from CocoaPods to SwiftPM.

## Gradle Issues

### "swiftPMDependencies not found"

**Symptom:** Unresolved reference to `swiftPMDependencies` in build.gradle.kts

**Solution:** Add buildscript constraint to root build.gradle.kts:

```kotlin
buildscript {
    dependencies.constraints {
        "classpath"("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.21-titan-211!!")
    }
}
```

Also verify:
- Kotlin version is `2.2.21-titan-211` in libs.versions.toml
- JetBrains Maven repo is in settings.gradle.kts

---

### Import Not Found After Migration

**Symptom:** `Unresolved reference` errors for classes that worked with CocoaPods

**Solution:** The import namespace follows a specific pattern:

```
swiftPMImport.<group>.<module>.<ClassName>
```

**Steps to fix:**
1. Check `group` property in build.gradle.kts
2. Replace `-` with `.` in both group and module names
3. Run `./gradlew build` to see available classes in error messages

**Example:**
```kotlin
// If group = "org.jetbrains.kotlin.firebase-sample" and module = "kotlin-library"
// Import becomes:
import swiftPMImport.org.jetbrains.kotlin.firebase.sample.kotlin.library.FIRAnalytics
//                    ^                          ^      ^
//                    dashes become dots --------+------+
```

---

### Gradle Sync Fails

**Symptom:** IDE fails to sync project after adding swiftPMDependencies

**Solution:**
1. Invalidate caches: File > Invalidate Caches > Invalidate and Restart
2. Run `./gradlew --refresh-dependencies`
3. Check all repository declarations include JetBrains Maven

---

## Linker Issues

### Missing Symbols / Linker Errors

**Symptom:** `Undefined symbols for architecture` errors

**Solutions:**

1. **Ensure static framework:**
   ```kotlin
   binaries.framework {
       isStatic = true  // Must be true for SwiftPM
   }
   ```

2. **Run integration task:**
   ```bash
   ./gradlew :moduleName:integrateLinkagePackage
   ```

3. **Verify SPM package is linked in Xcode:**
   - Open project in Xcode
   - Check Package Dependencies section
   - Ensure `_internal_linkage_SwiftPMImport` is present

---

### "No such module" in Xcode

**Symptom:** Xcode can't find the Kotlin module

**Solution:**
1. Clean Xcode build folder: Shift+Cmd+K
2. Re-run integration:
   ```bash
   ./gradlew :moduleName:integrateLinkagePackage
   ```
3. Restart Xcode completely
4. Re-open the `.xcodeproj` file (not .xcworkspace)

---

## Build Phase Issues

### Build Phase Order Problems

**Symptom:** Swift compilation fails because Kotlin framework isn't ready

**Solution:** Ensure "Compile Kotlin" runs BEFORE "Compile Sources":

1. Open Xcode project
2. Select app target > Build Phases
3. Drag "Compile Kotlin" phase above "Compile Sources"

---

### Script Sandboxing Errors

**Symptom:** Build script can't access files or run Gradle

**Solution:** Disable script sandboxing:

1. Select target > Build Settings
2. Search for "sandbox"
3. Set `ENABLE_USER_SCRIPT_SANDBOXING = NO`

---

## Firebase-Specific Issues

### FirebaseFirestore Import Errors

**Symptom:** Can't import FIRFirestore classes

**Cause:** Firestore's Clang module name differs from product name

**Solution:** Add explicit importedModules:

```kotlin
`package`(
    url = url("https://github.com/firebase/firebase-ios-sdk.git"),
    version = from("12.6.0"),
    products = listOf(product("FirebaseFirestore")),
    importedModules = listOf("FirebaseFirestoreInternal"),  // Required
)
```

---

### Firebase Initialization Fails at Runtime

**Symptom:** App crashes on Firebase initialization

**Solution:**
1. Ensure `GoogleService-Info.plist` is in iOS app target
2. Call `FIRApp.configure()` before using any Firebase service
3. Check Firebase console for configuration issues

---

## Google Maps Issues

### GoogleMaps Version Not Found

**Symptom:** SPM can't resolve GoogleMaps package

**Solution:** GoogleMaps requires exact version matching:

```kotlin
`package`(
    url = url("https://github.com/googlemaps/ios-maps-sdk.git"),
    version = exact("10.6.0"),  // Must use exact(), not from()
    products = listOf(
        product("GoogleMaps", platforms = setOf(iOS()))
    ),
)
```

Check [releases page](https://github.com/googlemaps/ios-maps-sdk/releases) for valid versions.

---

## Rollback Instructions

If migration fails and you need to revert:

### Step 1: Restore Git Files

```bash
# Restore CocoaPods files (adjust path if iOS project is not in iosApp/)
git checkout -- "**/Podfile" "**/Podfile.lock"
git checkout -- *.podspec
git checkout -- **/build.gradle.kts
git checkout -- **/src/**/*.kt
```

### Step 2: Restore CocoaPods in build.gradle.kts

```kotlin
plugins {
    kotlin("native.cocoapods")  // Re-add
}

kotlin {
    cocoapods {
        // Restore original configuration
    }
    // Remove swiftPMDependencies block
}
```

### Step 3: Restore Kotlin Imports

Change all imports back:
```kotlin
// FROM:
import swiftPMImport.group.module.ClassName

// TO:
import cocoapods.PodName.ClassName
```

### Step 4: Reinstall CocoaPods

```bash
# Navigate to directory containing Podfile (adjust path as needed)
cd <ios-project-directory>  # e.g., iosApp/, ios/, or project root
pod install
```

### Step 5: Open Workspace

Open `*.xcworkspace` (not .xcodeproj) from the iOS project directory in Xcode.

---

## Getting Help

If issues persist:

1. **Check sample projects:**
   - [kmp-with-cocoapods-compose-sample (spm_import branch)](https://github.com/Kotlin/kmp-with-cocoapods-compose-sample/tree/spm_import)
   - [kmp-with-cocoapods-firebase-sample (spm_import branch)](https://github.com/Kotlin/kmp-with-cocoapods-firebase-sample/tree/spm_import)

2. **Run verbose build:**
   ```bash
   ./gradlew build --info
   ```

3. **Check generated files:**
   - Look in `moduleName/_internal_linkage_SwiftPMImport/` for Package.swift
