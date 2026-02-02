# AGENTS.md

This file provides guidance to AI coding assistants when working with this repository.

## Overview

This repository contains an AI-assisted migration skill for migrating Kotlin Multiplatform (KMP) projects from CocoaPods to Swift Package Manager (SPM) import.

The skill is designed to be used with:
- **Claude Code** - As a Claude Code skill
- **Junie** - As JetBrains AI assistant guidelines
- **Other AI assistants** - Via drag-and-drop of MIGRATION_GUIDE.md

## Repository Structure

This repository follows the [AgentSkills specification](https://agentskills.io/specification).

```
/
├── SKILL.md                     # AgentSkills skill definition (main entry point)
├── MIGRATION_GUIDE.md           # User-facing guide (drag into AI chat)
├── references/                  # AgentSkills reference documents
│   ├── dsl-reference.md         # Full swiftPMDependencies DSL syntax
│   ├── common-pods-mapping.md   # Pod to SPM package mappings
│   └── troubleshooting.md       # Common issues and solutions
├── versions.yml                 # Centralized version requirements
├── update-versions.sh           # Script to sync versions across docs
└── README.md                    # Repository overview and installation
```

## How This Skill Works

When invoked, the AI assistant:

1. **Analyzes** the existing CocoaPods configuration
2. **Guides** through 6 migration phases:
   - Phase 1: Pre-migration analysis
   - Phase 2: Gradle configuration updates
   - Phase 3: Replace `cocoapods {}` with `swiftPMDependencies {}`
   - Phase 4: Transform Kotlin imports
   - Phase 5: iOS project reconfiguration
   - Phase 6: Build verification
3. **References** mapping tables and DSL docs as needed
4. **Troubleshoots** issues using the troubleshooting guide

## Key Migration Details

### Required Kotlin Version

```kotlin
// The SPM import requires a custom Kotlin build:
kotlin = "2.2.21-titan-211"
```

### Import Namespace Formula

```
swiftPMImport.<group>.<module>.<ClassName>

Where:
- group: build.gradle.kts `group` property, dashes (-) → dots (.)
- module: Gradle module name, dashes (-) → dots (.)
```

### Example Transformation

```kotlin
// CocoaPods:
import cocoapods.FirebaseAnalytics.FIRAnalytics

// SwiftPM Import:
import swiftPMImport.org.example.myproject.shared.FIRAnalytics
```

## Sample Projects

Working examples of migrated projects:
- [kmp-with-cocoapods-compose-sample (spm_import branch)](https://github.com/Kotlin/kmp-with-cocoapods-compose-sample/tree/spm_import)
- [kmp-with-cocoapods-firebase-sample (spm_import branch)](https://github.com/Kotlin/kmp-with-cocoapods-firebase-sample/tree/spm_import)

## Working on This Repository

When modifying the skill or documentation:

1. **SKILL.md** - AgentSkills entry point; keep self-contained with valid YAML frontmatter
2. **MIGRATION_GUIDE.md** - User-facing document for drag-and-drop use
3. **references/** - Supporting documentation following AgentSkills convention

Documentation should be:
- AI-friendly with clear phase structure
- Actionable with specific commands and code snippets
- Include troubleshooting for common issues

## Version Management

Version requirements are centralized in `versions.yml`:

```yaml
kotlin: "2.2.21-titan-211"
gradle: "9.2.1"
custom_kotlin_repo_required: true
custom_kotlin_repo_url: "https://packages.jetbrains.team/maven/p/kt/dev"
```

To update versions across all documentation:
1. Edit `versions.yml`
2. Run `./update-versions.sh`

Note: Set `custom_kotlin_repo_required: false` when the feature graduates to official Kotlin releases.
