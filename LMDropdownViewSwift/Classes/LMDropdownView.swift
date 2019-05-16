//
//  LMDropdownView.swift
//  LMDropdownViewSwift
//
//  Created by LMinh on 5/14/19.
//

import Foundation
import UIKit

/// Dropdown view state.
public enum LMDropdownViewState {
    case willOpen
    case didOpen
    case willClose
    case didClose
}

/// Dropdown view animation direction.
public enum LMDropdownViewDirection {
    case top
    case bottom
}

/// Dropdown view delegate.
public protocol LMDropdownViewDelegate: class {
    func dropdownViewWillShow(_ dropdownView: LMDropdownView)
    func dropdownViewDidShow(_ dropdownView: LMDropdownView)
    func dropdownViewWillHide(_ dropdownView: LMDropdownView)
    func dropdownViewDidHide(_ dropdownView: LMDropdownView)
}

/// A simple dropdown view inspired by Tappy.
open class LMDropdownView {
    
    // MARK: PROPERTIES
    
    /// The closed scale of container view. Set it to 1 to disable container scale animation.
    public var closedScale: Double = 0.85 {
        didSet {
            closedScale = min(max(closedScale, 0.1), 1)
        }
    }
    
    /// A boolean indicates whether container view should be blurred. Default is true.
    public var shouldBlurContainerView: Bool = true
    
    /// The blur radius of container view.
    public var blurRadius: Double = 5.0
    
    /// The alpha of black mask button.
    public var blackMaskAlpha: Double = 0.5 {
        didSet {
            blackMaskAlpha = min(max(blackMaskAlpha, 0), 0.9)
        }
    }
    
    /// The animation duration.
    public var animationDuration: Double = 0.5
    
    /// The animation bounce height of content view.
    public var animationBounceHeight: Double = 20.0
    
    /// The animation direction.
    public var direction: LMDropdownViewDirection = .top
    
    /// The background color of content view.
    public var contentBackgroundColor: UIColor?
    
    /// The current dropdown view state.
    public private(set) var currentState: LMDropdownViewState = .didClose
    
    /// A boolean indicates whether dropdown is open.
    public var isOpen: Bool {
        return currentState == .didOpen
    }
    
    /// The dropdown view delegate.
    public weak var delegate: LMDropdownViewDelegate?
    
    /// The callback when dropdown view did show in the container view.
    public var didShowHandler: (() -> Void)?
    
    /// The callback when dropdown view did hide in the container view.
    public var didHideHandler: (() -> Void)?
    
    /// Default animation bounce scale const
    let defaultAnimationBounceScale = 0.05
    
    /// View structure
    var mainView: UIScrollView
    var contentWrapperView: UIView
    var containerWrapperView: UIImageView
    var backgroundButton: UIButton
    var originContentCenter: CGPoint = .zero
    var desContentCenter: CGPoint = .zero
    var lastOrientation: UIInterfaceOrientation
    
    // MARK: INIT
    
    public init() {
        mainView = UIScrollView()
        mainView.backgroundColor = .black
        
        contentWrapperView = UIView()
        
        containerWrapperView = UIImageView()
        containerWrapperView.backgroundColor = .black
        containerWrapperView.contentMode = .center
        
        lastOrientation = UIApplication.shared.statusBarOrientation
        
        backgroundButton = UIButton(type: .custom)
        backgroundButton.addTarget(self, action: #selector(backgroundButtonTapped), for: .touchUpInside)
        
        // Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: SHOW
    public func show(_ contentView: UIView, inView containerView: UIView, origin: CGPoint) {
        guard currentState == .didClose else { return }
        
        // Start showing
        currentState = .willOpen
        delegate?.dropdownViewWillShow(self)
        
        // Setup menu in view
        setup(contentView: contentView, inView: containerView, origin: origin)
        
        // Animate menu view controller
        addContentAnimation(forState: currentState)
        
        // Animate content view controller
        if closedScale < 1 {
            addContainerAnimation(forState: currentState)
        }
        
        // Finish showing
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.currentState = .didOpen
            self.delegate?.dropdownViewDidShow(self)
            if let handler = self.didShowHandler {
                handler()
            }
        }
    }
    
    public func show(_ contentView: UIView, inView containerView: UIView, atView: UIView) {
        let origin = CGPoint(x: atView.frame.minX, y: atView.frame.maxY)
        show(contentView, inView: containerView, origin: origin)
    }
    
    public func show(_ contentView: UIView, inNavigationController navigationController: UINavigationController?) {
        guard let containerView = navigationController?.visibleViewController?.view else { return }
        show(contentView, inView: containerView, origin: .zero)
    }
    
    public func hide() {
        guard currentState == .didOpen else { return }
        
        // Start hiding
        currentState = .willClose
        delegate?.dropdownViewWillHide(self)
        
        // Animate menu view controller
        addContentAnimation(forState: currentState)
        
        // Animate content view controller
        if closedScale < 1 {
            addContainerAnimation(forState: currentState)
        }
        
        // Finish hiding
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.currentState = .didClose
            self.delegate?.dropdownViewDidHide(self)
            if let handler = self.didHideHandler {
                handler()
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                self.mainView.alpha = 0
            }, completion: { (finished) in
                self.mainView.alpha = 1
                self.forceHide()
            })
        }
    }
    
    public func forceHide() {
        currentState = .didClose
        
        let point = contentPositionValues(forState: currentState).last
        contentWrapperView.layer.setValue(point, forKeyPath: "position")
        contentWrapperView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        contentWrapperView.removeFromSuperview()
        
        backgroundButton.removeFromSuperview()
        
        let transform = containerTransformValues(forState: currentState).last
        containerWrapperView.layer.setValue(transform, forKeyPath: "transform")
        containerWrapperView.removeFromSuperview()
        
        mainView.removeFromSuperview()
    }
}

