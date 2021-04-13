//
//  NSObject+Extension.swift
//  JEMagnetic
//
//  Created by Jenson on 2021/4/10.
//  Copyright © 2021 Jenson. All rights reserved.
//

import Foundation

extension NSObject {
    
    /// 方法交换（method_exchangeImplementations实现）
    /// - Parameters:
    ///   - aClass: 当前class
    ///   - originalSelector: 原方法
    ///   - swizzledSelector: 新方法
    func swizzleMethod(for aClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        
        let originalMethod = class_getInstanceMethod(aClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)
        let didAddMethod = class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        if didAddMethod {
            class_replaceMethod(aClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
        
    }
    
}
