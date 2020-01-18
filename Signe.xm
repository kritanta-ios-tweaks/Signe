#include "BGNumberCanvas.h"
#include "Signe.h"
#include "SigneManager.h"
#include "SigneUtilities.h"
#import <AudioToolbox/AudioToolbox.h>

static NSDictionary *prefs;
static NSArray *utilityCommands;
static BOOL activationStyle = 0;
static BOOL _pfTweakEnabled = YES;

@interface UISystemGestureView : UIView

@property (nonatomic, retain) BGNumberCanvas *BGCanvas;
- (void)insertCanvas;
@property (nonatomic, retain) NSData *initial;
@property (nonatomic, assign) BOOL injected;
@end

@interface FBSystemGestureView : UISystemGestureView
@end


@interface bac 
-(BOOL)_handleVolumeDecreaseUp;
-(BOOL)_handleVolumeIncreaseUp;
@end
@interface volb
-(bac *)buttonActions;
@end
@interface UIApplication (Signe)
-(volb *)volumeHardwareButton;
@end

%group Signe

%hook UISystemGestureView 

// iOS 13+ Support

/* ([[[[UIApplication sharedApplication] volumeHardwareButton] buttonActions] _handleVolumeIncreaseUp] && [[[[UIApplication sharedApplication] volumeHardwareButton] buttonActions] _handleVolumeDecreaseUp]) */

%property (nonatomic, retain) BGNumberCanvas *BGCanvas;
%property (nonatomic, retain) NSData *initial;
%property (nonatomic, assign) BOOL injected;  

- (void)layoutSubviews
{
    %orig;
    if (!self.injected) 
    {
		self.BGCanvas = [[BGNumberCanvas alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		self.BGCanvas.hidden = YES;
		self.initial = [NSKeyedArchiver archivedDataWithRootObject: self.BGCanvas];
		[self addSubview:self.BGCanvas];
    	[self.BGCanvas setValue:@YES forKey:@"deliversTouchesForGesturesToSuperview"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activateSigne) name:@"ActivateSigne" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deactivateSigne) name:@"DeactivateSigne" object:nil];
		self.injected = YES;
    }
}

%new
- (void)activateSigne
{	
    [self.BGCanvas setValue:@NO forKey:@"deliversTouchesForGesturesToSuperview"];
	self.BGCanvas.hidden = NO;
	//
}

%new
- (void)deactivateSigne
{
    [self.BGCanvas setValue:@YES forKey:@"deliversTouchesForGesturesToSuperview"];
	self.BGCanvas.hidden = YES;
}


%end



%hook FBSystemGestureView 

// <= iOS 12 Support


%property (nonatomic, retain) BGNumberCanvas *BGCanvas;
%property (nonatomic, assign) BOOL injected; 

- (void)layoutSubviews
{
    %orig;
    if (!self.injected) 
    {
		self.BGCanvas = [[BGNumberCanvas alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		self.BGCanvas.hidden = YES;
		[self addSubview:self.BGCanvas];
    	[self.BGCanvas setValue:@YES forKey:@"deliversTouchesForGesturesToSuperview"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activateSigne) name:@"ActivateSigne" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deactivateSigne) name:@"DeactivateSigne" object:nil];
		self.injected = YES;
    }
}

%new
- (void)activateSigne
{
    [self.BGCanvas setValue:@NO forKey:@"deliversTouchesForGesturesToSuperview"];
	self.BGCanvas.hidden = NO;
}

%new
- (void)deactivateSigne
{
    [self.BGCanvas setValue:@YES forKey:@"deliversTouchesForGesturesToSuperview"];
	self.BGCanvas.hidden = YES;
	
}


%end


@interface SpringBoard : UIApplication
-(BOOL)_handlePhysicalButtonEvent:(id)arg1;
- (void)activateTouchRecognizer;
@property (nonatomic, assign) BOOL signeActive;
@property (nonatomic, assign) BOOL volDownActive;
@property (nonatomic, retain) NSTimer *pressedTimer;
@end

%hook SpringBoard

%property (nonatomic, assign) BOOL signeActive;
%property (nonatomic, retain) NSTimer *pressedTimer;
%property (nonatomic, assign) BOOL volDownActive;

