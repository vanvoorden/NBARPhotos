# Photos AR 1.0

This project demonstrates how the `NBARPhotosView` can be used to display any photos with location metadata in an AR space. We request permission to access the user photo library. The user can then choose to share photos and view them in AR at the same coordinates where the photo was geo-tagged.

For best results, the photos should have been taken outdoors with GPS and Wifi enabled for an accurate location. Photos that have been imported to photo library should also draw correctly in AR if they have location metadata saved.

## Requirements

This project requires Xcode 15.4 or later. The following device requirements apply:

* ARKit
* arm64
* GPS
* A12 Bionic and Later Chips
* Location Services
* iOS 14.0 or later

The location data required to place photos is limited to specific areas supported by Apple. Reference the [ARGeoTrackingConfiguration](https://developer.apple.com/documentation/arkit/argeotrackingconfiguration) documentation before placing photos in your location.

## Known Issues

* There is no UI if the user chooses to view a photo with invalid location metadata. The operation will fail silently. If the user chooses multiple photos from the picker, only the photos with valid location metadata will draw in AR.
* Launching the app, loading photos in AR, backgrounding the app for a long period of time, and activating the app back to the foreground can cause the previously loaded photos to disappear. Reloading the photos from the photo picker should place them back in AR space correctly.

## License

Copyright 2021 North Bronson Software

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
