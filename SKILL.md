---
name: migrate-cocoapods-to-spm
description: |
  Migrate Kotlin Multiplatform (KMP) projects from CocoaPods to Swift Package Manager import.
  Use when: (1) User wants to migrate from kotlin("native.cocoapods") plugin to swiftPMDependencies DSL,
  (2) User needs to replace pod() declarations with package() declarations,
  (3) User wants to update imports from cocoapods.* to swiftPMImport.*,
  (4) User mentions CocoaPods to SPM migration for KMP/Kotlin Multiplatform.
license: Apache-2.0
compatibility: |
  Requires Kotlin 2.2.21-titan-211 (custom build), Gradle 9.2.1+, Xcode 16.4 or 26.0+.
  Works with Claude Code, Junie, or any AgentSkills-compatible assistant.
metadata:
  author: JetBrains
  version: "1.0.0"
  category: kotlin-multiplatform
  homepage: https://github.com/Kotlin/kmp-cocoapods-to-spm-migration
---

# CocoaPods to SwiftPM Migration for KMP

Migrate Kotlin Multiplatform projects from `kotlin("native.cocoapods")` to `swiftPMDependencies {}` DSL.

## Requirements

- **Kotlin**: `2.2.21-titan-211` (custom build with SwiftPM import)
- **Gradle**: 9.2.1+
- **Xcode**: 16.4 or 26.0+
- **iOS Deployment Target**: 16.0+ recommended

## Migration Overview

| Phase | Action |
|-------|--------|
| 1 | Analyze existing CocoaPods configuration |
| 2 | Update Gradle configuration (repos, Kotlin version) |
| 3 | Replace `cocoapods {}` with `swiftPMDependencies {}` |
| 4 | Transform Kotlin imports |
| 5 | Reconfigure iOS project |
| 6 | Verify build |

---

## Phase 1: Pre-Migration Analysis

**Find and record:**

1. **CocoaPods configuration** - Search for `cocoapods` in `build.gradle.kts` files
2. **Pod dependencies** - Extract pod names, versions from `cocoapods {}` blocks
3. **Kotlin imports** - Find all `import cocoapods.*` statements
4. **Map pods to SPM** - See [common-pods-mapping.md](references/common-pods-mapping.md)
5. **Locate iOS project directory** - Find the directory containing `Podfile` and `.xcworkspace`:
   ```bash
   find . -name "Podfile" -type f
   ```
   Record this path (e.g., `iosApp/`, `ios/`, or project root) - needed for Phase 5

---

## Phase 2: Gradle Configuration

### 2.1 Update gradle-wrapper.properties

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-9.2.1-bin.zip
```

### 2.2 Update settings.gradle.kts

Add JetBrains Maven repository:

```kotlin
pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
        maven("https://packages.jetbrains.team/maven/p/kt/dev")  // ADD
    }
}

dependencyResolutionManagement {
    repositories {
        mavenCentral()
        maven("https://packages.jetbrains.team/maven/p/kt/dev")  // ADD
    }
}
```

### 2.3 Update Kotlin version

```toml
# gradle/libs.versions.toml
[versions]
kotlin = "2.2.21-titan-211"
```

### 2.4 Add buildscript constraint (if swiftPMDependencies not recognized)

```kotlin
// root build.gradle.kts
buildscript {
    dependencies.constraints {
        "classpath"("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.21-titan-211!!")
    }
}
```

---

## Phase 3: Module build.gradle.kts Migration

### 3.1 Add import and group

```kotlin
import org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget

group = "org.example.myproject"  // Required for import namespace
```

### 3.2 Remove CocoaPods plugin

```kotlin
plugins {
    // REMOVE: kotlin("native.cocoapods")
    alias(libs.plugins.kotlinMultiplatform)  // Keep
}
```

### 3.3 Replace cocoapods block

**BEFORE:**
```kotlin
cocoapods {
    ios.deploymentTarget = "16.0"
    framework {
        baseName = "SharedModule"
        isStatic = true
    }
    pod("FirebaseAnalytics") { version = "12.5.0" }
}
```

**AFTER:**
```kotlin
swiftPMDependencies {
    iosDeploymentVersion.set("16.0")

    `package`(
        url = url("https://github.com/firebase/firebase-ios-sdk.git"),
        version = from("12.6.0"),
        products = listOf(product("FirebaseAnalytics")),
    )
}

// Framework config moves outside cocoapods block
targets
    .withType<KotlinNativeTarget>()
    .matching { it.konanTarget.family.isAppleFamily }
    .configureEach {
        binaries.framework {
            baseName = "SharedModule"
            isStatic = true
        }
    }
```

### 3.4 Add language settings

```kotlin
sourceSets.configureEach {
    languageSettings {
        optIn("kotlinx.cinterop.ExperimentalForeignApi")
    }
}
```

For full DSL reference, see [dsl-reference.md](references/dsl-reference.md).

---

## Phase 4: Kotlin Source Updates

### Import Namespace Formula

```
swiftPMImport.<group>.<module>.<ClassName>

