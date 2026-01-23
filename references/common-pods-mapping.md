# Common Pods to SwiftPM Mapping

Reference for migrating popular CocoaPods dependencies to SwiftPM.

## Firebase Suite

All Firebase products come from the same repository: `https://github.com/firebase/firebase-ios-sdk.git`

### FirebaseAnalytics

```kotlin
// CocoaPods
pod("FirebaseAnalytics") { version = "12.5.0" }

// SwiftPM
`package`(
    url = url("https://github.com/firebase/firebase-ios-sdk.git"),
    version = from("12.6.0"),
    products = listOf(product("FirebaseAnalytics")),
)
```

**Kotlin import:**
```kotlin
import swiftPMImport.<group>.<module>.FIRAnalytics
import swiftPMImport.<group>.<module>.FIRApp
```

### FirebaseAuth

```kotlin
// CocoaPods
pod("FirebaseAuth") { version = "12.5.0" }

// SwiftPM
`package`(
    url = url("https://github.com/firebase/firebase-ios-sdk.git"),
    version = from("12.6.0"),
    products = listOf(product("FirebaseAuth")),
)
```

**Kotlin import:**
```kotlin
import swiftPMImport.<group>.<module>.FIRAuth
import swiftPMImport.<group>.<module>.FIRUser
```

### FirebaseFirestore (Special Case)

Firestore uses a different Clang module name than its product name.

```kotlin
// CocoaPods
pod("FirebaseFirestore") { version = "12.5.0" }

// SwiftPM - Note the importedModules parameter
`package`(
    url = url("https://github.com/firebase/firebase-ios-sdk.git"),
    version = from("12.6.0"),
    products = listOf(product("FirebaseFirestore")),
    importedModules = listOf("FirebaseFirestoreInternal"),
)
```

**Kotlin import:**
```kotlin
import swiftPMImport.<group>.<module>.FIRFirestore
import swiftPMImport.<group>.<module>.FIRDocumentReference
```

### Combined Firebase Example

```kotlin
swiftPMDependencies {
    `package`(
        url = url("https://github.com/firebase/firebase-ios-sdk.git"),
        version = from("12.6.0"),
        products = listOf(
            product("FirebaseAnalytics"),
            product("FirebaseAuth"),
            product("FirebaseFirestore")
        ),
        importedModules = listOf(
            "FirebaseAnalytics",
            "FirebaseAuth",
            "FirebaseCore",
            "FirebaseFirestoreInternal"
        ),
    )
}
```

---

## Google Maps

Google Maps requires exact version matching and is iOS-only.

```kotlin
// CocoaPods
pod("GoogleMaps") { version = "10.3.0" }

// SwiftPM
`package`(
    url = url("https://github.com/googlemaps/ios-maps-sdk.git"),
    version = exact("10.6.0"),  // Must use exact()
    products = listOf(
        product("GoogleMaps", platforms = setOf(iOS()))
    ),
)
```

**Kotlin import:**
```kotlin
import swiftPMImport.<group>.<module>.GMSMapView
import swiftPMImport.<group>.<module>.GMSCameraPosition
import swiftPMImport.<group>.<module>.GMSMarker
import swiftPMImport.<group>.<module>.GMSServices
```

**Note:** Check [googlemaps/ios-maps-sdk releases](https://github.com/googlemaps/ios-maps-sdk/releases) for available SPM versions.

---

## LoremIpsum

Simple text generation library with direct mapping.

```kotlin
// CocoaPods
pod("LoremIpsum") { version = "2.0.1" }

// SwiftPM
`package`(
    url = url("https://github.com/lukaskubanek/LoremIpsum.git"),
    version = from("2.0.1"),
    products = listOf(product("LoremIpsum")),
)
```

**Kotlin import:**
```kotlin
import swiftPMImport.<group>.<module>.LoremIpsum
```

---

## Quick Reference Table

| Pod Name | SPM Repository | Version Type | Platform | Notes |
|----------|----------------|--------------|----------|-------|
| FirebaseAnalytics | firebase/firebase-ios-sdk.git | from() | All | - |
| FirebaseAuth | firebase/firebase-ios-sdk.git | from() | All | - |
| FirebaseFirestore | firebase/firebase-ios-sdk.git | from() | All | importedModules: FirebaseFirestoreInternal |
| FirebaseCore | firebase/firebase-ios-sdk.git | from() | All | - |
| FirebaseMessaging | firebase/firebase-ios-sdk.git | from() | All | - |
| GoogleMaps | googlemaps/ios-maps-sdk.git | exact() | iOS only | Requires platform constraint |
| LoremIpsum | lukaskubanek/LoremIpsum.git | from() | All | - |

---

## Researching Other Pods

For pods not listed here:

1. **Check GitHub repository** - Look for a `Package.swift` file in the repo
2. **Check CocoaPods spec** - The `source` field often points to the Git URL
3. **Search Swift Package Index** - https://swiftpackageindex.com/
4. **Check library documentation** - Many libraries document SPM installation

### Finding the Clang Module Name

If you're unsure of the correct Clang module name:

1. Keep `discoverModulesImplicitly = true` (default)
2. Run `./gradlew build`
3. Check build errors for available class names
4. Or check the library's `module.modulemap` file in its source

### Version Compatibility

SPM versions may differ from CocoaPods versions. Always:
1. Check the GitHub releases page for SPM-compatible versions
2. Use `exact()` if the library requires exact version matching
3. Test thoroughly after migration
