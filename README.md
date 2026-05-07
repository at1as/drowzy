# Drowzy

Drowzy is a small macOS menu bar app for keeping your Mac awake. It is built for the "Keeping You Awake, but with timed choices" use case: click the menu bar icon, choose `On Until Turned Off`, or delay idle sleep for `10 Minutes`, `30 Minutes`, `1 Hour`, `2 Hours`, or `5 Hours`.

The app uses a macOS IOKit no-idle-sleep assertion. It does not install a helper, run a daemon, collect analytics, or send network traffic.

## Motivation

Sometimes a local task, long-running build, download, render, or coding agent just needs a few more minutes to finish. The usual choices are too blunt: let the Mac sleep and risk interrupting the work, or keep it awake indefinitely and possibly leave it running all night.

Drowzy exists for the middle case. It gives you a quick menu bar control for delaying idle sleep for a bounded amount of time, while still keeping the simple always-on option available when you actually need it.

## Features

- Menu bar only interface with no Dock icon.
- Off, indefinite on, and timed sleep delay modes.
- Timed modes automatically release the power assertion when the selected duration expires.
- Native AppKit implementation with no runtime dependencies.
- SwiftPM build, focused unit tests, CI, and release packaging scripts.

## Requirements

- macOS 12 Monterey or newer to run the packaged app.
- Xcode 15.4 or Swift 5.10 to build from source.

## Build

```sh
make test
make app
```

The app bundle is written to:

```text
.build/Drowzy.app
```

## Run The App

After building the app, launch it with:

```sh
open .build/Drowzy.app
```

Drowzy runs as a menu bar app, so it does not show a Dock icon. Look for the Drowzy icon in the macOS menu bar.

## Install Locally

```sh
make install
```

By default this copies the app to `/Applications/Drowzy.app`. To install somewhere else:

```sh
DESTINATION="$HOME/Applications" make install
```

## Package A Release

```sh
make package
```

This creates:

```text
.build/dist/Drowzy-0.1.0-macos.zip
.build/dist/Drowzy-0.1.0-macos.zip.sha256
```

For a universal Apple Silicon and Intel build:

```sh
UNIVERSAL=1 make package
```

For Developer ID signing:

```sh
CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" make package
```

Unsigned or ad-hoc signed builds may trigger Gatekeeper warnings when shared outside your own Mac. For a public release, sign with a Developer ID certificate and notarize the zip or app bundle before publishing.

## Release Flow

1. Update `VERSION`.
2. Run `make test` and `make package`.
3. Create and push a tag, for example `v0.1.0`.
4. The release workflow packages the app and attaches the zip plus checksum to the GitHub release.

## How It Works

Selecting an active mode creates a `kIOPMAssertionTypeNoIdleSleep` assertion through IOKit. Selecting `Off`, quitting the app, or reaching a timed mode's expiration releases that assertion.

## License

MIT. See [LICENSE](LICENSE).