Where:
- group: build.gradle.kts `group` property, dashes (-) → dots (.)
- module: Gradle module name, dashes (-) → dots (.)
- ClassName: Objective-C class name (FIR* for Firebase, GMS* for Google Maps)
```

### Example Transformation

```kotlin
// group = "org.jetbrains.kotlin.firebase.sample", module = "kotlin-library"

// BEFORE:
import cocoapods.FirebaseAnalytics.FIRAnalytics

// AFTER:
import swiftPMImport.org.jetbrains.kotlin.firebase.sample.kotlin.library.FIRAnalytics
```

**Finding correct import path:** Run `./gradlew build` - errors show available classes.

---

## Phase 5: iOS Project Migration

### 5.1 Remove CocoaPods integration

**Step 1: Discover project paths**
```bash
# Find iOS project directory (contains Podfile)
IOS_DIR=$(dirname "$(find . -name "Podfile" -type f | head -1)")

# Find .xcodeproj (exclude Pods.xcodeproj) - use realpath for absolute path
XCODEPROJ=$(realpath "$(find "$IOS_DIR" -maxdepth 1 -name "*.xcodeproj" -type d | grep -v Pods | head -1)")

# Find KMP module with swiftPMDependencies (module directory name)
KMP_MODULE=$(grep -rl "swiftPMDependencies" --include="build.gradle.kts" . | head -1 | xargs dirname | xargs basename)

echo "iOS directory: $IOS_DIR"
echo "Xcode project: $XCODEPROJ"
echo "KMP module: $KMP_MODULE"
```

**Step 2: Run pod deintegrate**
```bash
cd "$IOS_DIR" && pod deintegrate
```

**Step 3: Clean up CocoaPods artifacts**
```bash
# In iOS project directory (still in $IOS_DIR)
rm -rf Podfile Podfile.lock Pods/ *.xcworkspace

# Return to project root and remove podspec files
cd "$(git rev-parse --show-toplevel 2>/dev/null || cd .. && pwd)"
rm -f *.podspec
```

### 5.2 Run Gradle integration tasks

Run the integration tasks with the discovered paths:

```bash
XCODEPROJ_PATH="$XCODEPROJ" \
GRADLE_PROJECT_PATH=":$KMP_MODULE" \
./gradlew ":$KMP_MODULE:integrateEmbedAndSign" ":$KMP_MODULE:integrateLinkagePackage"
```

This automatically modifies the `.xcodeproj` to:
- Add "Compile Kotlin" build phase before "Compile Sources"
- Set `ENABLE_USER_SCRIPT_SANDBOXING = NO`
- Add the internal SwiftPM linkage package as a local dependency

**Note:** If the integration tasks fail, see section 5.3 for manual configuration.

### 5.3 Manual integration (if automatic fails)

1. Open `.xcodeproj` (NOT .xcworkspace)
2. Add "Compile Kotlin" run script phase BEFORE "Compile Sources":
   ```bash
   cd "$SRCROOT/.."
   ./gradlew :moduleName:embedAndSignAppleFrameworkForXcode
   ```
3. Set `ENABLE_USER_SCRIPT_SANDBOXING = NO`
4. Add local package: `../moduleName/_internal_linkage_SwiftPMImport`

---

## Phase 6: Verification

```bash
# 1. Build Gradle project
./gradlew clean build

# 2. Link framework
./gradlew :moduleName:linkDebugFrameworkIosSimulatorArm64

# 3. Build in Xcode
# Open iosApp.xcodeproj, select simulator, Cmd+B
```

---

## Quick Reference

### Common Pod to SPM Mappings

| Pod | SPM URL | Notes |
|-----|---------|-------|
| FirebaseAnalytics | firebase/firebase-ios-sdk.git | Product: FirebaseAnalytics |
| FirebaseFirestore | firebase/firebase-ios-sdk.git | importedModules: FirebaseFirestoreInternal |
| GoogleMaps | googlemaps/ios-maps-sdk.git | Use `exact()` version |

See [common-pods-mapping.md](references/common-pods-mapping.md) for full list.

### Troubleshooting

| Issue | Solution |
|-------|----------|
| swiftPMDependencies not found | Add buildscript constraint (Phase 2.4) |
| Import not found | Check group/module naming, run build for errors |
| Linker errors | Ensure isStatic = true, run integrateLinkagePackage |

See [troubleshooting.md](references/troubleshooting.md) for detailed solutions.

---

## Additional Resources

- [DSL Reference](references/dsl-reference.md) - Full swiftPMDependencies syntax
- [Common Pods Mapping](references/common-pods-mapping.md) - Pod to SPM mapping table
- [Troubleshooting](references/troubleshooting.md) - Issues, solutions, rollback
