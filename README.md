# CocoaPods to SwiftPM Migration Skill

AI-assisted migration of Kotlin Multiplatform (KMP) projects from CocoaPods to Swift Package Manager import.

## Overview

This repository provides comprehensive documentation and AI assistant configurations for migrating KMP projects from the `kotlin("native.cocoapods")` Gradle plugin to the new `swiftPMDependencies {}` DSL.

**Supported AI Assistants:**
- [Claude Code](https://claude.ai/code) - Anthropic's CLI for Claude
- [Junie](https://www.jetbrains.com/junie/) - JetBrains AI assistant

## Quick Start

### Option 1: Drag and Drop (Any Claude Interface)

1. Download [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
2. Open your KMP project in your IDE
3. Drag the file into a Claude conversation
4. Follow the AI-guided migration process

### Option 2: AgentSkills Installation

This repository follows the [AgentSkills specification](https://agentskills.io/specification).

**For Claude Code:**
```bash
git clone https://github.com/Kotlin/kmp-cocoapods-to-spm-migration.git \
  ~/.claude/skills/migrate-cocoapods-to-spm
```

**For Junie:**
```bash
git clone https://github.com/Kotlin/kmp-cocoapods-to-spm-migration.git \
  .junie/skills/migrate-cocoapods-to-spm
```

Then invoke with `/migrate-cocoapods-to-spm` in either Claude Code or Junie.

## Requirements

- **Kotlin**: `2.2.21-titan-211` (custom build with SwiftPM import)
- **Gradle**: 9.2.1+
- **Xcode**: 16.4 or 26.0+
- **iOS Deployment Target**: 16.0+ recommended

## Migration Phases

| Phase | Action |
|-------|--------|
| 1 | Analyze existing CocoaPods configuration |
| 2 | Update Gradle configuration (repos, Kotlin version) |
| 3 | Replace `cocoapods {}` with `swiftPMDependencies {}` |
| 4 | Transform Kotlin imports (`cocoapods.*` → `swiftPMImport.*`) |
| 5 | Reconfigure iOS project (remove CocoaPods, run integration tasks) |
| 6 | Verify build |

## Repository Structure

This repository follows the [AgentSkills specification](https://agentskills.io/specification).

```
├── README.md                    # This file
├── SKILL.md                     # AgentSkills skill definition (main entry point)
├── MIGRATION_GUIDE.md           # User-facing guide (drag into Claude)
└── references/                  # AgentSkills reference documents
    ├── dsl-reference.md         # Full swiftPMDependencies DSL syntax
    ├── common-pods-mapping.md   # Pod to SPM package mappings
    └── troubleshooting.md       # Common issues and solutions
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
| FirebaseFirestore | firebase/firebase-ios-sdk.git | Needs `importedModules` |
| GoogleMaps | googlemaps/ios-maps-sdk.git | `exact()` version, iOS only |

See [common-pods-mapping.md](references/common-pods-mapping.md) for the full list.

## Documentation

| Document | Description |
|----------|-------------|
| [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) | Step-by-step migration guide |
| [SKILL.md](SKILL.md) | Full skill with embedded references |
| [dsl-reference.md](references/dsl-reference.md) | Complete DSL syntax |
| [common-pods-mapping.md](references/common-pods-mapping.md) | Pod to SPM mappings |
| [troubleshooting.md](references/troubleshooting.md) | Issues and solutions |

## License

Apache License 2.0 - See [LICENSE](LICENSE) for details.

---

**Note:** The SwiftPM import feature requires Kotlin version `2.2.21-titan-211`, a custom build available from the JetBrains Maven repository. This is an experimental/preview feature.
