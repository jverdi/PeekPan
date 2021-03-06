/******************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 * Copyright 2016 Adobe Systems Incorporated
 * All Rights Reserved.
 *
 * This file is licensed to you under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License. You may obtain a copy
 * of the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 * OF ANY KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 ******************************************************************************/

import UIKit

/// PeekPanViewControllerDelegate protocol. Subclass of PeekPanCoordinatorDelegate.
@objc public protocol PeekPanViewControllerDelegate : PeekPanCoordinatorDelegate {
    /// Changes the view controller's view at a certain index. Return nil for no change.
    optional func view(for peekPanViewController: PeekPanViewController, atIndex index: Int) -> UIView?
    /// Changes the view controller's view at a certain percentage. Return nil for no change.
    optional func view(for peekPanViewController: PeekPanViewController, atPercentage percentage: CGFloat) -> UIView?
}

/// PeekPanViewController class. Recommended to use this class as a PeekPanCoordinatorDelegate to function as intended.
public class PeekPanViewController : UIViewController, PeekPanCoordinatorDelegate {
    /// A reference to a view controller that finished setting up.
    public static var currentViewController: PeekPanViewController?
    
    /// PeekPanViewControllerDelegate reference.
    public weak var delegate: PeekPanViewControllerDelegate?
    /// An identifier to bind to the view controller. Used when committing a view controller.
    public var identifier: String?
    /// An object to bind to the view controller. Used when committing a view controller.
    public var contentObject: AnyObject?
    
    private func reset() {
        identifier = nil
        contentObject = nil
        self.dynamicType.currentViewController = nil
    }
    
    /// Setup to reset data and set currentViewController.
    public func setup() {
        setup(at: CGSizeZero)
    }
    
    /// Setup to reset data, set the size of the view controller, and set currentViewController.
    public func setup(at size: CGSize) {
        reset()
        self.dynamicType.currentViewController = self
        updateSize(for: size)
    }
    
    /// Update the size of the view controller using 'sizeToFit()'.
    public func updateSize() {
        updateSize(for: CGSizeZero)
    }
    
    /// Update the size of the view controller with a specified size. Use 'CGSizeZero' to update the size using 'sizeToFit()'.
    public func updateSize(for size: CGSize) {
        if size == CGSizeZero {
            view.sizeToFit()
            preferredContentSize = view.bounds.size
        }
        else {
            preferredContentSize = size
        }
    }
    
    // MARK: PeekPanCoordinatorDelegate
    
    public func peekPanCoordinatorBegan(peekPanCoordinator: PeekPanCoordinator) {
        delegate?.peekPanCoordinatorBegan?(peekPanCoordinator)
    }
    
    public func peekPanCoordinatorUpdated(peekPanCoordinator: PeekPanCoordinator) {
        delegate?.peekPanCoordinatorUpdated?(peekPanCoordinator)
        guard let viewAtPercentage = delegate?.view?(for: self, atPercentage: peekPanCoordinator.percentage) else { return }
        view = viewAtPercentage
        view.sizeToFit()
        preferredContentSize = view.bounds.size
    }
    
    public func peekPanCoordinator(peekPanCoordinator: PeekPanCoordinator, movedTo index: Int) {
        delegate?.peekPanCoordinator?(peekPanCoordinator, movedTo: index)
        guard let viewAtIndex = delegate?.view?(for: self, atIndex: index) else { return }
        view = viewAtIndex
        view.sizeToFit()
        preferredContentSize = view.bounds.size
    }
    
    public func peekPanCoordinatorEnded(peekPanCoordinator: PeekPanCoordinator) {
        delegate?.peekPanCoordinatorEnded?(peekPanCoordinator)
        reset()
    }
}
