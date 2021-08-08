



//  GHKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


import Foundation
import ImageIO

#if os(macOS)
import AppKit
 typealias CFCrossPlatformImage = NSImage
 typealias CFCrossPlatformView = NSView
 typealias CFCrossPlatformColor = NSColor
 typealias CFCrossPlatformImageView = NSImageView
 typealias CFCrossPlatformButton = NSButton
#else
import UIKit
 typealias CFCrossPlatformImage = UIImage
 typealias CFCrossPlatformColor = UIColor
#if !os(watchOS)
 typealias CFCrossPlatformImageView = UIImageView
 typealias CFCrossPlatformView = UIView
 typealias CFCrossPlatformButton = UIButton
#else
import WatchKit
#endif
#endif

/// Wrapper for GHKingfisher compatible types. This type provides an extension point for
/// connivence methods in GHKingfisher.
 struct GHKingfisherWrapper<Base> {
     let base: Base
     init(_ base: Base) {
        self.base = base
    }
}

/// Represents an object type that is compatible with GHKingfisher. You can use `kf` property to get a
/// value in the namespace of GHKingfisher.
 protocol GHKingfisherCompatible: AnyObject { }

/// Represents a value type that is compatible with GHKingfisher. You can use `kf` property to get a
/// value in the namespace of GHKingfisher.
 protocol GHKingfisherCompatibleValue {}

extension GHKingfisherCompatible {
    /// Gets a namespace holder for GHKingfisher compatible types.
     var cf: GHKingfisherWrapper<Self> {
        get { return GHKingfisherWrapper(self) }
        set { }
    }
}

extension GHKingfisherCompatibleValue {
    /// Gets a namespace holder for GHKingfisher compatible types.
     var cf: GHKingfisherWrapper<Self> {
        get { return GHKingfisherWrapper(self) }
        set { }
    }
}

extension CFCrossPlatformImage: GHKingfisherCompatible { }
#if !os(watchOS)
extension CFCrossPlatformImageView: GHKingfisherCompatible { }
extension CFCrossPlatformButton: GHKingfisherCompatible { }
#else
extension WKInterfaceImage: GHKingfisherCompatible { }
#endif
