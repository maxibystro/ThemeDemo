//
//  UIViewController+Theme.swift
//  ThemeDemo
//
//  Created by Maxim Bystrov on 16.11.2019.
//  Copyright © 2019 Maxim Bystrov. All rights reserved.
//

import UIKit

private var contextAssociationObject: UInt8 = 0

extension UIViewController: ThemeEnvironment {
    
    private enum State {
        case uninitialized
        case inherited(Theme)
        case overridden(Theme)
        
        var theme: Theme? {
            switch self {
            case .uninitialized:
                return nil
            case .inherited(let theme):
                return theme
            case .overridden(let theme):
                return theme
            }
        }
    }
    
    private final class Context {
        
        var state: State = .uninitialized
        var observations = [NSKeyValueObservation]()
    }
    
    private var themeEnvironmentContext: Context {
        if let associatedContext = objc_getAssociatedObject(self, &contextAssociationObject) as? Context {
            return associatedContext
        }
        let context = Context()
        objc_setAssociatedObject(self, &contextAssociationObject, context, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return context
    }
    
    private var defaultTheme: Theme {
        return LightTheme.theme
    }
    
    private var predecessor: UIViewController? {
        if let _ = parent {
            return parent
        }
        return presentingViewController
    }
    
    var theme: Theme {
        ensureThemeIsInitialized()
        ensureObservationsAreConfigured()
        return themeEnvironmentContext.state.theme!
    }
    
    func themeDidChange() {}
    
    func setOverrideTheme(_ overrideTheme: Theme?) {
        if let overrideTheme = overrideTheme {
            setStateAndNotify(.overridden(overrideTheme))
        } else {
            setStateAndNotify(inheritedState())
        }
    }
    
    private func ensureObservationsAreConfigured() {
        guard themeEnvironmentContext.observations.isEmpty else { return }
        let parentObservation = observe(
            \.parent,
            options: [.new]
        ) { [weak self] _, _ in
            self?.predecessorDidChangeTheme()
        }
        let presentingControllerObservation = observe(
            \.presentingViewController,
            options: [.new]
        ) { [weak self] _, _ in
            self?.predecessorDidChangeTheme()
        }
        themeEnvironmentContext.observations = [parentObservation, presentingControllerObservation]
    }
    
    private func ensureThemeIsInitialized() {
        if case .uninitialized = themeEnvironmentContext.state {
            setState(inheritedState())
        }
    }
    
    private func inheritedTheme() -> Theme {
        guard let predecessor = predecessor else {
            return defaultTheme
        }
        return predecessor.theme
    }
    
    private func inheritedState() -> State {
        return .inherited(inheritedTheme())
    }
    
    @discardableResult private func setState(_ state: State) -> Bool {
        let oldTheme = themeEnvironmentContext.state.theme
        let newTheme = state.theme
        themeEnvironmentContext.state = state
        return oldTheme !== newTheme
    }
    
    private func setStateAndNotify(_ state: State) {
        let changed = setState(state)
        if changed {
            notifyThemeDidChange()
        }
    }
    
    private func notifyThemeDidChange() {
        themeDidChange()
        children.forEach({ $0.predecessorDidChangeTheme() })
        presentedViewController?.predecessorDidChangeTheme()
    }
    
    private func predecessorDidChangeTheme() {
        guard let _ = predecessor else { return }
        switch themeEnvironmentContext.state {
        case .uninitialized:
            fallthrough
        case .inherited(_):
            setStateAndNotify(inheritedState())
        default:
            return
        }
    }
}
