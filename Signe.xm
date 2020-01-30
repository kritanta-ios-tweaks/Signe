//
// 	Signe.xm 
//	Signe - Numeric Gesture Recognition anywhere on your phone.
//
//	Read the README.md for more general information on this project
//
// 	This file contains the collection of hooks needed to get it working
//

#include "Signe.h"
#include "SigneManager.h"
#include "SigneUtilities.h"
#import <AudioToolbox/AudioToolbox.h>
#include "libcolorpicker.h"

static NSDictionary *prefs;

static int activationStyle = 0;
static BOOL _pfTweakEnabled = YES;

static BOOL signeActive = NO;

static BGNumberCanvas *canvas;

//=======================================
//
//	Main Group
//	#pragma Signe
//	
//  Hooks to get Signe working. 
//
//=======================================

%group Signe

void toggleSigne()
{
	// Intra-tweak method to toggle the editor.

	if (signeActive)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DeactivateSigne" object:nil];
		AudioServicesPlaySystemSound(1519);
	} 
	else 
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ActivateSigne" object:nil];
		AudioServicesPlaySystemSound(1519);
	}
	signeActive = !signeActive;
}


%hook SBHomeGrabberView

// Currently not working; Find a way to listen for tap on this bad boy and
// 		make it work as an activation method. 

-(void)_bounce
{
	%orig;
	if (activationStyle != 2) return;
	toggleSigne();
}

%end

// DISCUSS(_kritanta): I personally think this might be better off manually calling libsubstrate
//							I dislike how convoluted and unclear this is with logos, when not using logos
//							can simplify it significantly and make it clear what is going on. 

%hook SystemGestureView 

// "SystemGestureView" is not a real class. 
// This represents "FBSystemGestureView" on iOS 12 and "UISystemGestureView on iOS 13 Respectively". 
// We define the proper one in the %ctor. 
//
// Seeing as these classes are identical, there may be a better way to cast self and such. 
// 		It may end up just being a limitation of logos, though :p
//
// ------
//
// FB/UISystemGestureView is a nice little view that sits above a majority of the windows that
// 		are shown in iOS. It contains a ton of GestureRecognizers that are crucial to using iOS.
// 		If you're curious as to how crucial, hide UI/FBSystemGestureWindow and see how much you're
// 		able to do :)
//
// Here, we simply use it to inject the modified BGNumberCanvas as a subview of this view. 
// this hook also contains the crucial methods of hiding and showing this canvas. 

%property (nonatomic, retain) BGNumberCanvas *recognitionCanvas;
%property (nonatomic, assign) BOOL injected; 

