//
//  Copyright © 2021 North Bronson Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import NBARKit
import Photos
import UIKit

extension NBARPhotosPickerResult : NBARPhotosViewAnchor {
  
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
  var anchors: Array<NBARPhotosViewAnchor> {
    return Array(self.resultsDictionary.values)
  }
  
  //  MARK: -
  
  func cancelImageRequest(for id: UUID) {
    if let request = self.requestsDictionary[id] {
      self.requestsDictionary[id] = nil
      PHImageManager.default().cancelImageRequest(request)
    }
  }
  
  func placeholder(for anchor: NBARPhotosViewAnchor) -> UIImage? {
    return nil
  }
  
  func requestImage(for anchor: NBARPhotosViewAnchor, resultHandler: @escaping (UIImage?, Error?) -> Void) -> UUID? {
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