-(_Bool)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1 
{
	if (!_pfTweakEnabled) return %orig;
	int type = arg1.allPresses.allObjects[0].type; 
	int force = arg1.allPresses.allObjects[0].force;

	NSLog(@"Signe: %d - %d", type, force);

	// type = 101 -> Home button
	// type = 102 -> vol up
	// type = 103 -> vol down
	// type = 104 -> Power button
    

	// force = 0 -> button released
	// force = 1 -> button pressed
	if ([arg1.allPresses.allObjects count] <= 1) return %orig;
	if (arg1.allPresses.allObjects[0].type >= 103 && force == 1 && arg1.allPresses.allObjects[1].type >= 103 && arg1.allPresses.allObjects[1].force == 1) //Power PRESSED
	{
		[self activateTouchRecognizer];
		return NO;
	}

	/* 	if (type == 103 && force == 1) //Power PRESSED
	{
		if (self.pressedTimer == nil) self.pressedTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(activateTouchRecognizer) userInfo:nil repeats:NO];
	}

	if (type == 103 && force == 0) //Power RELEASED
	{
		if (self.pressedTimer != nil) {
			[self.pressedTimer invalidate];
			self.pressedTimer = nil;
		}
	} */

	return %orig;
}

%new 
-(void)volup{}

%new 
- (void)activateTouchRecognizer
{
	if (!self.signeActive || self.signeActive == nil) // If signe not active
	{
		self.signeActive = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ActivateSigne" object:nil];
		AudioServicesPlaySystemSound(1519);
	}
	else // If signe is active
	{
		self.signeActive = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DeactivateSigne" object:nil];
		AudioServicesPlaySystemSound(1519);
	}
}

%end

%end

static void *observer = NULL;

static void reloadPrefs() 
{
    if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) 
    {
        CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

        if (keyList) 
        {
            prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));

            if (!prefs) 
            {
                prefs = [NSDictionary new];
            }
            CFRelease(keyList);
        }
    } 
    else 
    {
        prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
    }
}


static BOOL boolValueForKey(NSString *key, BOOL defaultValue) 
{
    return (prefs && [prefs objectForKey:key]) ? [[prefs objectForKey:key] boolValue] : defaultValue;
}

static BOOL isURL(NSString *keyValue)
{
	return [keyValue containsString:@"http"];
}

static BOOL isCommand(NSString *keyValue) 
{
	return [utilityCommands containsObject:keyValue] ?: NO;
}

static void preferencesChanged() 
{
    CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
    reloadPrefs();
	NSLog(@"Signe: Loading Preferences");

	BOOL _pfDrawingEnabled = boolValueForKey(@"drawingEnabled", YES);
	_pfTweakEnabled = boolValueForKey(@"enabled", YES);

	NSString *zero = [prefs objectForKey:@"zero"]?:@"";
	NSString *one = [prefs objectForKey:@"one"]?:@"";
	NSString *two = [prefs objectForKey:@"two"]?:@"";
	NSString *three = [prefs objectForKey:@"three"]?:@"";
	NSString *four = [prefs objectForKey:@"four"]?:@"";
	NSString *five = [prefs objectForKey:@"five"]?:@"";
	NSString *six = [prefs objectForKey:@"six"]?:@"";
	NSString *seven = [prefs objectForKey:@"seven"]?:@"";
	NSString *eight = [prefs objectForKey:@"eight"]?:@"";
	NSString *nine = [prefs objectForKey:@"nine"]?:@"";

	//NSLog(@"Signe: %@ -%@ -%@ -%@ -%@ -%@ -%@ -%@ -%@ -%@ -", zero, one, two, three, four, five, six, seven, eight, nine);

	NSArray *options = [NSArray arrayWithObjects:zero,one,two,three,four,five,six,seven,eight,nine, nil];
	utilityCommands = [NSArray arrayWithObjects:@"sbreload", @"respring", @"safemode", @"uicache", @"wifi", @"bluetooth"];

	int i = 0;
	for (NSString *option in options)
	{
		NSLog(@"Signe: %@ - %d", option, i);
		if (isURL(option))
		{
			[[SigneManager sharedManager] setURLToOpen:option forKey:[[NSNumber numberWithInt:i] stringValue]]; 
		}
		else if (isCommand(option))
		{
			[[SigneUtilities sharedUtilities] setCommandToRun:option forKey:[[NSNumber numberWithInt:i] stringValue]];
		}
		else 
		{
			[[SigneManager sharedManager] setBundleToOpen:option forKey:[[NSNumber numberWithInt:i] stringValue]];
		}
		i++;
	}

	[[SigneManager sharedManager] setURLToOpen:@"https://patreon.com/KritantaDev" forKey:@"V"]; 

	[[SigneManager sharedManager] setShouldDrawCharacters:_pfDrawingEnabled];
	[[SigneManager sharedManager] setStrokeColor:[UIColor colorWithRed:0.28 green:0.80 blue:0.64 alpha:1.0]];
	[[SigneManager sharedManager] setStrokeSize:10];
}

#pragma mark ctor

%ctor 
{
    [SigneManager sharedManager];

    preferencesChanged();

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        &observer,
        (CFNotificationCallback)preferencesChanged,
        (CFStringRef)@"me.kritanta.signeprefs/Prefs",
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately
    );
	if (_pfTweakEnabled) 
		%init(Signe);
}
