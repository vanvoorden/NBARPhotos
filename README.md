# Photos AR 0.1

This project demonstrates how the `NBARPhotosView` can be used to display any photos with location metadata in an AR space. We request permission to access the user photo library. The user can then choose to share photos and view them in AR at the same coordinates where the photo was geo-tagged.

For best results, the photos should have been taken outdoors with GPS and Wifi enabled for an accurate location. Photos that have been imported to photo library should also draw correctly in AR if they have location metadata saved.

## Requirements

This project requires Xcode 12.5 or later. The following device requirements apply:

* ARKit
* arm64
* GPS
* A12 Bionic and Later Chips
* Location Services
* iOS 14.0 or later

## Known Issues

* There is no UI if the user chooses to view a photo with invalid location metadata. The operation will fail silently. If the user chooses multiple photos from the picker, only the photos with valid location metadata will draw in AR.
* Launching the app, loading photos in AR, backgrounding the app for a long period of time, and activating the app back to the foreground can cause the previously loaded photos to disappear. Reloading the photos from the photo picker should place them back in AR space correctly.
