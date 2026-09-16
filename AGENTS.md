# AGENTS.md

## What this is

**HorizontalPicker** is a horizontal *spinning-wheel* picker view for iOS —
`LAUPickerView`, the same idea as `UIPickerView` but with columns running
left to right instead of rows running top to bottom. It follows
`UIPickerView`'s data source and delegate semantics.

Pure Swift, UIKit, iOS 13.0 or later. No Objective-C and no `@objc` anywhere in
the interface: `LAUPickerViewDataSource` and `LAUPickerViewDelegate` are plain
Swift protocols, so an adopting type does not have to be an `NSObject`
subclass. It has no dependencies.

The repository is public and self-contained. Consumers resolve it as a remote
Swift Package Manager dependency, and a consumer may track the `main` branch
rather than a version tag — so treat a change to the public API as reaching an
app with no version gate in between, and say so in the pull request.

## Build and test the library

**`Package.swift` is the authoritative build.** It defines the `HorizontalPicker`
library target and the `HorizontalPickerTests` test target, and it is what
consumers resolve. Every change to the library is built and tested through it.

The package is UIKit-only, so it is built against an iOS simulator with
`xcodebuild` rather than with `swift build`. The root `Makefile` wraps both:

```bash
make build   # xcodebuild build -scheme HorizontalPicker -destination 'generic/platform=iOS Simulator'
make test    # xcodebuild test -scheme HorizontalPicker on the newest available iPhone simulator
```

There is no `.xcodeproj` for the library and none is needed — `xcodebuild`
builds `Package.swift` directly through an implicit workspace. `make test`
picks the newest installed iPhone simulator automatically; override it with
`TEST_DEVICE=` or `TEST_DEST=`, and check what's installed with
`xcrun simctl list devices available`.

**There is no lint step.** No SwiftLint, no SwiftFormat, no `.editorconfig` —
match the surrounding file instead.

**CI gates the merge.** `.github/workflows/ci.yml` runs `make build` and
`make test` on `macos-latest` for every pull request into `main`, and a human
cannot merge without it passing. Xcode Cloud isn't an option here: it needs an
app or framework target in an Xcode project, and this SwiftPM package has
neither.

## Build and run the example app

`Example/HorizontalPicker.xcodeproj` builds **only the example app**. It is not
an alternative way to build the library: it depends on the repository root as a
*local* Swift package (`XCLocalSwiftPackageReference ".."`), so it compiles
whatever is in the working tree through the same `Package.swift`. It exists so
a change can be seen working by hand.

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

**The example app is kept in step with the library, always.** A change to the
library is not finished until the example reflects it:

- **New public API** — a property, a delegate method, a selection mode — gets a
  scenario that exercises it, or is folded into an existing scenario where one
  already fits. An addition nobody can see running is not covered.
- **Changed public API** — every call site in `Example/` is updated to the new
  shape in the same pull request. The example must compile against the working
  tree, not against the previous release.
- **Removed public API** — the scenarios that used it go with it.
- **A fixed bug** gets a scenario under `Scenarios/Regressions/` that shows the
  behaviour it fixed, so the next change can be checked against it by hand.

The example targets iOS 17 while the package targets iOS 13, so the example
compiling is *not* evidence that an API you used is available to the package's
own deployment target — see the gotchas.

## Project layout

| Path | What's there |
|---|---|
| `Package.swift` | The authoritative manifest. Library target `HorizontalPicker`, test target `HorizontalPickerTests`, iOS 13 platform, `resources/tick.caf` declared as a copied resource. |
| `Sources/HorizontalPicker/` | The library. `LAUPickerView` is the picker; `LAUPickerViewDataSource` / `LAUPickerViewDelegate` the protocols a consumer adopts; `LAUPickerSelectionAlignment` the selection position. `LAUPickerTableView` (one component) and its own data source and delegate protocols, `LAUPickerViewLabel` and `LAUPickerTableInputSound` are public too, but they are the picker's internals — a consumer is not meant to reach for them. `LAUPickerColumnLayout`, `LAUPickerColumnCell` and `LAUPickerTouchGestureRecognizer` are internal. |
| `Sources/HorizontalPicker/resources/` | `tick.caf`, the click-input sound, loaded through `Bundle.module`. |
| `Tests/HorizontalPickerTests/` | XCTest unit tests covering the data source and delegate contract, selection, reloading, layout, hidden column states, selection geometry, column recycling and scroll snapping. |
| `Example/` | The example app and its Xcode project. `App/` is the entry point, `Catalog/` the index of scenarios, `Scenarios/` the scenarios themselves, `Resources/` the asset catalog. |
| `Docs/figures/` | The screenshots the README displays. Regenerate the example screenshot when the example's appearance changes. |
| `CHANGELOG.md` | Hand-written, newest first, grouped under `Features:` / `Improvements:` / `Fixed:` / `Removed:` / `Other:`. Add an entry for anything a consumer would notice. |

## Conventions

Branch names, pull request titles and bodies, and how a pull request references
its task are the same in every Laugga Practice repository and are documented in
[`laugga/ops`](https://github.com/laugga/ops). What is specific to this
repository:

- **The default and integration branch is `main`.** Open pull requests against
  it.
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

- **The example targets iOS 17, the package targets iOS 13.** The example
  compiling is not evidence that an API you used is available to the package's
  own deployment target. The library build is what settles that.

- **Resources go through `Bundle.module`.** `tick.caf` is declared in
  `Package.swift` as `.copy("resources/tick.caf")`. A new resource that is not
  added to that array is silently absent at runtime.

- **The version tags are behind the CHANGELOG.** `0.3.0` is the newest tag and
  it points at `31f828f`, *before* the Swift rewrite, even though
  `CHANGELOG.md` files the rewrite under 0.3.0; the top section of the
  CHANGELOG, `1.0.0`, has no tag yet. Don't trust a tag to mean what the
  CHANGELOG says it means, and don't create one without being asked.

- **`LAUPickerView` is public but not the whole public surface.** `xcodebuild`
  will happily let you use `LAUPickerTableView` or `LAUPickerViewLabel` from
  outside the module; they are public for the picker's own composition, not as
  API. Build against `LAUPickerView` and its two protocols.

## Definition of done

Before opening a pull request, confirm:

- [ ] `make build` succeeds
- [ ] `make test` passes
- [ ] The example app builds, and covers whatever the library gained, lost or changed
- [ ] `CHANGELOG.md` has an entry, if a consumer would notice the change
- [ ] Public API changes are called out in the pull request — a consumer may be tracking `main`
- [ ] The README still matches the code, and its screenshots still match the example
- [ ] No unintended churn is committed
