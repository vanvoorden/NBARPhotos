//
//  NBARPhotosPicker.swift
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

import PhotosUI
import SwiftUI

private extension PHAsset {
  //  MARK: -
  class func fetchAssets(withResults results: Array<PHPickerResult>, options: PHFetchOptions?) -> Array<PHAsset> {
    let identifiers = results.compactMap { result in
      return result.assetIdentifier
    }
    let results = self.fetchAssets(withLocalIdentifiers: identifiers, options: options)
    return results.objects(at: IndexSet(integersIn: 0..<results.count))
  }
}

//  MARK: -

private func OpenSettings() -> UIAlertController {
  let actionSheet = UIAlertController(title: "Allow Photos Access", message: nil, preferredStyle: .actionSheet)
  actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
  actionSheet.addAction(UIAlertAction(title: "Settings", style: .default) { action in
    UIApplication.shared.openSettings()
  })
  return actionSheet
}

//  MARK: -

private func ParseAssets(_ assets: Array<PHAsset>) -> Array<NBARPhotosPickerResult> {
  var results = Array<NBARPhotosPickerResult>()
  for asset in assets {
    if let location = asset.location {
      let result = NBARPhotosPickerResult(id: UUID(), altitude: location.altitude, asset: asset.localIdentifier, coordinate: location.coordinate, course: location.course, pixelHeight: asset.pixelHeight, pixelWidth: asset.pixelWidth)
      results.append(result)
    }
  }
  return results
}

//  MARK: -

private func ParseResults(_ results: Array<PHPickerResult>) -> Array<NBARPhotosPickerResult> {
  let assets = PHAsset.fetchAssets(withResults: results, options: nil)
  return ParseAssets(assets)
}

//  MARK: -

extension UIApplication {
  //  MARK: -
  func openSettings(options: Dictionary<UIApplication.OpenExternalURLOptionsKey, Any> = [:], completionHandler completion: ((Bool) -> Void)? = nil) {
    if let url = URL(string: Self.openSettingsURLString),
       self.canOpenURL(url) {
      self.open(url, options: options, completionHandler: completion)
    }
  }
}

//  MARK: -

struct NBARPhotosPickerResult {
  //  MARK: -
  let id: UUID
  let altitude: CLLocationDistance?
  let asset: String
  let coordinate: CLLocationCoordinate2D
  let course: CLLocationDirection
  let pixelHeight: Int?
  let pixelWidth: Int?
}

//  MARK: -

struct NBARPhotosPicker : UIViewControllerRepresentable {
  //  MARK: -
  private let didFinishPicking: (Array<NBARPhotosPickerResult>) -> Void
  
  //  MARK: -
  
  init(didFinishPicking: @escaping (Array<NBARPhotosPickerResult>) -> Void) {
    self.didFinishPicking = didFinishPicking
  }
  
  func makeUIViewController(context: Context) -> PHPickerViewController {
    var configuration = PHPickerConfiguration(photoLibrary: .shared())
    configuration.selectionLimit = 0
    let controller = PHPickerViewController(configuration: configuration)
    controller.delegate = context.coordinator
    return controller
  }
  
  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    
  }
  
  func makeCoordinator() -> Self.Coordinator {
    Self.Coordinator(self)
  }
  
  //  MARK: -
  
  final class Coordinator : NSObject, PHPhotoLibraryChangeObserver, PHPickerViewControllerDelegate {
    //  MARK: -
    private let parent: NBARPhotosPicker
    
    private var isRequestingAuthorization = false
    
    private var results: Array<PHPickerResult>?
    
    //  MARK: -
    
    init(_ parent: NBARPhotosPicker) {
      self.parent = parent
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: Array<PHPickerResult>) {
      if self.isRequestingAuthorization == false {
        if results.count != 0 {
          self.isRequestingAuthorization = true
          PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async { [weak self] in
              if let self = self {
                self.isRequestingAuthorization = false
                switch status {
                case .notDetermined:
                  picker.present(OpenSettings(), animated: true, completion: nil)
                  break
                case .restricted:
                  picker.present(OpenSettings(), animated: true, completion: nil)
                  break
                case .denied:
                  picker.present(OpenSettings(), animated: true, completion: nil)
                  break
                case .authorized:
                  let results = ParseResults(results)
                  self.parent.didFinishPicking(results)
                  break
                case .limited:
                  let assets = PHAsset.fetchAssets(withResults: results, options: nil)
                  if assets.count == results.count {
                    let results = ParseAssets(assets)
                    self.parent.didFinishPicking(results)
                  } else {
                    let actionSheet = UIAlertController(title: "Allow Photos Access", message: nil, preferredStyle: .actionSheet)
                    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    actionSheet.addAction(UIAlertAction(title: "Settings", style: .default) { [weak self] action in
                      if let self = self {
                        self.results = results
                        PHPhotoLibrary.shared().register(self)
                        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: picker)
                      }
                    })
                    picker.present(actionSheet, animated: true, completion: nil)
                  }
                  break
                default:
                  break
                }
              }
            }
          }
        } else {
          self.parent.didFinishPicking([])
        }
      }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
      DispatchQueue.main.async { [weak self] in
        if let self = self,
           let results = self.results {
          let assets = PHAsset.fetchAssets(withResults: results, options: nil)
          if assets.count == results.count {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
            let results = ParseAssets(assets)
            self.parent.didFinishPicking(results)
          }
        }
      }
    }
  }
}

// MARK: -

struct NBARPhotosPickerPreviews: PreviewProvider {
  // MARK: -
  static var previews: some View {
    NBARPhotosPicker(
      didFinishPicking: { results in
        
      }
    )
  }
}
