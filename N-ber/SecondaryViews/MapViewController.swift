//
//  MapViewController.swift
//  N-ber
//
//  Created by Seyma on 6.09.2023.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    //MARK: - Vars
    var location: CLLocation?
    var mapView: MKMapView! // this is not optional because our mapView should have some kind of map in order to display our current location
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTitle()
        configureMapView()
        configureLeftBarButton()
        
    }

    
    //MARK: - Configuration
    private func configureMapView() {
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        mapView.showsUserLocation = true
        
        if location != nil {
            mapView.setCenter(location!.coordinate, animated: false) // Our pin that is here going to be the center of our mapView
            
            mapView.addAnnotation(MapAnnotation(title: "Konum", coordinate: location!.coordinate))
            //mapView.addAnnotation(MapAnnotation(title: nil, coordinate: location!.coordinate))
            
        }
    
        view.addSubview(mapView)
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))
        
    }
    
    private func configureTitle() {
        self.title = "Harita"
    }
    
    
    //MARK: - Actions
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)  // we are back to our chatroom
    }
}
