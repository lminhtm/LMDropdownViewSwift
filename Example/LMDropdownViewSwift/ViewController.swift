//
//  ViewController.swift
//  LMDropdownViewSwift
//
//  Created by LMinh on 05/14/2019.
//  Copyright (c) 2019 LMinh. All rights reserved.
//

import UIKit
import MapKit
import LMDropdownViewSwift

class ViewController: UIViewController {
    
    // MARK: PROPERTIES
    
    let mapTypes: [String] = ["Standard", "Satellite", "Hybrid"]
    var currentMapTypeIndex: Int = 0
    lazy var dropdownView: LMDropdownView = LMDropdownView()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet var moreBottomView: UIView!
    @IBOutlet weak var dropPinButton: UIButton!
    @IBOutlet weak var removeAllPinsButton: UIButton!
    @IBOutlet var menuTableView: UITableView!
    
    // MARK: VIEW LIFECYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropdownView.delegate = self
        dropdownView.closedScale = 0.85
        dropdownView.blurRadius = 5
        dropdownView.shouldBlurContainerView = true
        dropdownView.blackMaskAlpha = 0.5
        dropdownView.animationDuration = 0.5
        dropdownView.animationBounceHeight = 20
        
        dropPinButton.layer.cornerRadius = 5
        removeAllPinsButton.layer.cornerRadius = 5
        moreButton.layer.cornerRadius = 5
        moreButton.layer.shadowOffset = .zero
        moreButton.layer.shadowOpacity = 0.5
        moreButton.layer.shadowRadius = 1.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuTableView.frame = CGRect(x: menuTableView.frame.minX,
                                     y: menuTableView.frame.minY,
                                     width: view.bounds.width,
                                     height: min(view.bounds.height - 50, CGFloat(mapTypes.count * 50)))
        moreBottomView.frame = CGRect(x: moreBottomView.frame.minX,
                                      y: moreBottomView.frame.minY,
                                      width: view.bounds.width,
                                      height: moreBottomView.bounds.height)
    }

    // MARK: EVENTS
    
    @IBAction func titleButtonTapped(_ sender: Any) {
        menuTableView.reloadData()
        showDropdownView(fromDirection: .top)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        showDropdownView(fromDirection: .bottom)
    }
    
    @IBAction func dropPinButtonTapped(_ sender: Any) {
        dropdownView.hide()
        DispatchQueue.main.asyncAfter(deadline: .now() + dropdownView.animationDuration) {
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = self.mapView.convert(self.mapView.center, toCoordinateFrom: self.mapView)
            pointAnnotation.title = "LMDropdownView"
            self.mapView.addAnnotation(pointAnnotation)
        }
    }
    
    @IBAction func removeAllPinsButtonTapped(_ sender: Any) {
        dropdownView.hide()
        DispatchQueue.main.asyncAfter(deadline: .now() + dropdownView.animationDuration) {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as! MenuCell
        cell.titleLabel.text = mapTypes[indexPath.row]
        cell.selectedMarkView.isHidden = indexPath.row != currentMapTypeIndex
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        currentMapTypeIndex = indexPath.row
//        dropdownView.hide()
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "current")
        pinAnnotationView.animatesDrop = true
        pinAnnotationView.canShowCallout = true
        pinAnnotationView.pinColor = .green
        return pinAnnotationView
    }
}

// MARK: - LMDropdownViewDelegate
extension ViewController: LMDropdownViewDelegate {

    func showDropdownView(fromDirection direction: LMDropdownViewDirection) {

        guard let navigationController = navigationController else { return }

        // Customize Dropdown style
        dropdownView.direction = direction

        // Show/hide dropdown view
        if dropdownView.isOpen {
            dropdownView.hide()
        }
        else {
            switch direction {
            case .top:
                dropdownView.contentBackgroundColor = UIColor(red: 40.0/255, green: 196.0/255, blue: 80.0/255, alpha: 1)
                dropdownView.show(menuTableView, inNavigationController: navigationController)
            case .bottom:
                dropdownView.contentBackgroundColor = .white
                let origin = CGPoint(x: 0, y: navigationController.view.bounds.height - moreBottomView.bounds.height)
                dropdownView.show(moreBottomView, inView: navigationController.view, origin: origin)
            }
        }
    }

    func dropdownViewWillShow(_ dropdownView: LMDropdownView) {
        NSLog("Dropdown view will show")
    }

    func dropdownViewDidShow(_ dropdownView: LMDropdownView) {
        NSLog("Dropdown view did show")
    }

    func dropdownViewWillHide(_ dropdownView: LMDropdownView) {
        NSLog("Dropdown view will hide")
    }

    func dropdownViewDidHide(_ dropdownView: LMDropdownView) {
        NSLog("Dropdown view did hide")

        if currentMapTypeIndex == 0 {
            mapView.mapType = .standard
        }
        else if currentMapTypeIndex == 1 {
            mapView.mapType = .satellite
        }
        else {
            mapView.mapType = .hybrid
        }
    }
}

