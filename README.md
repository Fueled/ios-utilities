# FueledUtils

<div align="center">
  <img src="hero.jpg" alt="FueledUtils" width="800"/>
</div>

![PR Check](https://github.com/Fueled/ios-utilities/actions/workflows/pr_check.yml/badge.svg)
![Latest Version](https://img.shields.io/github/v/tag/Fueled/ios-utilities?label=version&sort=semver)

FueledUtils is a collection of utilities for iOS used often within projects at [Fueled](https://fueled.com).

## Documentation

Documentation is available [here](https://fueled.github.io/ios-utilities/).

### Generating Documentation Locally

To generate the documentation locally using Swift-DocC:

```bash
./docs-script.sh
```

This will generate the documentation in the `./docs` directory. Open `./docs/index.html` in your browser to view it.

**Requirements:**
- Swift 6.0+ (Swift-DocC is included)
- `jq` (for parsing Package.swift): `brew install jq`

## Contributing

If you'd like to contribute to the project, please familiarise yourself with [CONTRIBUTING.md](CONTRIBUTING.md) before creating an issue or a pull request.

## License

This project is licensed under the Apache License, Version 2.0.