- (void)layoutSubviews
{
    %orig;

	// Since FBSystemGestureView and UISystemGestureView are identical in all but name, I've declared
	// 		FBSystemGestureView as a subclass of the latter, and, to get things to compile without explicitly
	//		creating hooks for both views, we cast them to one of the two classes. 
	FBSystemGestureView *selfView = (((FBSystemGestureView *)self));
    if (!selfView.injected) 
    {
		// See the README for information on what BGNumberCanvas is and how we use it. 
		selfView.recognitionCanvas = [[BGNumberCanvas alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		canvas = selfView.recognitionCanvas;
		selfView.recognitionCanvas.hidden = YES;
		[selfView addSubview:selfView.recognitionCanvas];
    	[selfView.recognitionCanvas setValue:@YES forKey:@"deliversTouchesForGesturesToSuperview"];
        [[NSNotificationCenter defaultCenter] addObserver:selfView selector:@selector(activateSigne) name:@"ActivateSigne" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:selfView selector:@selector(deactivateSigne) name:@"DeactivateSigne" object:nil];
		selfView.injected = YES;
    }
}

%new
- (void)activateSigne
{
    [((FBSystemGestureView *)self).recognitionCanvas setValue:@NO forKey:@"deliversTouchesForGesturesToSuperview"];
	((FBSystemGestureView *)self).recognitionCanvas.hidden = NO;
}

%new
- (void)deactivateSigne
{
    [((FBSystemGestureView *)self).recognitionCanvas setValue:@YES forKey:@"deliversTouchesForGesturesToSuperview"];
	((FBSystemGestureView *)self).recognitionCanvas.hidden = YES;
}

%end


%hook SpringBoard

// The Springboard hook contains a few of the vital recognizers for activating the canvas.
// Since I've code-golfed a bit of it, I'll thoroughly explain what I do here. 


-(_Bool)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1 
{
	// Although the tweak isn't injected in the first place when disabled, if a user toggles enable, immediately stop listening for
	//		the activation gestures. 
	if (!_pfTweakEnabled) return %orig;

	// type = 101 -> Home button
	// type = 102 -> Vol up
	// type = 103 -> Vol down
	// type = 104 -> Power button
    
	// force = 0 -> button released
	// force = 1 -> button pressed


	// We only ever listen for multiple button presses. If only one is being pressed, ignore. 
	if ([arg1.allPresses.allObjects count] <= 1) return %orig;

	// Shorten these. 
	UIPress *press0 = arg1.allPresses.allObjects[0];
	UIPress *press1 = arg1.allPresses.allObjects[1];

	
	// It's worth noting, the presses may be sent in any order to this method, and you should not rely on them
	// 		being in a specific order, as it will not work around 50% of the time. 


	if (activationStyle == 0) // Activation Style - Volume Down + Power
	{
		// Add the press types together. 103+104 is the maximum possible combination of any of the presses. 
		// So, here, we add them together. If they, no matter the order, are 103 and 104, the left side will
		// 		evaluate to true. 

		//The right side is fairly simple. If they're both being held down, true
		if (press0.type + press1.type == 207 && press1.force + press0.force == 2) 
		{
			toggleSigne();
			return NO;
		}
	}
	else if (activationStyle == 1) // Holding volume down and volume up at the same time
	{
		// This is somewhat rediculous, I feel bad for even writing it, but w/e

		// Best way I can explain is by example:
		//
		// 101 minus 102 will be negative. If you cast a negative to an unsigned integer, it will underflow and become an
		//		extremely large positive number. 
		// 102 and 103 minus 102 (0 and 1) will not be affected by the unsigned int cast. 
		// 104 - 102 is 2, which is greater than 1. 

		// So what you see below is the golfiest way I could find to check if both numbers were either 102 or 103. 

		if (((unsigned)((press1.type) - 102)) <= 1 && ((unsigned)((press0.type) - 102)) <= 1 && press0.force + press1.force == 2) 
		{
			toggleSigne();
			return NO;
		}
	}

	return %orig;
}

%new 
-(void)volup{}

%end

%hook SigneManager

// Due to past experiences in previous projects, I want to keep a singular method as the only one posting notifications to important things
// Since we need to de-activate the view from our canvas object, lets give our centralized manager a way to properly toggle the view. 

// So yes, if you were curious, you can hook your own classes, and IMO this is a perfectly valid use case. 

-(void)toggleEditor
{
	%orig;
	toggleSigne();
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

static void processNumber(NSString *number, NSString *numberButLessVerbose) // TODO: Find a better way to do this
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
	activationStyle = [[prefs objectForKey:@"activationStyle"] intValue] ?: 0;

	NSString *colorFromKey = [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/me.kritanta.signecolors.plist"] objectForKey:@"strokeColor"]; 

	UIColor *strokeColor = LCPParseColorString(colorFromKey, @"#626ECC");

	int strokeSize = [[prefs objectForKey:@"strokeSize"] intValue] ?: 10;

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
	[[SigneManager sharedManager] setStrokeColor:strokeColor];
	[[SigneManager sharedManager] setStrokeSize:strokeSize];

	if (canvas)
	{
		[canvas setup];
	}
	
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
	Class gestureWindow;
    if (@available(iOS 13, *)) {
        gestureWindow = NSClassFromString(@"UISystemGestureView");
    }
    else {
        gestureWindow = NSClassFromString(@"FBSystemGestureView");
    }
	if (_pfTweakEnabled) 
		%init(Signe, SystemGestureView=gestureWindow);
}
