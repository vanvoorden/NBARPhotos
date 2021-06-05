//
//  NBARPhotosDataModel.swift
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
import UIKit

extension NBARPhotosPickerResult : NBARPhotosAnchor {
  
}

//  MARK: -

final class NBARPhotosDataModel : ObservableObject {
  //  MARK: -
  private var requestsDictionary = Dictionary<UUID, PHImageRequestID>()
  @Published private var resultsDictionary = Dictionary<UUID, NBARPhotosPickerResult>()
  
  private let queue = DispatchQueue(label: "")
  
  //  MARK: -
  
  func parseResults(_ results: Array<NBARPhotosPickerResult>) {
    self.queue.async { [weak self] in
      if results.count != 0 {
        var resultsDictionary = Dictionary<UUID, NBARPhotosPickerResult>()
        for result in results {
          resultsDictionary[result.id] = result
        }
        DispatchQueue.main.async { [weak self] in
          self?.resultsDictionary = resultsDictionary
        }
      }
    }
  }
}

//  MARK: -

extension NBARPhotosDataModel : NBARPhotosViewDataModel {
  //  MARK: -
  var anchors: Array<NBARPhotosAnchor> {
    return Array(self.resultsDictionary.values)
  }
  
  //  MARK: -
  
  func cancelImageRequest(for id: UUID) {
    if let request = self.requestsDictionary[id] {
      self.requestsDictionary[id] = nil
      PHImageManager.default().cancelImageRequest(request)
    }
  }
  
  func placeholder(for anchor: NBARPhotosAnchor) -> UIImage? {
    return nil
  }
  
  func requestImage(for anchor: NBARPhotosAnchor, resultHandler: @escaping (UIImage?, Dictionary<AnyHashable, Any>?) -> Void) -> UUID? {
    if let result = self.resultsDictionary[anchor.id],
       let asset = PHAsset.fetchAssets(withLocalIdentifiers: [result.asset], options: nil).lastObject {
      let id = UUID()
      let options = PHImageRequestOptions()
      options.isNetworkAccessAllowed = true
      self.requestsDictionary[id] = PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .default, options: options) { [weak self] result, info in
        DispatchQueue.main.async { [weak self] in
          self?.requestsDictionary[id] = nil
          resultHandler(result, nil)
        }
      }
      return id
    }
    return nil
  }
}
