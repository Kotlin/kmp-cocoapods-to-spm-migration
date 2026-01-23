# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Overview

This repository contains an AI-assisted migration skill for migrating Kotlin Multiplatform (KMP) projects from CocoaPods to Swift Package Manager (SPM) import.

The skill is designed to be used with:
- **Claude Code** - As a Claude Code skill
- **Junie** - As JetBrains AI assistant guidelines

## Repository Structure

```
/
├── README.md                    # Repository overview and installation
├── SKILL.md                     # Claude Code skill definition (comprehensive version)
├── MIGRATION_GUIDE.md           # Step-by-step migration guide
├── references/
│   ├── dsl-reference.md         # Full swiftPMDependencies DSL syntax
│   ├── common-pods-mapping.md   # Pod to SPM package mappings
│   └── troubleshooting.md       # Common issues and solutions
└── agents/
    ├── claude-code/
    │   └── SKILL.md             # Claude Code skill wrapper (references main docs)
    └── junie/
        └── guidelines.md        # Junie guidelines (self-contained)
```

## How This Skill Works

When a user drags the MIGRATION_GUIDE.md or SKILL.md into a Claude conversation (or invokes the skill in Claude Code), the AI assistant:

1. **Analyzes** the existing CocoaPods configuration in the user's project
2. **Guides** through 6 migration phases:
   - Phase 1: Pre-migration analysis
   - Phase 2: Gradle configuration updates
   - Phase 3: Replace `cocoapods {}` with `swiftPMDependencies {}`
   - Phase 4: Transform Kotlin imports
   - Phase 5: iOS project reconfiguration
   - Phase 6: Build verification
3. **References** the mapping tables and DSL docs as needed
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

Working examples of migrated projects (for reference):
- [kmp-with-cocoapods-compose-sample (spm_import branch)](https://github.com/Kotlin/kmp-with-cocoapods-compose-sample/tree/spm_import)
- [kmp-with-cocoapods-firebase-sample (spm_import branch)](https://github.com/Kotlin/kmp-with-cocoapods-firebase-sample/tree/spm_import)

## When Working on This Repository

If modifying the skill or documentation:

1. **SKILL.md** is the comprehensive guide - keep it self-contained
2. **MIGRATION_GUIDE.md** is the user-facing document to drag into Claude
3. **agents/claude-code/SKILL.md** is a lightweight wrapper that references main docs
4. **agents/junie/guidelines.md** should be relatively self-contained for Junie

The documentation should be:
- AI-friendly with clear phase structure
- Actionable with specific commands and code snippets
- Include troubleshooting for common issues
