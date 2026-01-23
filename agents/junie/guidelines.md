# CocoaPods to SwiftPM Migration Guidelines

## Overview

This project guideline helps migrate Kotlin Multiplatform (KMP) projects from CocoaPods to Swift Package Manager import.

## When to Apply

Apply these guidelines when the user:
- Wants to migrate from `kotlin("native.cocoapods")` to `swiftPMDependencies`
- Needs to replace `pod()` declarations with `package()` declarations
- Wants to update imports from `cocoapods.*` to `swiftPMImport.*`
- Mentions CocoaPods to SPM migration for KMP

## Technical Stack

- **Language**: Kotlin (KMP - Kotlin Multiplatform)
- **Build System**: Gradle 9.2.1+
- **Kotlin Version**: 2.2.21-titan-211 (custom build with SwiftPM import)
- **IDE**: Xcode 16.4 or 26.0+
- **iOS Deployment Target**: 16.0+

## Migration Workflow

Follow the phases in `MIGRATION_GUIDE.md`:

1. **Phase 1: Analyze** - Find cocoapods config, pod dependencies, Kotlin imports
2. **Phase 2: Gradle Config** - Update repositories, Kotlin version to 2.2.21-titan-211
3. **Phase 3: Module Migration** - Replace cocoapods{} with swiftPMDependencies{}
4. **Phase 4: Kotlin Imports** - Transform cocoapods.* to swiftPMImport.<group>.<module>.*
5. **Phase 5: iOS Project** - Remove CocoaPods, run Gradle integration tasks
6. **Phase 6: Verify** - Build Gradle and Xcode projects

## Code Standards

### Import Namespace Formula

```
swiftPMImport.<group>.<module>.<ClassName>
```

Where:
- `group`: from build.gradle.kts `group` property, dashes (-) become dots (.)
- `module`: Gradle module name, dashes (-) become dots (.)

### Example Transformation

```kotlin
// BEFORE (CocoaPods):
import cocoapods.FirebaseAnalytics.FIRAnalytics

// AFTER (SwiftPM):
import swiftPMImport.org.jetbrains.kotlin.firebase.sample.kotlin.library.FIRAnalytics
```

### Framework Configuration Pattern

```kotlin
targets
    .withType<KotlinNativeTarget>()
    .matching { it.konanTarget.family.isAppleFamily }
    .configureEach {
        binaries.framework {
            baseName = "SharedModule"
            isStatic = true  // Must be true for SwiftPM
        }
    }
```

## Implementation Guidance

### Path Discovery (Phase 5.1)

Always use these commands to discover project paths:

```bash
# Find iOS project directory (contains Podfile)
IOS_DIR=$(dirname "$(find . -name "Podfile" -type f | head -1)")

# Find .xcodeproj (exclude Pods.xcodeproj)
XCODEPROJ=$(realpath "$(find "$IOS_DIR" -maxdepth 1 -name "*.xcodeproj" -type d | grep -v Pods | head -1)")

# Find KMP module with swiftPMDependencies
KMP_MODULE=$(grep -rl "swiftPMDependencies" --include="build.gradle.kts" . | head -1 | xargs dirname | xargs basename)
```

### SwiftPM Dependencies Block Pattern

```kotlin
swiftPMDependencies {
    iosDeploymentVersion.set("16.0")

    `package`(
        url = url("https://github.com/firebase/firebase-ios-sdk.git"),
        version = from("12.6.0"),
        products = listOf(product("FirebaseAnalytics")),
    )
}
```

### Antipatterns to Avoid

- Do NOT use `.xcworkspace` after migration - use `.xcodeproj`
- Do NOT use `from()` version for GoogleMaps - use `exact()`
- Do NOT forget to set `isStatic = true` in framework config
- Do NOT leave CocoaPods plugin in build.gradle.kts after migration

## Common Pod Mappings

| Pod | SPM Repository | Version Type | Notes |
|-----|----------------|--------------|-------|
| FirebaseAnalytics | firebase/firebase-ios-sdk.git | from() | - |
| FirebaseFirestore | firebase/firebase-ios-sdk.git | from() | importedModules: FirebaseFirestoreInternal |
| GoogleMaps | googlemaps/ios-maps-sdk.git | exact() | iOS only |

## Reference Files

When using the full skill package, these files are available:
- `../../MIGRATION_GUIDE.md` - Complete step-by-step migration guide
- `../../references/dsl-reference.md` - Full swiftPMDependencies DSL syntax
- `../../references/common-pods-mapping.md` - Pod to SPM package mappings
- `../../references/troubleshooting.md` - Common issues and solutions

## Sample Projects

See working examples of migrated projects:
- [kmp-with-cocoapods-compose-sample (spm_import)](https://github.com/Kotlin/kmp-with-cocoapods-compose-sample/tree/spm_import)
- [kmp-with-cocoapods-firebase-sample (spm_import)](https://github.com/Kotlin/kmp-with-cocoapods-firebase-sample/tree/spm_import)
