#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.sabir.Login-Hub";

/// The "cloudColor" asset catalog color resource.
static NSString * const ACColorNameCloudColor AC_SWIFT_PRIVATE = @"cloudColor";

/// The "nightSkyColor" asset catalog color resource.
static NSString * const ACColorNameNightSkyColor AC_SWIFT_PRIVATE = @"nightSkyColor";

/// The "appleLogo" asset catalog image resource.
static NSString * const ACImageNameAppleLogo AC_SWIFT_PRIVATE = @"appleLogo";

/// The "facebookLogo" asset catalog image resource.
static NSString * const ACImageNameFacebookLogo AC_SWIFT_PRIVATE = @"facebookLogo";

/// The "googleLogo" asset catalog image resource.
static NSString * const ACImageNameGoogleLogo AC_SWIFT_PRIVATE = @"googleLogo";

/// The "universityLogo" asset catalog image resource.
static NSString * const ACImageNameUniversityLogo AC_SWIFT_PRIVATE = @"universityLogo";

#undef AC_SWIFT_PRIVATE
