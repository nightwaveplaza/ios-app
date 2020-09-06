# iOS-hub

[![Build Status](https://travis-ci.org/Loud-Clear/ios-hub.svg?branch=master)](https://travis-ci.org/Loud-Clear/ios-hub)
[![codecov](https://codecov.io/gh/Loud-Clear/ios-hub/branch/master/graph/badge.svg)](https://codecov.io/gh/Loud-Clear/ios-hub)


See available pods in [ComponentsHub.podspec](https://github.com/Loud-Clear/ios-hub/blob/master/ComponentsHub.podspec).

## Useful shared iOS components:

- [gena](https://github.com/alexgarbarev/gena): everyone knows gena.  
`gem install gena`

- [mergeXcodeproj](https://github.com/ivanzoid/mergeXcodeproj): automatically merge .xcodeproj in case of git conflict. Also see [readme](https://github.com/ivanzoid/mergeXcodeproj) for configuration.  
`brew install ivanzoid/tap/merge-xcodeproj`

- [xc-resave](https://github.com/alexgarbarev/xc-resave):  
`brew install alexgarbarev/core/xc-resave`

- [viperModuleRename](https://github.com/ivanzoid/viperModuleRename): rename a VIPER module  
`brew install ivanzoid/tap/viper-module-rename`

- [prefixChange](https://github.com/ivanzoid/prefixChange): change prefix for a class  
`brew install ivanzoid/tap/prefixChange`


## News

2017-07-19

- `Observation`: added methods which accept array of keys; added method to unobserve an object
- `EnvironmentUI`: Refactored CCEnvironmentHUD to use `StatusBarHUD` component
- `StatusBarHUD`: introduced `StatusBarHUD` component which consists of `StatusBarHUD` and `CCAppVersionHUD` classes

2017-07-07

- Added `EnvironmentUI`
- Added `CCResendConnection`
- Added `CCValueTransformerDateRFC3339`
- Added `CCValidationErrorToBugfenderPostProcessor` which reports validation error as Bugfender issue

2017-06-30

- Added `RemoteNotificationService` component.
- `Macroses`: Added macroses for checking iOS version.

2017-06

- `Observation`: Bug fixes in NSObject+Observe.


2017-02-22

- `Table`: `CCTableViewManager` now has `.defaultSection` property which will create and add a default section when accessed first time.

