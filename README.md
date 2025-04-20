<h1 align="center">🏜️ DECODE™ Scorer 🔎</h1>

<h6 align="center">for iOS & iPadOS</h6>

<p align="center">
  The ultimate scorer, <b>redefined.</b>
  <br />
  presented by 20240 Slingshot
</p>


> ### 🚧 This project is in early development. Please check back for more information.

> ⚠️ This is the **development** branch. Please ensure you are on the right branch.

## Development

### Prerequisites

In order to develop the DECODE™ Scorer for iOS and iPadOS, you must have the following:

- A Mac computer running macOS Sequoia (version 15) or later
- Xcode 16 or later
- The latest iOS 18 platform support and simulator runtimes
  - (Optional) iOS 17.5 platform support simulator runtimes

Here's a [guide](https://gist.github.com/JiningLiu/59ce150600c781533736b41ca0615805) to install Xcode and platform support components.

### Project Setup

To get started, clone this repository, but **DO NOT** open it in Xcode yet.

In order to accomodate code-signing requirements, this project uses an [Xcode Configuration Settings File](https://developer.apple.com/documentation/xcode/adding-a-build-configuration-file-to-your-project) for setting the target development team and product bundle identifier.

Using a text editor or IDE that is **NOT Xcode**, open [`ExampleConfig.xcconfig`](./ExampleConfig.xcconfig) and change the placeholder values for each of the two keys with your project-specific values.

- `DEVELOPMENT_TEAM` refers to your Apple Developer Program Team ID, which you can find [here](https://developer.apple.com/account#MembershipDetailsCard).
- `PRODUCT_BUNDLE_IDENTIFIER` is a unique identifier used by the system for the application. Replace with the standard convention of a reversed domain (e.g. `decode.scorer.slingshot.example.com` ➡️ `com.example.slingshot.scorer.decode`). This should be unique to your project, avoid using `app.ftcscoring.decode` unless you know what you are doing.

Rename [`ExampleConfig.xcconfig`](./ExampleConfig.xcconfig) to `Config.xcconfig`, and open Xcode.

In the left sidebar, navigate to `DECODE (top-level .xcodeproj) > Targets > DECODE > Build Settings > All > Development Team`, single click (select) the line, and press `delete` (`backspace`) on your keyboard. Repeat for key `Product Bundle Identifier`

You're done! Head to the `Signing & Capabilities` section on the DECODE target page to make sure your development team and bundle identifier have been set correctly.

## Legal

### Disclaimer

This application is an independent project developed by FTC Team 20240 Slingshot and open-source contributors. It is not affiliated with, endorsed by, or officially connected to *FIRST*® (For Inspiration and Recognition of Science and Technology), the *FIRST*® Tech Challenge (FTC), Qualcomm, RTX (Raytheon Technologies), or any other sponsors, partners, or affiliates of these organizations.

All names, brands, and content referenced are the intellectual property of their respective owners. Their use in this application is solely for identification purposes and does not imply endorsement.

### Licenses

#### Third-party Software

[aptabase/aptabase-swift](https://github.com/aptabase/aptabase-swift) ([MIT License](https://github.com/aptabase/aptabase-swift/blob/main/LICENSE))

[kewlbear/NumPy-iOS](https://github.com/kewlbear/NumPy-iOS) ([MIT License](https://github.com/kewlbear/NumPy-iOS/blob/main/LICENSE))

[kewlbear/Python-iOS](https://github.com/kewlbear/Python-iOS) ([MIT License](https://github.com/kewlbear/Python-iOS/blob/kivy-ios/LICENSE))

[pvieito/PythonKit](https://github.com/pvieito/PythonKit) ([Apache License 2.0](https://github.com/pvieito/PythonKit/blob/master/LICENSE.txt))

[auth0/SimpleKeychain](https://github.com/auth0/SimpleKeychain) ([MIT License](https://github.com/auth0/SimpleKeychain/blob/master/LICENSE))

#### DECODE™ Scorer presented by 20240 Slingshot

Open source information to come. Planned release under the MIT License in Q3 2025.

© 2025 FTC Team 20240 Slingshot and contributors. All rights reserved until further notice.
