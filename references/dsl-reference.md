# SwiftPM Import DSL Reference

Complete reference for the `swiftPMDependencies {}` DSL in Kotlin Multiplatform.

## Basic Structure

```kotlin
kotlin {
    iosArm64()
    iosSimulatorArm64()

    swiftPMDependencies {
        // Deployment versions
        iosDeploymentVersion.set("16.0")
        macosDeploymentVersion.set("13.0")
        tvosDeploymentVersion.set("16.0")
        watchosDeploymentVersion.set("9.0")

        // IDE integration
        xcodeProjectPathForKmpIJPlugin.set(
            layout.projectDirectory.file("../iosApp/iosApp.xcodeproj")
        )

        // Module discovery (default: true)
        discoverModulesImplicitly = true

        // Package declarations
        `package`(...)
        localPackage(...)
    }
}
```

---

## Package Declaration

### Remote Package (Git URL)

```kotlin
`package`(
    url = url("https://github.com/owner/repo.git"),
    version = from("1.0.0"),
    products = listOf(
        product("ProductName"),
        product("AnotherProduct")
    ),
)
```

### Remote Package (Swift Package Registry)

```kotlin
`package`(
    repository = id("scope.package-name"),
    version = from("1.0.0"),
    products = listOf(product("ProductName")),
)
```

### Local Package

```kotlin
localPackage(
    path = projectDir.resolve("../LocalPackage"),
    products = listOf("LocalPackage")
)
```

---

## Version Specification

| Function | Description | Use Case |
|----------|-------------|----------|
| `from("1.0")` | Minimum version (like Gradle "require") | Most packages |
| `exact("1.0")` | Exact version (like Gradle "strict") | GoogleMaps, strict dependencies |
| `branch("name")` | Git branch | Development, testing |
| `revision("hash")` | Git commit hash | Pinning specific commits |

### Examples

```kotlin
// Minimum version - allows compatible updates
version = from("12.5.0")

// Exact version - no updates
version = exact("10.3.0")

// Branch tracking
version = branch("main")

// Specific commit
version = revision("abc123def456")
```

---

## Product Configuration

### Basic Product

```kotlin
products = listOf(product("FirebaseAnalytics"))
```

### Multiple Products from Same Package

```kotlin
products = listOf(
    product("FirebaseAnalytics"),
    product("FirebaseAuth"),
    product("FirebaseFirestore")
)
```

### Platform-Constrained Product

For packages that only support certain platforms:

```kotlin
products = listOf(
    product("GoogleMaps", platforms = setOf(iOS()))  // iOS only
)
```

Available platforms:
- `iOS()`
- `macOS()`
- `tvOS()`
- `watchOS()`

---

## Module Import Configuration

### Automatic Discovery (Default)

By default, `discoverModulesImplicitly = true`. SwiftPM import automatically discovers and imports all accessible Clang modules.

### Explicit Module Import

When the Clang module name differs from the product name:

```kotlin
swiftPMDependencies {
    discoverModulesImplicitly = false  // Disable auto-discovery

    `package`(
        url = url("https://github.com/firebase/firebase-ios-sdk.git"),
        version = from("12.6.0"),
        products = listOf(
            product("FirebaseAnalytics"),
            product("FirebaseFirestore")
        ),
        importedModules = listOf(
            "FirebaseAnalytics",
            "FirebaseCore",
            "FirebaseFirestoreInternal"  // Note: different from product name
        ),
    )
}
```

### When to Use importedModules

| Scenario | Use importedModules? |
|----------|---------------------|
| Product name = module name | No (auto-discovery works) |
| Product name != module name | Yes |
| Multiple modules per product | Yes |
| Using discoverModulesImplicitly = false | Yes |

---

## Deployment Versions

Set minimum deployment targets for each platform:

```kotlin
swiftPMDependencies {
    iosDeploymentVersion.set("16.0")
    macosDeploymentVersion.set("13.0")
    tvosDeploymentVersion.set("16.0")
    watchosDeploymentVersion.set("9.0")
}
```

---

## IDE Integration

For KMP IntelliJ plugin integration, specify the Xcode project path:

```kotlin
swiftPMDependencies {
    xcodeProjectPathForKmpIJPlugin.set(
        layout.projectDirectory.file("../iosApp/iosApp.xcodeproj")
    )
}
```

This enables the IDE to properly resolve SwiftPM dependencies and provide code completion.

---

## Complete Example

```kotlin
import org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget

plugins {
    alias(libs.plugins.kotlinMultiplatform)
}

group = "org.example.myproject"
version = "1.0-SNAPSHOT"

kotlin {
    iosArm64()
    iosSimulatorArm64()

    swiftPMDependencies {
        iosDeploymentVersion.set("16.0")

        xcodeProjectPathForKmpIJPlugin.set(
            layout.projectDirectory.file("../iosApp/iosApp.xcodeproj")
        )

        // Firebase packages
        `package`(
            url = url("https://github.com/firebase/firebase-ios-sdk.git"),
            version = from("12.6.0"),
            products = listOf(
                product("FirebaseAnalytics"),
                product("FirebaseAuth"),
                product("FirebaseFirestore")
            ),
        )

        // Google Maps (iOS only, exact version)
        `package`(
            url = url("https://github.com/googlemaps/ios-maps-sdk.git"),
            version = exact("10.6.0"),
            products = listOf(
                product("GoogleMaps", platforms = setOf(iOS()))
            ),
        )

        // Local package
        localPackage(
            path = projectDir.resolve("LocalWrapper"),
            products = listOf("LocalWrapper")
        )
    }

    // Framework configuration (moved from cocoapods block)
    targets
        .withType<KotlinNativeTarget>()
        .matching { it.konanTarget.family.isAppleFamily }
        .configureEach {
            binaries.framework {
                baseName = "SharedModule"
                isStatic = true
            }
        }

    sourceSets.configureEach {
        languageSettings {
            optIn("kotlinx.cinterop.ExperimentalForeignApi")
        }
    }
}
```

---

## Transitive Dependencies

SwiftPM dependencies are automatically handled transitively. If your package depends on other SwiftPM packages, the Kotlin Gradle Plugin will provision necessary machine code from transitive dependencies.

You can optionally declare transitive dependencies explicitly to pin specific versions:

```kotlin
swiftPMDependencies {
    // Main dependency
    `package`(
        url = url("https://github.com/firebase/firebase-ios-sdk.git"),
        version = from("12.5.0"),
        products = listOf(product("FirebaseAnalytics")),
    )

    // Transitive dependency with explicit version
    `package`(
        url = url("https://github.com/apple/swift-protobuf.git"),
        version = exact("1.32.0"),
        products = listOf(),  // No direct import needed
    )
}
```
