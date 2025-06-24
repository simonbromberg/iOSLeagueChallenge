# LeagueiOSChallenge

*Project Author*: Simon Bromberg (bshimmy@gmail.com)
*Submitted*: February 13, 2025

## System Requirements

* Used Xcode Version 16.2, macOS Sequoia 15.3 (recent older versions of Xcode are untested, but would probably work).
* I modified the base iOS version in the starter project to 16. I assume this is fine, but it would not be difficult to change it back to 15 if needed.

## Assumptions

* The instructions say to validate the domain extension of the email address on the user page. I am assuming the rest of the email string is expected to be valid, so I am only checking the domain there.

## Architecture

* For a new iOS app, I'd be inclined to use mainly SwiftUI. However, in this case I focused on UIKit because the challenge doc mentioned that's what League mainly uses.
* While I am comfortable using Storyboards for building UIs, and it has its advantages in terms of reducing repetitive lines of code for setting styles and constraints, and a convenient GUI for making interface changes, I chose to define the relatively simple interface for this app fully in code:
  * Storyboard files are difficult to manage when merging conflicting changes together, even if you follow good practices and split the UI up into multiple Storyboards.
  * Storyboard changes are more difficult to review in PRs.
  * Also, it was more interesting for me to try to do everything in code for this challenge, while keeping it readable and avoiding repetition.

### `PostsViewController`
* The `PostsViewController` separates its interaction with the API into a view model. The view model manipulates user posts and user response data as well as images into what the `PostsViewController` needs for displaying content. The view model also handles the log out and the transition to the user view. 
  * This is MVVM-inspired, simplified for the sake of this challenge.
* I used a diffable data source on the table view so that updates to the data would reload more seamlessly. Plus it's a newer more interesting part of the SDK that I wanted more practice with.
  * When images are needed in the table view, the table view data source tries to get them from the view model. The view model keeps some images in memory for quick loading, and if it doesn't have the image it returns a placeholder and then asks for the image from the API helper (which has its internal cahcing mechanism to skip repetitively downloading the same images).
  * The image cache takes advantage of the fact that the post list contains the same image multiple times because the user profile images are repeated.
  * When an image is retrieved, regardless of whether it was downloaded or retrieved from the file system, it updates an `imageLoaded` flag in the corresponding post in the array and triggers the data source to reload. This takes advantage of the efficiencies in the `UITableViewDiffableDataSource` which uses hashing to only apply updates where data has changed.      

### `UserView`
* I opted to build this standalone view in SwiftUI to showcase my skills and as a contrast to the more verbose UIKit code. Plus it's just a lot faster to implement and adjust.

### `APIService` / `APIHelper`
* `APIHelper` provides all the required API functionality and handles loading images
  * Images are cached in the app's document directory based on the image's URL. This speeds the UI up considerably, especially since the posts list reuses the same image multiple times. 
  * The `APIHelper` is an implementation of the `APIService` protocol. An `APIService` can be injected into the initializers of the various controllers / views. This could be swapped out for the mock service as needed to debug the app or run tests independent of the remote server. 
* I have included a basic mock API service that could be used to help debug the app, support additional unit tests, or be hooked up during UI tests to focus on testing the actual app without external dependencies on the API.

## Tests

I have included some simple unit tests and even a brief UI test that runs through the login as user, opening a user on a post, existing, and logging out.

* Note: the UI test is using the real API by default, so mileage may vary on different network connections / machines. You can swap it use the mock API service by changing the API service passed to `LoginViewController` in `SceneDelegate`. In a production app one might set up the build configuration for UI tests to do this automatically.
* The `JSONDecodingTests` ensure that the decoding of response models based on the expected output from the API is working properly, using the mock API helper.
* The `EmailValidationTests` provide checks for the utility that determines whether to show the warning label next to the email on the user screen.
* `PostsViewModelTests` run through data loading and log out handling using the mock API.
 
## Future Improvements

* I set up a placeholder `CredentialStore` for storing the API key / user state. This should be updated to use the iOS Keychain to securely store the API key. I would not bother writing this from scratch as it is relatively complicated and there are plenty of easy to use third-party wrappers for the keychain.
* It'd be better to keep track of the least recently used images for both the in-memory and on-disk image caching so that unused images can be cleared out. iOS can automatically clear the `cachesDirectory` but in a real app one would want to be more proactive about overusing storage.
* The flow between the login screen and the app is fairly basic for the purposes of this challenge. Instead, the root view of the window could be swapped out when logging in / out instead of presenting the main app on top of the login view.
* The basic mock API service could be improved with (optional) simulated delays, larger / more realistic JSON fixtures / more test images.
* Lots of opportunities for polishing the UI, such as adding highlighting when the avatar / username is tapped on a post or improving the design of the login screen. I set things up to make it easy to make simple design changes, such as modifying the colour palette (for both default and dark mode) or swapping out placeholder images.
* While most of the app works fine when the device is in landscape, the login view does not handle the keyboard properly and the content gets squished. So I disabled the landscape orientation across the app. The login view content could be put in a scroll view to get it working, though most social media apps do not bother supporting landscape orientations on iPhones. The app was also built on an iPhone simulator; adjustments would need to be made to improve the experience on iPads.  
* User-facing strings should be collected together in a localization for easier translation / editing.
* Add more UI tests and better handle different app states / waiting for components to load. 

