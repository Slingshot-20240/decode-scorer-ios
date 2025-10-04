# 🏜️ iOS DECODE™ Scorer 🔎

The ultimate scorer, **redefined**.  
presented by **20240 Slingshot**

> [!NOTE]
> 🚧 This project is in early development. Please check back for more information.

> [!WARNING]
> This is the **development** branch. Please ensure you are on the right branch.

## Development

### Prerequisites

In order to develop the DECODE Scorer for iOS, you must have the following:

- A Mac computer running macOS Sequoia 15.5 or later
- Xcode 26 or later
- The latest iOS 26 and iOS 18 platform support and simulator runtimes
  - (Optional) iOS 17.5 platform support and simulator runtimes

Here's a [guide](https://gist.github.com/JiningLiu/59ce150600c781533736b41ca0615805) to install Xcode and platform support components.

### Project Setup

To get started, clone this repository, but **DO NOT** open it in Xcode yet.

In order to accomodate code-signing requirements, this project uses an [Xcode Configuration Settings File](https://developer.apple.com/documentation/xcode/adding-a-build-configuration-file-to-your-project) for setting the target development team and product bundle identifier.

Using a text editor or IDE that is **NOT Xcode**, open [`ExampleConfig.xcconfig`](./ExampleConfig.xcconfig) and add the required project-specific values for each of the two keys.

- `DEVELOPMENT_TEAM` refers to your Apple Developer Program Team ID, which you can find [here](https://developer.apple.com/account#MembershipDetailsCard).
- `PRODUCT_BUNDLE_IDENTIFIER` is a unique identifier used by the system for the application. Replace with the standard convention of a reversed domain (e.g. `decode.scorer.slingshot.example.com` ➡️ `com.example.slingshot.scorer.decode`). This should be unique to your project, avoid using `app.ftcscoring.decode` unless you know what you are doing.

Make a copy of [`ExampleConfig.xcconfig`](./ExampleConfig.xcconfig) and rename it to `Config.xcconfig`, and open Xcode.

In the left sidebar, navigate to `DECODE (top-level .xcodeproj) > Targets > DECODE > Build Settings > All > Development Team`, single click (select) the line, and press `delete` (`backspace`) on your keyboard. Repeat for key `Product Bundle Identifier`

> [!CAUTION]
> **NEVER** update your development team or bundle identifier in the Xcode GUI, **only** use the `Config.xcconfig` file to avoid pushing your project-specific configuration to GitHub. 

Head to the `Signing & Capabilities` section on the DECODE target page to make sure your development team and bundle identifier have been set correctly.

After configuring code signing, make a copy of [`ExampleEnv.swift`](./ExampleEnv.swift) and rename it to `Env.swift`.

If you would like to setup Aptabase analytics, fill in your Aptabase App Key. For more information, visit https://aptabase.com/.

If you would not like to use analytics, simply leave the value blank. 

In Xcode, go to `File > Add Files to "DECODE"...` and select the `Env.swift` file. Make sure to select the "Move files to destination" action and confirm that the "DECODE" target is selected.

That's it! You are now good to go.

## Legal

[Privacy Policy](https://ftcscoring.app/privacy) | [Terms & Conditions](https://ftcscoring.app/terms)

### Disclaimer

*FIRST*®, *FIRST*® Tech Challenge, FTC®, *FIRST*® AGE™, DECODE™, and all accompanying logos as they are created, are trademarks of For Inspiration and Recognition of Science and Technology (*FIRST*®) (www.firstinspires.org). These trademarks are used by special permission of *FIRST* which is not overseeing, involved with, or responsible for this activity, product, or service. © 2025 *FIRST*®. Used by special permission. All rights reserved.

### Licenses

#### Third-party Software

[aptabase/aptabase-swift](https://github.com/aptabase/aptabase-swift) ([MIT License](https://github.com/aptabase/aptabase-swift/blob/main/LICENSE))

[kewlbear/NumPy-iOS](https://github.com/kewlbear/NumPy-iOS) ([MIT License](https://github.com/kewlbear/NumPy-iOS/blob/main/LICENSE))

[kewlbear/Python-iOS](https://github.com/kewlbear/Python-iOS) ([MIT License](https://github.com/kewlbear/Python-iOS/blob/kivy-ios/LICENSE))

[pvieito/PythonKit](https://github.com/pvieito/PythonKit) ([Apache License 2.0](https://github.com/pvieito/PythonKit/blob/master/LICENSE.txt))

#### Slingshot Open Source Software

[Slingshot-20240/swiftc](https://github.com/Slingshot-20240/swiftc) ([MIT License](https://github.com/Slingshot-20240/swiftc/blob/dev/LICENSE))

#### DECODE Scorer presented by 20240 Slingshot

© 2025 FTC Team 20240 Slingshot and contributors. [MIT License](https://github.com/Slingshot-20240/decode-scorer-ios/blob/release/LICENSE).
