#include "BGNumberCanvas.h"
#include "Signe.h"
#include "SigneManager.h"
#include "SigneUtilities.h"
#import <AudioToolbox/AudioToolbox.h>

static NSDictionary *prefs;
static NSString *_activationGesture;

static BOOL activationStyle = 0;
static BOOL _pfTweakEnabled = YES;
//static BOOL _pfSiriReplaced = NO;
static CALayer *borderLayer;

#define kBorderWidth 3.0
#define kCornerRadius 5.0

@interface UISystemGestureView : UIView

@property (nonatomic, retain) BGNumberCanvas *BGCanvas;
- (void)insertCanvas;
@property (nonatomic, retain) NSData *initial;
@property (nonatomic, assign) BOOL injected;
@property (nonatomic, retain) CALayer *borderLayer;
@end

@interface FBSystemGestureView : UISystemGestureView
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

		borderLayer = [CALayer layer];
		CGRect borderFrame = CGRectMake(0, 0, (self.frame.size.width),(self.frame.size.height));
		[borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
		[borderLayer setFrame:borderFrame];
		[borderLayer setCornerRadius:kCornerRadius];
		[borderLayer setBorderWidth:kBorderWidth];
		[borderLayer setBorderColor:[[UIColor redColor] CGColor]];
		[self.layer addSublayer:borderLayer];
		borderLayer.hidden = YES;
    }
}



%new
- (void)activateSigne
{
    [self.BGCanvas setValue:@NO forKey:@"deliversTouchesForGesturesToSuperview"];
	self.BGCanvas.hidden = NO;
	borderLayer.hidden = NO;
	
	
}

%new
- (void)deactivateSigne
{
    [self.BGCanvas setValue:@YES forKey:@"deliversTouchesForGesturesToSuperview"];
	self.BGCanvas.hidden = YES;
	borderLayer.hidden = YES;
	
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
	// If volume up + down or volume down + up has been pressed
	if ([_activationGesture isEqualToString:@"volUpAndDown"]) 
	{
		if (arg1.allPresses.allObjects[0].type == 102 && force == 1 && arg1.allPresses.allObjects[1].type == 103 && arg1.allPresses.allObjects[1].force == 1 || arg1.allPresses.allObjects[0].type == 103 && force == 1 && arg1.allPresses.allObjects[1].type == 102 && arg1.allPresses.allObjects[1].force == 1) 
		{
			[self activateTouchRecognizer];
			return NO;
		}
	}
	else if ([_activationGesture isEqualToString:@"volDownPower"])
	{
		if (arg1.allPresses.allObjects[0].type >= 103 && force == 1 && arg1.allPresses.allObjects[1].type >= 103 && arg1.allPresses.allObjects[1].force == 1) //Power PRESSED
		{
			[self activateTouchRecognizer];
			return NO;
		}
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

static void processNumber(NSString *number, NSString *numberButLessVerbose) // I'm sorry, this needs fixed -kr
{
	NSInteger numberMode = [[prefs objectForKey:[NSString stringWithFormat:@"actionMode%@", number]] intValue] ?:0;
	if (numberMode == 0)
		return;

	if (numberMode == 1)
		{
			NSString *option = [prefs objectForKey:[NSString stringWithFormat:@"%@EnabledApp", number]]?:@"";
			[[SigneManager sharedManager] setBundleToOpen:option forKey:numberButLessVerbose];
		}
		else if (numberMode == 2)
		{
			NSString *option = [prefs objectForKey:[NSString stringWithFormat:@"%@URL", number]]?:@"";
			[[SigneManager sharedManager] setURLToOpen:option forKey:numberButLessVerbose]; 
		}
		else 
		{
			NSString *option = [prefs objectForKey:[NSString stringWithFormat:@"%@CMD", number]]?:@"";
			[[SigneUtilities sharedUtilities] setCommandToRun:option forKey:numberButLessVerbose];
		}
}

static void preferencesChanged() 
{
    CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
    reloadPrefs();
	NSLog(@"Signe: Loading Preferences");

	BOOL _pfDrawingEnabled = boolValueForKey(@"drawingEnabled", YES);
	_pfTweakEnabled = boolValueForKey(@"enabled", YES);
	_activationGesture = [prefs objectForKey:@"activationGestureKey"] ?: @"";
	
	//_pfSiriReplaced = boolValueForKey(@"siriReplaced", NO);
	//NSLog(@"Signe: ACTIVATION GESTURE: %@", _activationGesture);
	//NSLog(@"Signe: %@ -%@ -%@ -%@ -%@ -%@ -%@ -%@ -%@ -%@ -", zero, one, two, three, four, five, six, seven, eight, nine);

	processNumber(@"Zero", @"0");
	processNumber(@"One", @"1");
	processNumber(@"Two", @"2");
	processNumber(@"Three", @"3");
	processNumber(@"Four", @"4");
	processNumber(@"Five", @"5");
	processNumber(@"Six", @"6");
	processNumber(@"Seven", @"7");
	processNumber(@"Eight", @"8");
	processNumber(@"Nine", @"9");

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
