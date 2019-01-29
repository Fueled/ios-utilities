# FueledUtils

[![Documentation Badge](https://cdn.rawgit.com/Fueled/ios-utilities/master/docs/badge.svg)](https://cdn.rawgit.com/Fueled/ios-utilities/master/docs/index.html)

FueledUtils is a collection of utilities for iOS used often within project worked by [Fueled](https://fueled.com).

## Documentation

The documentation for project is available [here](https://cdn.rawgit.com/Fueled/ios-utilities/master/docs/index.html).

## Contributing

In order to properly clone the project and be ready to submit bug fixes/new features, please follow these steps:

1. Clone the project locally
2. Go to the repository, and using your favorite shell type:  

    ```swift
    git submodule update --init --recursive
    ```

    This will pull all the dependencies as they were checked out in git.
    Alternatively, if you have `carthage` installed, you may type:
    
    ```swift
    carthage bootstrap --use-submodules --no-build
    ```

3. Open `FueledUtils.xcworkspace`
4. You're ready to go!

## License

This project is licensed under the Apache License, Version 2.0.
