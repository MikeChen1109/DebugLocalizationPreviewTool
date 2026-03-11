# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project follows Semantic Versioning.

## [Unreleased]

## [0.1.0] - 2026-03-11

### Added
- Initial public baseline for the DebugLocalization package.
- `DebugLocalizationCore` with async localization provider abstractions and `DebugLocalizer`.
- Built-in provider modes for passthrough, pseudo-localization, and mock translation flows.
- `DebugLocalizationTranslationSupport` with Apple Translation integration for supported iOS configurations.
- Translation preparation coordination for checking and downloading language resources before translation.
- Public runtime version constant via `DebugLocalizationVersion.current`.
