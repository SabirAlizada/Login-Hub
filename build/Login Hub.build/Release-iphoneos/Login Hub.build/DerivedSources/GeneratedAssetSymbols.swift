import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "cloudColor" asset catalog color resource.
    static let cloud = DeveloperToolsSupport.ColorResource(name: "cloudColor", bundle: resourceBundle)

    /// The "nightSkyColor" asset catalog color resource.
    static let nightSky = DeveloperToolsSupport.ColorResource(name: "nightSkyColor", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "appleLogo" asset catalog image resource.
    static let appleLogo = DeveloperToolsSupport.ImageResource(name: "appleLogo", bundle: resourceBundle)

    /// The "facebookLogo" asset catalog image resource.
    static let facebookLogo = DeveloperToolsSupport.ImageResource(name: "facebookLogo", bundle: resourceBundle)

    /// The "googleLogo" asset catalog image resource.
    static let googleLogo = DeveloperToolsSupport.ImageResource(name: "googleLogo", bundle: resourceBundle)

    /// The "universityLogo" asset catalog image resource.
    static let universityLogo = DeveloperToolsSupport.ImageResource(name: "universityLogo", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "cloudColor" asset catalog color.
    static var cloud: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cloud)
#else
        .init()
#endif
    }

    /// The "nightSkyColor" asset catalog color.
    static var nightSky: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .nightSky)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "cloudColor" asset catalog color.
    static var cloud: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .cloud)
#else
        .init()
#endif
    }

    /// The "nightSkyColor" asset catalog color.
    static var nightSky: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .nightSky)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "cloudColor" asset catalog color.
    static var cloud: SwiftUI.Color { .init(.cloud) }

    /// The "nightSkyColor" asset catalog color.
    static var nightSky: SwiftUI.Color { .init(.nightSky) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "cloudColor" asset catalog color.
    static var cloud: SwiftUI.Color { .init(.cloud) }

    /// The "nightSkyColor" asset catalog color.
    static var nightSky: SwiftUI.Color { .init(.nightSky) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "appleLogo" asset catalog image.
    static var appleLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appleLogo)
#else
        .init()
#endif
    }

    /// The "facebookLogo" asset catalog image.
    static var facebookLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .facebookLogo)
#else
        .init()
#endif
    }

    /// The "googleLogo" asset catalog image.
    static var googleLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .googleLogo)
#else
        .init()
#endif
    }

    /// The "universityLogo" asset catalog image.
    static var universityLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .universityLogo)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "appleLogo" asset catalog image.
    static var appleLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .appleLogo)
#else
        .init()
#endif
    }

    /// The "facebookLogo" asset catalog image.
    static var facebookLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .facebookLogo)
#else
        .init()
#endif
    }

    /// The "googleLogo" asset catalog image.
    static var googleLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .googleLogo)
#else
        .init()
#endif
    }

    /// The "universityLogo" asset catalog image.
    static var universityLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .universityLogo)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

