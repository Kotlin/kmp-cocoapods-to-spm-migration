#!/bin/bash
set -euo pipefail

# Parse versions from YAML (portable, no yq dependency)
KOTLIN=$(grep '^kotlin:' versions.yml | cut -d'"' -f2)
GRADLE=$(grep '^gradle:' versions.yml | cut -d'"' -f2)
XCODE=$(grep '^xcode:' versions.yml | cut -d'"' -f2)
IOS_TARGET=$(grep '^ios_deployment_target:' versions.yml | cut -d'"' -f2)
CUSTOM_REPO_REQUIRED=$(grep '^custom_kotlin_repo_required:' versions.yml | awk '{print $2}')
CUSTOM_REPO_URL=$(grep '^custom_kotlin_repo_url:' versions.yml | cut -d'"' -f2)

echo "Updating versions:"
echo "  Kotlin: $KOTLIN"
echo "  Gradle: $GRADLE"
echo "  Xcode: $XCODE"
echo "  iOS Target: $IOS_TARGET"
echo "  Custom Kotlin repo required: $CUSTOM_REPO_REQUIRED"
if [[ "$CUSTOM_REPO_REQUIRED" == "true" ]]; then
  echo "  Custom Kotlin repo URL: $CUSTOM_REPO_URL"
fi

# Files to update
FILES=(
  "SKILL.md"
  "MIGRATION_GUIDE.md"
  "README.md"
  "CLAUDE.md"
  "references/troubleshooting.md"
)

for file in "${FILES[@]}"; do
  if [[ -f "$file" ]]; then
    # Kotlin version (handles various patterns)
    sed -i '' -E "s/[0-9]+\.[0-9]+\.[0-9]+-titan-[0-9]+/$KOTLIN/g" "$file"

    # Gradle version in distribution URL
    sed -i '' -E "s/gradle-[0-9]+\.[0-9]+(\.[0-9]+)?-bin\.zip/gradle-$GRADLE-bin.zip/g" "$file"

    # Gradle version in requirements (e.g., "Gradle: 9.2.1+")
    sed -i '' -E "s/Gradle(:|\*\*:) [0-9]+\.[0-9]+(\.[0-9]+)?\+/Gradle\1 $GRADLE+/g" "$file"

    # Custom Kotlin repo URL (JetBrains Maven)
    if [[ "$CUSTOM_REPO_REQUIRED" == "true" ]]; then
      sed -i '' -E "s|https://packages\.jetbrains\.team/maven/p/kt/[a-z]+|$CUSTOM_REPO_URL|g" "$file"
    fi

    echo "  Updated: $file"
  fi
done

echo "Done! Review changes with: git diff"
