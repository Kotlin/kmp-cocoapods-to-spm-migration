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
│   ├── cocoapods-extras-patterns.md  # Detection and cleanup of CocoaPods workarounds
│   ├── troubleshooting.md       # Common issues and solutions
│   └── migration-report-template.md  # Post-migration report template
├── versions.yml                 # Fixed version requirements (Xcode, iOS target)
└── README.md                    # Repository overview and installation
```

## How This Skill Works

When invoked, the AI assistant:

1. **Analyzes** the existing CocoaPods configuration
2. **Guides** through 8 migration phases:
   - Phase 1: Pre-migration analysis
   - Phase 2: Gradle configuration updates
   - Phase 3: Add `swiftPMDependencies {}` alongside existing `cocoapods {}`
   - Phase 4: Transform Kotlin imports
   - Phase 5: Reconfigure iOS project and deintegrate CocoaPods
   - Phase 6: Remove CocoaPods plugin from Gradle
   - Phase 7: Gradle and Xcode build verification
   - Phase 8: Write MIGRATION_REPORT.md
3. **References** mapping tables and DSL docs as needed
4. **Troubleshoots** issues using the troubleshooting guide

**IMPORTANT**: The migration keeps CocoaPods active until Phase 6. The `swiftPMDependencies {}` block is added alongside the existing `cocoapods {}` first, the Xcode project is reconfigured, and only then is CocoaPods removed.

## Key Migration Details

### Required Kotlin Version

The Kotlin version is **not hardcoded** — the skill asks the user at migration time (Phase 1.0a) whether their project already uses a compatible version or which version to use. This allows the skill to work with official releases, Betas, RCs, and dev builds without modification.

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

The Kotlin version is **dynamic** — determined at migration time by asking the user (Phase 1.0a). The skill adapts its behavior:
- If the user's project already has a compatible version → skip version change and custom repo steps
- If the user provides a dev build version → ask for the custom Maven repo URL and add it in Phase 2.1
- If the user provides an official release/Beta/RC → skip custom repo setup

Fixed version requirements (Xcode, iOS deployment target) are in `versions.yml`.