// MARK: - SETUP
extension LMDropdownView {
    
    func setup(contentView: UIView, inView containerView: UIView, origin: CGPoint) {
        
        // Prepare container captured image
        let containerSize = containerView.bounds.size
        let scale = 3 - 2 * closedScale
        let capturedSize = CGSize(width: Double(containerSize.width) * scale, height: Double(containerSize.height) * scale)
        guard var capturedImage = UIImage.screenshot(fromView: containerView, size: capturedSize) else { return }
        if shouldBlurContainerView {
            capturedImage = capturedImage.blurred(withRadius: CGFloat(blurRadius))
        }
        
        // Main View
        mainView.frame = containerView.bounds
        containerView.addSubview(mainView)
        
        // Container Wrapper View
        containerWrapperView.image = capturedImage
        containerWrapperView.bounds = CGRect(x: 0, y: 0, width: capturedSize.width, height: capturedSize.height)
        containerWrapperView.center = mainView.center
        mainView.addSubview(containerWrapperView)
        
        // Background Button
        let maskColor = UIColor.black.withAlphaComponent(CGFloat(blackMaskAlpha))
        backgroundButton.backgroundColor = maskColor
        backgroundButton.frame = mainView.bounds
        mainView.addSubview(backgroundButton)
        
        // Content Wrapper View
        contentWrapperView.backgroundColor = contentBackgroundColor
        let contentWrapperViewHeight = Double(contentView.frame.size.height) + animationBounceHeight;
        switch direction {
        case .top:
            contentView.frame = CGRect(x: 0,
                                       y: CGFloat(animationBounceHeight),
                                       width: contentView.frame.size.width,
                                       height: contentView.frame.size.height)
            contentWrapperView.frame = CGRect(x: origin.x,
                                              y: origin.y - CGFloat(contentWrapperViewHeight),
                                              width: contentView.frame.size.width,
                                              height: CGFloat(contentWrapperViewHeight));
        case .bottom:
            contentView.frame = CGRect(x: 0,
                                       y: 0,
                                       width: contentView.frame.size.width,
                                       height: contentView.frame.size.height)
            contentWrapperView.frame = CGRect(x: origin.x,
                                              y: origin.y + CGFloat(contentWrapperViewHeight),
                                              width: contentView.frame.size.width,
                                              height: CGFloat(contentWrapperViewHeight));
        }
        contentWrapperView.addSubview(contentView)
        mainView.addSubview(contentWrapperView)
        
        // Set up origin, destination content center
        originContentCenter = CGPoint(x: contentWrapperView.frame.midX, y: contentWrapperView.frame.midY)
        if (direction == .top) {
            desContentCenter = CGPoint(x: contentWrapperView.frame.midX,
                                       y: origin.y + CGFloat(contentWrapperViewHeight)/2 - CGFloat(animationBounceHeight))
        }
        else {
            desContentCenter = CGPoint(x: contentWrapperView.frame.midX,
                                       y: origin.y + CGFloat(contentWrapperViewHeight)/2)
        }
    }
    
    @objc func backgroundButtonTapped() {
        hide()
    }
    
