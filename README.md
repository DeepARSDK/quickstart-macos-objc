# quickstart-macos-objc

## Overview

This is an example app demonstrating DeepAR SDK.

- Preview of fun face filters, effects and background replacement.
- Carousel with filter thumbnails.
- Take screenshot.
- Source code demonstrates how to integrate DeepAR for iOS/MacOS in your app.

For more info on DeepAR for iOS/MacOS see: https://docs.deepar.ai/deepar-sdk/platforms/ios/overview

## How to run

1. Open the project in Xcode.
2. Create a DeepAR developer account: https://developer.deepar.ai/signup.
3. Create a project: https://developer.deepar.ai/projects.
4. Add a MacOS app to the project. Note that you need to specify the bundle id of your app. In this case it is "ai.deepar.quickstart-ios".
5. Copy the generated license key in the `ViewController.m` instead of your_license_key_here.


## Common issues
- If your Mac has an M1 chip you need to change the build target to My Mac (Rosetta).
- If the app keeps shutting down, this means you have some license key issue. Make sure you have properly setup the project on dev portal with correct bundle ID and copied the correct license key.
- In this example we have disabled library validation (Signing & Capabilities -> Hardened runtime). To distribute your app, you need to enable it and properly sign the DeepAR.xcframework.
