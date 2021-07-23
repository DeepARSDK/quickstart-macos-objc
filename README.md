# quickstart-macos-objc

To run the example
* Go to https://developer.deepar.ai, sign up, create your project and an MacOS app within it. Copy the license key and paste it to ViewController.m (instead of your_license_key_goes_here string)
* Download the SDK from https://developer.deepar.ai and copy the DeepAR.framework into quickstart-macos-objc folder. Make sure the DeepAR.framework is aded to the xCode project - it must be visible in the xCode file explorer.
* In the quickstart-macos-objc project settings, tab General, section Frameworks, Libraries, and Embedded Content must have DeepAR.framework entry with Embed & Sign option selected 

Common issues
* If your mac has an M1 chip you need to change the build target to My Mac (Rosetta)
* If your build fails with a cycle error you need to use the chenge the build system to Legacy build system in File->Project/Workspace settings
