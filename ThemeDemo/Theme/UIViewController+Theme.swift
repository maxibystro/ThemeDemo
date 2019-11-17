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
    
    private class Context {
        
        var state: State = .uninitialized
        var parentObservation: NSKeyValueObservation?
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
    
    var theme: Theme {
        ensureThemeIsInitialized()
        ensureParentObservationExists()
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
    
    private func ensureParentObservationExists() {
        if let _ = themeEnvironmentContext.parentObservation {
            return
        }
        themeEnvironmentContext.parentObservation = observe(
            \.parent,
            options: [.new]
        ) { [weak self] _, _ in
            self?.parentDidChangeTheme()
        }
    }
    
    private func ensureThemeIsInitialized() {
        if case .uninitialized = themeEnvironmentContext.state {
            setState(inheritedState())
        }
    }
    
    private func inheritedTheme() -> Theme {
        guard let parent = parent else {
            return defaultTheme
        }
        return parent.theme
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
    
    private func inheritedState() -> State {
        return .inherited(inheritedTheme())
    }
    
    private func notifyThemeDidChange() {
        themeDidChange()
        children.forEach({ $0.parentDidChangeTheme() })
    }
    
    private func parentDidChangeTheme() {
        guard let _ = parent else { return }
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
