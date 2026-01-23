---
name: migrate-cocoapods-to-spm
description: |
  Migrate Kotlin Multiplatform (KMP) projects from CocoaPods to Swift Package Manager import.
  Use when: (1) User wants to migrate from kotlin("native.cocoapods") plugin to swiftPMDependencies DSL,
  (2) User needs to replace pod() declarations with package() declarations,
  (3) User wants to update imports from cocoapods.* to swiftPMImport.*,
  (4) User mentions CocoaPods to SPM migration for KMP/Kotlin Multiplatform.
---

# CocoaPods to SwiftPM Migration Skill

Follow the instructions in [MIGRATION_GUIDE.md](../../MIGRATION_GUIDE.md) to migrate Kotlin Multiplatform projects from CocoaPods to SwiftPM.

## Reference Documents

- [MIGRATION_GUIDE.md](../../MIGRATION_GUIDE.md) - Main migration guide with all phases
- [references/dsl-reference.md](../../references/dsl-reference.md) - SwiftPM DSL syntax
- [references/common-pods-mapping.md](../../references/common-pods-mapping.md) - Pod to SPM mappings
- [references/troubleshooting.md](../../references/troubleshooting.md) - Common issues and solutions

## Workflow

1. **Read the migration guide** - Start with MIGRATION_GUIDE.md
2. **Analyze the project** - Follow Phase 1 to gather information
3. **Execute phases sequentially** - Phases 2-6 in order
4. **Use references as needed** - DSL reference for syntax, mappings for pods
5. **Troubleshoot issues** - Use troubleshooting.md for common problems

## Key Automation (Phase 5.1)

The migration guide includes automated path discovery:

```bash
# Find iOS project directory
IOS_DIR=$(dirname "$(find . -name "Podfile" -type f | head -1)")

# Find .xcodeproj
XCODEPROJ=$(realpath "$(find "$IOS_DIR" -maxdepth 1 -name "*.xcodeproj" -type d | grep -v Pods | head -1)")

# Find KMP module
KMP_MODULE=$(grep -rl "swiftPMDependencies" --include="build.gradle.kts" . | head -1 | xargs dirname | xargs basename)
```

Use these values throughout Phase 5 operations.
