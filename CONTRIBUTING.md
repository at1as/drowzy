# Contributing

Thanks for helping improve Drowzy.

## Development

```sh
make test
make app
```

Keep changes small and focused. The sleep assertion behavior lives in `Sources/DrowzyCore`; the menu bar UI lives in `Sources/Drowzy`.

## Pull Requests

- Include tests for changes in `DrowzyCore`.
- Run `make test` before opening a PR.
- Update `README.md` when changing install, package, or user-facing behavior.

## Release Checklist

- Update `VERSION`.
- Update `CHANGELOG.md`.
- Run `make test`.
- Run `make package`.
- Push a `vX.Y.Z` tag.