    @objc func orientationChanged(notification: Notification) {
        let currentOrientation = UIApplication.shared.statusBarOrientation
        let canForceHide = (currentOrientation.isPortrait && lastOrientation.isLandscape)
            || (lastOrientation.isPortrait && currentOrientation.isLandscape)
        if canForceHide {
            delegate?.dropdownViewWillHide(self)
            forceHide()
            delegate?.dropdownViewDidHide(self)
            
            if let handler = self.didHideHandler {
                handler()
            }
        }
        
        lastOrientation = currentOrientation
    }
}

// MARK: - KEYFRAME ANIMATION
extension LMDropdownView {
    
    func addContentAnimation(forState state: LMDropdownViewState) {
        let contentBounceAnim = CAKeyframeAnimation(keyPath: "position")
        contentBounceAnim.duration = animationDuration
        contentBounceAnim.isRemovedOnCompletion = false
        contentBounceAnim.fillMode = .forwards
        contentBounceAnim.values = contentPositionValues(forState: state)
        contentBounceAnim.timingFunctions = contentTimingFunctions(forState: state)
        contentBounceAnim.keyTimes = contentKeyTimes(forState: state)
        
        contentWrapperView.layer.add(contentBounceAnim, forKey: nil)
        contentWrapperView.layer.setValue(contentBounceAnim.values?.last, forKeyPath: "position")
    }
    
    func addContainerAnimation(forState state: LMDropdownViewState) {
        let containerScaleAnim = CAKeyframeAnimation(keyPath: "transform")
        containerScaleAnim.duration = animationDuration
        containerScaleAnim.isRemovedOnCompletion = false
        containerScaleAnim.fillMode = .forwards
        containerScaleAnim.values = containerTransformValues(forState: state)
        containerScaleAnim.timingFunctions = containerTimingFunctions(forState: state)
        containerScaleAnim.keyTimes = containerKeyTimes(forState: state)
        
        containerWrapperView.layer.add(containerScaleAnim, forKey: nil)
        containerWrapperView.layer.setValue(containerScaleAnim.values?.last, forKeyPath: "transform")
    }
    
    func contentPositionValues(forState state: LMDropdownViewState) -> [CGPoint] {
        let currentContentCenter = contentWrapperView.layer.position
        var values = [currentContentCenter]
        
        if state == .willOpen || state == .didOpen {
            if (direction == .top) {
                values.append(CGPoint(x: currentContentCenter.x, y: desContentCenter.y + CGFloat(animationBounceHeight)))
            }
            else {
                values.append(CGPoint(x: currentContentCenter.x, y: desContentCenter.y - CGFloat(animationBounceHeight)))
            }
            values.append(CGPoint(x: currentContentCenter.x, y: desContentCenter.y))
        }
        else {
            if (direction == .top) {
                values.append(CGPoint(x: currentContentCenter.x, y: currentContentCenter.y + CGFloat(animationBounceHeight)))
            }
            else {
                values.append(CGPoint(x: currentContentCenter.x, y: currentContentCenter.y - CGFloat(animationBounceHeight)))
            }
            values.append(CGPoint(x: currentContentCenter.x, y: originContentCenter.y))
        }
        
        return values
    }
    
    func contentKeyTimes(forState state: LMDropdownViewState) -> [NSNumber] {
        return [NSNumber(value: 0), NSNumber(value: 0.5), NSNumber(value: 1)]
    }
    
    func contentTimingFunctions(forState state: LMDropdownViewState) -> [CAMediaTimingFunction] {
        return [CAMediaTimingFunction(name: .easeOut), CAMediaTimingFunction(name: .easeInEaseOut)]
    }
    
    func containerTransformValues(forState state: LMDropdownViewState) -> [CATransform3D] {
        let transform = containerWrapperView.layer.transform
        var values = [transform]
        
        if state == .willOpen || state == .didOpen {
            let scale = CGFloat(closedScale - defaultAnimationBounceScale)
            values.append(CATransform3DScale(transform, scale, scale, scale))
            values.append(CATransform3DScale(transform, CGFloat(closedScale), CGFloat(closedScale), CGFloat(closedScale)))
        }
        else {
            let scale = CGFloat(1 - defaultAnimationBounceScale)
            values.append(CATransform3DScale(transform, scale, scale, scale))
            values.append(CATransform3DIdentity)
        }
        
        return values
    }
    
    func containerKeyTimes(forState state: LMDropdownViewState) -> [NSNumber] {
        return [NSNumber(value: 0), NSNumber(value: 0.5), NSNumber(value: 1)]
    }
    
    func containerTimingFunctions(forState state: LMDropdownViewState) -> [CAMediaTimingFunction] {
        return [CAMediaTimingFunction(name: .easeOut), CAMediaTimingFunction(name: .easeInEaseOut)]
    }
}
