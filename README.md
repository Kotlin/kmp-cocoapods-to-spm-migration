# CocoaPods to SwiftPM Migration Skill

AI-assisted migration of Kotlin Multiplatform (KMP) projects from CocoaPods to Swift Package Manager import.

## Overview

This repository provides comprehensive documentation and AI assistant configurations for migrating KMP projects from the `kotlin("native.cocoapods")` Gradle plugin to the new `swiftPMDependencies {}` DSL.

**Supported AI Assistants:**
- [Claude Code](https://claude.ai/code) - Anthropic's CLI for Claude
- [Junie](https://www.jetbrains.com/junie/) - JetBrains AI assistant
- [Codex](https://openai.com/codex/) - OpenAI coding agent

## Quick Start

### Option 1: Drag and Drop (Any Claude Interface)

1. Download [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
2. Open your KMP project in your IDE
3. Drag the file into a Claude conversation
4. Follow the AI-guided migration process

### Option 2: One-Liner Install (Recommended)

Run these commands from your project root. They install the skill project-scoped for reproducibility.

**For Claude Code:**
```bash
mkdir -p .claude/skills && curl -sL https://kotl.in/pods-spm-skill | tar xz -C .claude/skills
```

**For Junie:**
```bash
mkdir -p .junie/skills && curl -sL https://kotl.in/pods-spm-skill | tar xz -C .junie/skills
```

**For Codex:**
```bash
mkdir -p .codex/skills && curl -sL https://kotl.in/pods-spm-skill | tar xz -C .codex/skills
```

Then invoke with `/migrate-cocoapods-to-spm` in Claude Code or Junie.  
In Codex, invoke the `migrate-cocoapods-to-spm` skill.

### Option 3: Git Clone (Latest Development Version)

This repository follows the [AgentSkills specification](https://agentskills.io/specification).

**For Claude Code:**
```bash
git clone https://github.com/Kotlin/kmp-cocoapods-to-spm-migration.git \
  .claude/skills/migrate-cocoapods-to-spm
```

**For Junie:**
```bash
git clone https://github.com/Kotlin/kmp-cocoapods-to-spm-migration.git \
  .junie/skills/migrate-cocoapods-to-spm
```

**For Codex:**
```bash
git clone https://github.com/Kotlin/kmp-cocoapods-to-spm-migration.git \
  .codex/skills/migrate-cocoapods-to-spm
```

Then invoke with `/migrate-cocoapods-to-spm` in Claude Code or Junie.  
In Codex, invoke the `migrate-cocoapods-to-spm` skill.

## Requirements

- **Kotlin**: Version with Swift Import support (e.g., 2.4.0-Beta1 or later). The skill asks the user for their version at migration time.
- **Xcode**: 16.4 or 26.0+
- **iOS Deployment Target**: 16.0+ recommended

## Migration Phases

**IMPORTANT**: CocoaPods stays active until Phase 6. The migration adds `swiftPMDependencies {}` alongside `cocoapods {}` first, reconfigures Xcode, and only then removes CocoaPods.

| Phase | Action |
|-------|--------|
| 1 | Analyze existing CocoaPods configuration (verify project builds first) |
| 2 | Update Gradle configuration (repos, Kotlin version) |
| 3 | Add `swiftPMDependencies {}` alongside existing `cocoapods {}` |
| 4 | Transform Kotlin imports (`cocoapods.*` → `swiftPMImport.*`) |
| 5 | Reconfigure iOS project and deintegrate CocoaPods |
| 6 | Remove CocoaPods plugin from Gradle |
| 7 | Verify build |
| 8 | Write MIGRATION_REPORT.md |

## Repository Structure

This repository follows the [AgentSkills specification](https://agentskills.io/specification).

```
├── README.md                    # This file
├── SKILL.md                     # AgentSkills skill definition (main entry point)
├── MIGRATION_GUIDE.md           # User-facing guide (drag into Claude)
└── references/                  # AgentSkills reference documents
    ├── dsl-reference.md         # Full swiftPMDependencies DSL syntax
    ├── common-pods-mapping.md   # Pod to SPM package mappings
    ├── cocoapods-extras-patterns.md  # Detection and cleanup of CocoaPods workarounds
    ├── troubleshooting.md       # Common issues and solutions
    └── migration-report-template.md  # Post-migration report template
```

## Sample Projects

Working examples of migrated projects:
- [kmp-with-cocoapods-compose-sample (spm_import branch)](https://github.com/Kotlin/kmp-with-cocoapods-compose-sample/tree/spm_import)
- [kmp-with-cocoapods-firebase-sample (spm_import branch)](https://github.com/Kotlin/kmp-with-cocoapods-firebase-sample/tree/spm_import)

## Key Concepts

### Import Namespace Formula

```
swiftPMImport.<group>.<module>.<ClassName>
```

**Example:**
```kotlin
// CocoaPods:
import cocoapods.FirebaseAnalytics.FIRAnalytics

// SwiftPM Import (group = "org.example.myproject", module = "shared"):
import swiftPMImport.org.example.myproject.shared.FIRAnalytics
```

### Common Pod Mappings

| Pod | SPM Repository | Notes |
|-----|----------------|-------|
| FirebaseAnalytics | firebase/firebase-ios-sdk.git | `from()` version |
| FirebaseFirestore | firebase/firebase-ios-sdk.git | Needs `importedModules: FirebaseFirestoreInternal` |
| FirebaseCrashlytics | firebase/firebase-ios-sdk.git | Needs dSYM upload script |
| GoogleMaps | googlemaps/ios-maps-sdk.git | `exact()` version, iOS 16+ only |
| GoogleSignIn | google/GoogleSignIn-iOS.git | `from()` version |

See [common-pods-mapping.md](references/common-pods-mapping.md) for the full list, including:
- KMP wrapper libraries with bundled cinterop klibs ([KMPNotifier](https://github.com/mirzemehdi/KMPNotifier), [firebase-kotlin-sdk](https://github.com/GitLiveApp/firebase-kotlin-sdk))
- Firebase `importedModules` reference (Clang module names that differ from product names)
- Guidance for researching unmapped pods with `klib dump-metadata-signatures`

### Key Caveats

- **Bundled `cocoapods.*` imports may survive migration.** KMP libraries like [KMPNotifier](https://github.com/mirzemehdi/KMPNotifier) ship pre-built cinterop klibs with `cocoapods.*` namespaces. Those imports must be preserved — they resolve to the library's bundled klib, not actual CocoaPods.
- **`dev.gitlive:firebase-*` requires `isStatic = true` and framework search paths.** These wrapper libraries have CocoaPods-era linker flags baked in. With SPM, Firebase frameworks live in per-product subdirectories requiring explicit `-F` linkerOpts and `FRAMEWORK_SEARCH_PATHS`. A dynamic framework causes `dyld` crashes at runtime.
- **`discoverModulesImplicitly = false` is required for Firebase.** Firebase's transitive C++ dependencies (gRPC, abseil, leveldb, BoringSSL) fail cinterop. Explicitly list only the Firebase Clang modules you need in `importedModules`.

## Documentation

| Document | Description |
|----------|-------------|
| [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) | Step-by-step migration guide |
| [SKILL.md](SKILL.md) | Full skill with embedded references |
| [dsl-reference.md](references/dsl-reference.md) | Complete DSL syntax |
| [common-pods-mapping.md](references/common-pods-mapping.md) | Pod to SPM mappings |
| [cocoapods-extras-patterns.md](references/cocoapods-extras-patterns.md) | Detection and cleanup of CocoaPods workarounds |
| [troubleshooting.md](references/troubleshooting.md) | Issues and solutions |
| [migration-report-template.md](references/migration-report-template.md) | Post-migration report template |

## Version Management

The Kotlin version is **dynamic** — the skill asks the user for their Kotlin version at migration time and adapts accordingly (adding custom Maven repos for dev builds, skipping version changes if already compatible, etc.).

Fixed version requirements (Xcode, iOS deployment target) are in `versions.yml`.

## License

Apache License 2.0 - See [LICENSE](LICENSE) for details.

---

**Note:** The SwiftPM import feature requires a Kotlin version with Swift Import support (e.g., 2.4.0-Beta1 or later). Dev builds may require the JetBrains Maven repository.
