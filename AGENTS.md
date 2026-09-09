# AGENTS.md

Guidance for AI coding agents (Claude, Codex, and others) and human
contributors working in this repository. Read this before making changes.

This file covers **this repository**: what it is, how to build and test it, how
it is laid out, and what will bite you. How work reaches it — which task an
agent picks up, when a task is ready, branch and pull request conventions, and
what happens after review — lives in
[`laugga/ops`](https://github.com/laugga/ops), which serves every repository
and is where those rules are changed.

## What this is

**HorizontalPicker** is a horizontal *spinning-wheel* picker view for iOS —
`LAUPickerView`, the same idea as `UIPickerView` but with columns running
left to right instead of rows running top to bottom. It follows
`UIPickerView`'s data source and delegate semantics.

Pure Swift, UIKit, iOS 13.0 or later. No Objective-C and no `@objc` anywhere in
the interface: `LAUPickerViewDataSource` and `LAUPickerViewDelegate` are plain
Swift protocols, so an adopting type does not have to be an `NSObject`
subclass. It has no dependencies.

**What depends on it.** [`laugga/lightmate-app-ios`](https://github.com/laugga/lightmate-app-ios)
— the Lightmate iOS app — is the one consumer. It takes this package as a
remote Swift Package Manager dependency and draws its exposure-value picker
with it (`Sources/LightmateViewController.swift`,
`Sources/Views/ExposureValuePickerView/`). It tracks the `main` **branch**, not
a version tag; read the gotchas below before changing public API.

This repository is **public**. Its only consumer is private. Nothing
Lightmate-specific, and nothing secret, belongs in here.

## Build and test

**`Package.swift` is the authoritative build.** It defines the `HorizontalPicker`
library target and the `HorizontalPickerTests` test target, and it is what
consumers resolve. Every change to the library is built and tested through it.

The package is UIKit-only, so it is built against an iOS simulator with
`xcodebuild` rather than with `swift build`. Run these from the repository root:

```bash
# Build the library
xcodebuild -scheme HorizontalPicker -destination 'generic/platform=iOS Simulator' build

# Run the 27 unit tests
xcodebuild test -scheme HorizontalPicker -destination 'platform=iOS Simulator,name=iPhone 17'
```

There is no `.xcodeproj` for the library and none is needed — `xcodebuild`
builds `Package.swift` directly through an implicit workspace. Substitute any
installed simulator for `iPhone 17`; check with
`xcrun simctl list devices available`.

**`Example/HorizontalPicker.xcodeproj` is the other build system, and it builds
only the example app.** It is not an alternative way to build the library: it
depends on the repository root as a *local* Swift package (`XCLocalSwiftPackageReference ".."`),
so it compiles whatever is in the working tree through the same `Package.swift`.
It exists so a change can be seen working by hand.

```bash
xcodebuild -project Example/HorizontalPicker.xcodeproj -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

The example is a catalog: thirteen scenarios in six sections, each opening a
working screen. `Catalog.swift` is the index; each scenario is a
`ScenarioViewController` subclass that builds and configures its own picker
through the public API only. Add a scenario by adding the view controller under
`Example/HorizontalPicker/Scenarios/<Section>/` and an entry in `Catalog.swift`;
nothing else is wired by hand.

**There is no lint step.** No SwiftLint, no SwiftFormat, no `.editorconfig` —
match the surrounding file instead.

**There is no CI.** No GitHub Actions workflows exist and no status check runs
on a pull request. The commands above are the whole gate; run them yourself.
`.travis.yml` is dormant — Travis is not connected to this repository.

## Project layout

| Path | What's there |
|---|---|
| `Package.swift` | The authoritative manifest. Library target `HorizontalPicker`, test target `HorizontalPickerTests`, iOS 13 platform, `resources/tick.caf` declared as a copied resource. |
| `Sources/HorizontalPicker/` | The library. `LAUPickerView` is the public view; `LAUPickerViewDataSource` / `LAUPickerViewDelegate` are the public protocols; `LAUPickerSelectionAlignment` the public enum. Everything else (`LAUPickerTableView`, `LAUPickerColumnLayout`, `LAUPickerColumnCell`, `LAUPickerTouchGestureRecognizer`, `LAUPickerTableInputSound`, `LAUPickerViewLabel`) is internal. |
| `Sources/HorizontalPicker/resources/` | `tick.caf`, the click-input sound, loaded through `Bundle.module`. |
| `Tests/HorizontalPickerTests/` | XCTest unit tests covering the data source and delegate contract, selection, reloading, layout, hidden column states, selection geometry, column recycling and scroll snapping. |
| `Example/` | The example app and its Xcode project. `App/` is the entry point, `Catalog/` the index of scenarios, `Scenarios/` the scenarios themselves, `Resources/` the asset catalog. |
| `docs/` | `figures/` holds the README screenshots. `features.md` is a stale wishlist, not a description of what exists — see the gotchas. |
| `scripts/`, `support/` | Dead. Left over from the pre-SPM framework build — see the gotchas. |
| `CHANGELOG.md` | Hand-written, newest first, grouped under `Features:` / `Improvements:` / `Fixed:` / `Removed:` / `Other:`. Add an entry for anything a consumer would notice. |

## Conventions

Branch names, pull request titles and bodies, and how a pull request references
its task are the same in every Laugga Practice repository and are documented in
[`laugga/ops`](https://github.com/laugga/ops). What is specific to this
repository:

- **The default and integration branch is `main`.** Open pull requests against
  it. (Lightmate uses `development`; this repository does not.)
- **Commit subjects read `Type / Description`** — the same shape as the pull
  request title: `Fix / Blank columns when a delegate-supplied column view is
  recycled`, `Refactor / Rewrite the horizontal picker in Swift`.
- **Type names carry the `LAUPicker` prefix; the module is `HorizontalPicker`.**
  The two do not match and that is deliberate — consumers write
  `import HorizontalPicker` and then use `LAUPickerView`. Keep new types on the
  existing prefix rather than renaming toward the module.
- **Every file in `Sources/` opens with the MIT-style license header block**
  carrying the file name and `HorizontalPicker`. Copy it into new files.
  `Tests/` and `Example/` use the short four-line Xcode header instead.
- **Public API is documented with `///` doc comments.** The protocols say what
  each method returns and what the default does when it is not implemented.
- **Delegate methods have default implementations**, not `@objc optional`
  requirements. A new optional delegate method needs a default in the protocol
  extension, or it becomes a source-breaking change for every consumer.

## Gotchas

- **`swift build` and `swift test` do not work.** They target macOS and the
  sources are UIKit-only, so they fail with `error: no such module 'UIKit'`.
  This is expected, not a broken checkout. Always go through `xcodebuild` with
  an iOS Simulator destination.

- **Lightmate tracks the `main` branch, not a tag.** `lightmate-app-ios`
  declares this package as `requirement = { branch = main; kind = branch; }`,
  so anything merged here reaches the app the next time it resolves packages —
  there is no version gate in between. Treat a change to the public API as a
  change to the app, and say so in the pull request.

- **Lightmate has not caught up with the Swift rewrite yet.** Its
  `Package.resolved` pins revision `0c3059e`, the last commit before
  `616808a Refactor / Rewrite the horizontal picker in Swift`. Its call sites
  still use the Objective-C-bridged signatures (`pickerView: LAUPickerView!`,
  `-> String!`), which do not satisfy the current pure-Swift protocols. Its
  next package resolve will not compile until those signatures are updated.
  Do not assume the app builds against `main` today.

- **The version tags are behind the CHANGELOG.** `0.3.0` is the newest tag and
  it points at `31f828f`, thirteen commits back, *before* the Swift rewrite —
  even though `CHANGELOG.md` files the rewrite under 0.3.0 and there is a 0.4.0
  section with no tag at all. So the README's
  `.package(url: ..., from: "0.3.0")` resolves to the old Objective-C code, not
  to the Swift API the README goes on to document. Don't trust a tag to mean
  what the CHANGELOG says it means, and don't create one to tidy this up
  without being asked — Lightmate is on `main` and would not notice either way.

- **This repository is public; `lightmate-app-ios`'s own `AGENTS.md` says it is
  private.** That is wrong (`gh repo view laugga/HorizontalPicker` reports
  `PUBLIC`), and only `laugga/LightmateUI` in that list actually is private.
  Nothing here needs GitHub credentials to resolve. The remote is configured
  over SSH (`git@github.com:laugga/HorizontalPicker.git`) for pushing, which is
  a separate matter from how consumers fetch it — Lightmate fetches over HTTPS.

- **`scripts/` and `support/` are dead.** `build_framework.sh`,
  `copy_framework_headers.sh`, `copy_framework_resources.sh`,
  `embed_framework_resources.sh`, `update_bundle_version.sh` and
  `LAUPickerView-Info.plist` were build phases of the hand-rolled `.framework`
  target in `LAUPickerView.xcodeproj`, which was removed in 0.3.0. Nothing
  invokes them and nothing reads that plist. Don't wire them into anything;
  don't treat the plist's `0.1.0` as the package version.

- **`docs/features.md` is a wishlist.** It lists a vertical and a circular
  picker view. Neither exists. Only the horizontal one does.

- **Resources go through `Bundle.module`.** `tick.caf` is declared in
  `Package.swift` as `.copy("resources/tick.caf")`. A new resource that is not
  added to that array is silently absent at runtime.

- **The example targets iOS 17, the package targets iOS 13.** The example
  compiling is not evidence that an API you used is available to the package's
  own deployment target. The library build is what settles that.

## Definition of done

Before opening a pull request, confirm:

- [ ] `xcodebuild -scheme HorizontalPicker -destination 'generic/platform=iOS Simulator' build` succeeds
- [ ] `xcodebuild test -scheme HorizontalPicker -destination 'platform=iOS Simulator,name=iPhone 17'` passes
- [ ] The example still builds, if you touched anything it uses
- [ ] `CHANGELOG.md` has an entry, if a consumer would notice the change
- [ ] Public API changes are called out in the pull request — Lightmate is on `main`
- [ ] No unintended churn is committed
