#import <UIKit/UIKit.h>
#include <IOKit/hid/IOHIDEventSystem.h>

static CGFloat SENSITIVITY = 2.0;

static NSDictionary *globalSettings;
static BOOL isEnabled = YES;

static CGFloat lastQuality = 0;
static CGFloat lastDensity = 0;
static CGFloat lastRadius = 0;
static CGFloat pressure = 0;

@interface UITouch (Private)
@property (assign,setter=_setHidEvent:,nonatomic) IOHIDEventRef _hidEvent;
@property (nonatomic, retain) NSNumber *pab_force;
@property (nonatomic, assign) BOOL shouldUsePreviousForce;
- (CGFloat)_pressure; 
- (void)_setPressure:(CGFloat)arg1 resetPrevious:(BOOL)arg2;
- (BOOL)_supportsForce;
- (CGFloat)_pressure;
@end

%group MGGetBoolAnswer
#define keyy(key_) CFEqual(key, CFSTR(key_))
extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
    if (keyy("eQd5mlz0BN0amTp/2ccMoA")|| keyy("SupportsForceTouch"))
        return YES;
    return %orig;
}
%end

%hook UITouch
%property (nonatomic, retain) NSNumber *pab_force;
%property (nonatomic, assign) BOOL shouldUsePreviousForce;

- (void)_setHidEvent:(IOHIDEventRef)event {
    %orig;
    self.pab_force = [NSNumber numberWithFloat:-1.0];
    [self _setPressure:[self _pressure] resetPrevious:NO];
}

-(void)_setPressure:(CGFloat)arg1 resetPrevious:(BOOL)arg2 {
    self.shouldUsePreviousForce = arg2;
    %orig([self _pressure], arg2);
}

- (CGFloat)_pressure {
    if (![self _supportsForce]) {
        return (CGFloat)0;
    }
    if ((CGFloat)[self.pab_force doubleValue] < 0) {
        if (self._hidEvent != nil) {

                    CGFloat densityValue = [[NSNumber numberWithFloat:IOHIDEventGetFloatValue(self._hidEvent, (IOHIDEventField)kIOHIDEventFieldDigitizerDensity)] doubleValue];
                    
                    if (densityValue == 0) {
                        return 0;
                    }

                    CGFloat radiusValue = [[NSNumber numberWithFloat:IOHIDEventGetFloatValue(self._hidEvent, (IOHIDEventField)kIOHIDEventFieldDigitizerMajorRadius)] doubleValue];
                    CGFloat qualityValue = [[NSNumber numberWithFloat:IOHIDEventGetFloatValue(self._hidEvent, (IOHIDEventField)kIOHIDEventFieldDigitizerQuality)] doubleValue];

                    densityValue = (lastDensity * .35) + (densityValue*(1.4 * SENSITIVITY) * (.75));
                    qualityValue = (lastQuality * .35) + (qualityValue*(3 * SENSITIVITY) * (.75));
                    radiusValue = (lastRadius * .35) + (radiusValue*(2.6 * SENSITIVITY) * (.65));

                    pressure = (((((((CGFloat)100*qualityValue)+((CGFloat)100*densityValue))/1.4)*(radiusValue+1))/14)*SENSITIVITY);

                    lastQuality = qualityValue;
                    lastDensity = densityValue;
                    lastRadius = radiusValue;

                    CGFloat forceToReturn = (pressure*4.5)*(pressure * 0.01);

                    if (forceToReturn > 0) self.pab_force = [NSNumber numberWithFloat:forceToReturn];
                    else self.pab_force = [NSNumber numberWithFloat:0];
                    return (CGFloat)[self.pab_force doubleValue];
        }
        self.pab_force = [NSNumber numberWithFloat:0];
        return 0;
    }
    return (CGFloat)[self.pab_force doubleValue];
}
%end

static void reloadPrefs() {
    NSString *mainIdentifier = [NSBundle mainBundle].bundleIdentifier;

    NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", @"com.ryannair05.peekable"];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];

    globalSettings = settings;

    SENSITIVITY = (CGFloat)[[globalSettings objectForKey:@"forceSensitivity"]?:@2.0 doubleValue];
    isEnabled = (BOOL)[[globalSettings objectForKey:@"Enabled"]?:@TRUE boolValue];

    NSDictionary *appSettings = [settings objectForKey:mainIdentifier];
    if (appSettings) {
        isEnabled = (BOOL)[[appSettings objectForKey:@"Enabled"]?:((NSNumber *)[NSNumber numberWithBool:isEnabled]) boolValue];
        SENSITIVITY = (CGFloat)[[appSettings objectForKey:@"forceSensitivity"]?:@(SENSITIVITY) doubleValue];
    }
}

%ctor {
    NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    reloadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
        (CFNotificationCallback)reloadPrefs,
        CFSTR("com.ryannair05.peekable.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    if ((isEnabled) && (![bundleIdentifier isEqualToString:@"com.apple.springboard"])) {
    %init;
    %init(MGGetBoolAnswer);
    }
}