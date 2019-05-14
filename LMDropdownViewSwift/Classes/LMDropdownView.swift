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
public protocol LMDropdownViewDelegate: NSObject {
    func dropdownViewWillShow(dropdownView: LMDropdownView)
    func dropdownViewDidShow(dropdownView: LMDropdownView)
    func dropdownViewWillHide(dropdownView: LMDropdownView)
    func dropdownViewDidHide(dropdownView: LMDropdownView)
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
    public var blurRadius: Double = 5
    
    /// The alpha of black mask button.
    public var blackMaskAlpha: Double = 0.5 {
        didSet {
            blackMaskAlpha = min(max(blackMaskAlpha, 0), 0.9)
        }
    }
    
    /// The animation duration.
    public var animationDuration: Double = 0.5
    
    /// The animation bounce height of content view.
    public var animationBounceHeight: Double = 20
    
    /// The animation direction.
    public var direction: LMDropdownViewDirection = .top
    
    /// The background color of content view.
    public var contentBackgroundColor: UIColor?
    
    /// The current dropdown view state.
    public let currentState: LMDropdownViewState = .didClose
    
    /// A boolean indicates whether dropdown is open.
    public var isOpen: Bool {
        return currentState == .didOpen
    }
    
    /// The dropdown view delegate.
    public weak var delegate: LMDropdownViewDelegate?
    
    /// Default animation bounce scale const
    let defaultAnimationBounceScale = 0.05
    
    // MARK: INIT
    
    init() {
        
    }
    
    // MARK: SHOW
    public func show(inView containerView: UIView, contentView: UIView, origin: CGPoint) {
        
    }
    
    public func show(inView containerView: UIView, contentView: UIView, atView view: UIView) {
        
    }
    
    public func show(inNavigationController navigationController: UINavigationController, contentView: UIView) {
        
    }
    
    public func hide() {
        
    }
    
    public func forceHide() {
        
    }
    
    // MARK: PRIVATE
    
    func setup(contentView: UIView, inView containerView: UIView, origin: CGPoint) {
        
    }
    
    func backgroundButtonTapped() {
        
    }
    
    // MARK: KEYFRAME ANIMATION
    
    func addContentAnimation(forState state: LMDropdownViewState) {
        
    }
    
    func addContainerAnimation(forState state: LMDropdownViewState) {
        
    }
    
    func contentPositionValues(forState state: LMDropdownViewState) -> [CGPoint] {
        return [CGPoint.zero]
    }
}
