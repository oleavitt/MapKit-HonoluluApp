/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import MapKit

// MARK: UIViewController

class ViewController: UIViewController {
  @IBOutlet private var mapView: MKMapView!
  
  private var artworks: [Artwork] = []
  
  // Set the initial location in Honolulu, HI
  let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
  let oahuCenter = CLLocation(latitude: 21.4765, longitude: -157.9647)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    mapView.centerToLocation(initialLocation)
    mapView.constrainCamera(oahuCenter, latitudinalMeters: 50000, longitudinalMeters: 60000, maxZoomRange: 200000)
    mapView.register(ArtworkView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    loadInitialData()
    mapView.addAnnotations(artworks)
  }
}

// MARK: MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    guard let artwork = view.annotation as? Artwork else {
      return
    }

    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    artwork.mapItem?.openInMaps(launchOptions: launchOptions)
  }
}

// MARK: Private

private extension ViewController {
  func loadInitialData() {
    guard let fileName = Bundle.main.url(forResource: "PublicArt", withExtension: "geojson"),
          let artworkData = try? Data(contentsOf: fileName) else {
      return
    }
    
    do {
      let features = try MKGeoJSONDecoder()
        .decode(artworkData)
        .compactMap { $0 as? MKGeoJSONFeature }
      let validWorks = features.compactMap(Artwork.init)
      artworks.append(contentsOf: validWorks)
    } catch {
      print("Unexpected error: \(error)")
    }
  }
}
