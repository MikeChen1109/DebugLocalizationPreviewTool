# DebugLocalization

Debug localization helpers and translation support for iOS apps.

## Install with Swift Package Manager

In Xcode, add this repository as a package dependency:

```text
https://github.com/MikeChen1109/DebugLocalizationPreviewTool.git
```

Products:

- `DebugLocalizationCore`
- `DebugLocalizationTranslationSupport`

## Repository Layout

- `Package.swift`: root package manifest for SPM consumers
- `frameworks/DebugLocalizationPackage/`: package source and tests
- `DebugLocalizationDemo/`: demo app for local development

## Notes

The package manifest is intentionally placed at the repository root so other developers can add the package directly from GitHub.
