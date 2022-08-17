
# Contributing to FueledUtils

## Setup

In order to properly clone the project and be ready to submit bug fixes/new features, please follow these steps:

1. Clone the project using 
    ```shell
    git clone --recurse-submodules https://github.com/Fueled/ios-utilities.git
    ```
    This will initialize all dependencies.

    If you've already cloned the project without initializing submodules, please run submodules update from the project directory:

    ```shell
    git submodule update --init --recursive
    ```
2. Open `Test/FueledUtils.xcworkspace` and update the *FueledUtils* Pod in `Development Pods`
3. You're ready to go!

## How to contribute

You can contribute by:
1. Reporting bugs
2. Enhance the existing features
3. Introduce new features

Fueled team will generally accept bugs fixes, and discuss the benefits of integrating new features and enhancements within the codebase.

## Guidelines

1. All code must conform to [Fueled Swift style guide](https://github.com/Fueled/swift-style-guide). This conformance is largely ensured by our [swiftlint](https://github.com/Fueled/swiftlint-yml/blob/master/.swiftlint.yml) configuration.
2. Additionally, all public and open constructs must be documented unless their meaning is determined clearly and unambiguousy by types and naming.

### Commit style

We're using semantic commit messages at all times when writing commit messages.
Our semantic commit message format involves 4 distinct parts (1 is optional)

1. A type
2. A scope
3. A short description
4. A long description

The general format is:
```
<type>(<scope>): <short description>

<long description>
```

The type may be one of:

- `feat`: a new feature
- `fix`: a bug fix
- `perf`: performance enhancement
- `docs`: documentation update
- `refactor`: code refactoring
- `test`: add/change/remove unit tests
- `style`: style change (update indentation, change spaces to tabs, …)
- `chore`: configuration update, code signing change, …

The scope must reference what part of the library was changed, and can be made specific using slashes, for example `reactive/swift-extensions`. The scope can also reference one or multiple GitHub issues.  
The short description must describe in as few words as possible what the commit does. It must be written in imperative tense and can reference a GitHub issue.  
The long description may go further into explaining why some changes were necessary (e.g. if a feature is done through a refactoring).  

For example, you may do something like:
```shell
git commit \
    -m "fix(reactive/ui-extensions/#123,#124): fix issue in SignalProducer.minimum sometimes triggered before the interval elapses" \ # The type, scope + short description
    -m "This issue works around an internal issue in iOS." # The long description
```

You can find more info on our commit format and its purpose [in this Medium article](https://medium.com/fueled-engineering/automated-changelog-generation-at-fueled-1c06306f3b06).
