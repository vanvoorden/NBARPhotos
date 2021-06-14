//
//  NBARPhotosApp.swift
//  NBARPhotos
//
//  Copyright © 2021 North Bronson Software
//
//  This Item is protected by copyright and/or related rights. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use. In addition, no permission is required from the rights-holder(s) for scholarly, educational, or non-commercial uses. For other uses, you need to obtain permission from the rights-holder(s).
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import NBARKit
import Photos
import SwiftUI

@main
struct NBARPhotosApp : App {
  //  MARK: -
  @StateObject private var model = NBARPhotosDataModel()
  
  var body: some Scene {
    WindowGroup {
      NBARPhotosContentView(
        model: self.model
      )
    }
  }
}

//  MARK: -

extension Bundle {
  var navigationTitle: String {
    return ((self.infoDictionary?["CFBundleDisplayName"] as? String ?? "") + " " + (self.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""))
  }
}

//  MARK: -

private struct NBARPhotosLaunchView : View {
  //  MARK: -
  var body: some View {
    ScrollView {
      HStack {
        VStack(
          alignment: .leading
        ) {
          Text("Tap the Photo icon to begin your AR experience.\n")
          Text("The app will download the locations of the photos you requested. The app will only place your photos in AR if they have a location saved.\n")
          Text("The app needs to determine your location before placing your photos in AR. You will be asked to enable Location Services. Enabling Wi-Fi can help the app determine a more accurate location.\n")
          Text("The app will use your surroundings to help place your photos. You can slowly sweep your device around and point your device at nearby buildings. Please remain patient while your device collects accurate location data. Pointing your device to the ground can slow the process down. Keep your camera pointed up and try to scan for the shapes of the buildings you see on the street.\n")
          Text("The app will place your photos in AR when your device has determined an accurate location.\n")
          Text("Tap the camera view to hide your photo settings. Tap again to hide your app navigation bar. Tap again to see your photo settings and your app navigation bar.\n")
          Text("Thanks.\n")
        }
        Spacer()
      }.padding()
    }
  }
}

//  MARK: -

struct NBARPhotosContentView : View {
  //  MARK: -
  @ObservedObject private var model: NBARPhotosDataModel
  
  @State private var isActionSheetPresented = false
  @State private var isEditing = true
  @State private var isNavigationBarHidden = false
  @State private var isRequestingAuthorization = false
  @State private var isSheetPresented = false
  
  var body: some View {
    NavigationView {
      Group {
        if self.model.anchors.count == 0 {
          NBARPhotosLaunchView(
          ).navigationTitle(
            Bundle.main.navigationTitle
          ).onTapGesture {
            self.requestAuthorization()
          }
        } else {
          NBARPhotosView(
            model: self.model,
            isEditing: self.isEditing
          ).edgesIgnoringSafeArea(
            .all
          ).navigationBarTitleDisplayMode(
            .inline
          ).navigationTitle(
            Bundle.main.navigationTitle
          ).onTapGesture {
            if self.isNavigationBarHidden {
              self.isNavigationBarHidden.toggle()
              self.isEditing.toggle()
            } else {
              if self.isEditing {
                self.isEditing.toggle()
              } else {
                self.isNavigationBarHidden.toggle()
              }
            }
          }
        }
      }.actionSheet(
        isPresented: self.$isActionSheetPresented
      ) {
        ActionSheet(
          title: Text("Allow Photos Access"),
          message: nil,
          buttons: [
            .cancel(),
            .default(
              Text("Settings"),
              action: {
                UIApplication.shared.openSettings()
              }
            )
          ]
        )
      }.navigationBarHidden(
        self.isNavigationBarHidden
      ).sheet(
        isPresented: self.$isSheetPresented
      ) {
        NBARPhotosPicker(
          didFinishPicking: { results in
            self.model.parseResults(results)
            self.isSheetPresented.toggle()
          }
        )
      }.statusBar(
        hidden: self.isNavigationBarHidden
      ).toolbar {
        ToolbarItem(
          placement: .navigationBarLeading
        ) {
          Button(
            action: {
              self.isEditing.toggle()
            }
          ) {
            Label(
              "Info",
              systemImage: "info.circle"
            )
          }.disabled(
            self.model.anchors.count == 0
          )
        }
        ToolbarItem(
          placement: .navigationBarTrailing
        ) {
          Button(
            action: {
              self.requestAuthorization()
            }
          ) {
            Label(
              "Photo",
              systemImage: "photo"
            )
          }.disabled(
            self.isRequestingAuthorization
          )
        }
      }
    }.navigationViewStyle(
      StackNavigationViewStyle()
    )
  }
  
  //  MARK: -
  
  init(model: NBARPhotosDataModel) {
    self.model = model
  }
}

private extension NBARPhotosContentView {
  // MARK: -
  func requestAuthorization() {
    if self.isRequestingAuthorization == false {
      self.isRequestingAuthorization = true
      PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        DispatchQueue.main.async {
          self.isRequestingAuthorization = false
          switch status {
          case .notDetermined:
            self.isActionSheetPresented.toggle()
            break
          case .restricted:
            self.isActionSheetPresented.toggle()
            break
          case .denied:
            self.isActionSheetPresented.toggle()
            break
          case .authorized:
            self.isSheetPresented.toggle()
            break
          case .limited:
            self.isSheetPresented.toggle()
            break
          default:
            break
          }
        }
      }
    }
  }
}

// MARK: -

struct NBARPhotosContentViewPreviews: PreviewProvider {
  // MARK: -
  static var previews: some View {
    NBARPhotosContentView(
      model: NBARPhotosDataModel()
    )
  }
}
