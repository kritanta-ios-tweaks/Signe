
#include "Signe.h"
#include "SigneManager.h"
#include "SigneUtilities.h"
#import <AudioToolbox/AudioToolbox.h>

static NSDictionary *prefs;

static BOOL activationStyle = 0;
static BOOL _pfTweakEnabled = YES;

static BOOL signeActive = NO;

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

%hook SystemGestureView 

// "SystemGestureView" is not a real class. 
// This represents "FBSystemGestureView" on iOS 12 and "UISystemGestureView on iOS 13 Respectively". 
// We define the proper one in the %ctor. 
//
// Seeing as these classes are identical, there may be a better way to cast self and such. 
// 		It may end up just being a limitation of logos, though :p

%property (nonatomic, retain) BGNumberCanvas *recognitionCanvas;
%property (nonatomic, assign) BOOL injected; 

- (void)layoutSubviews
{
    %orig;

	FBSystemGestureView *selfView = (((FBSystemGestureView *)self));
    if (!selfView.injected) 
    {
		selfView.recognitionCanvas = [[BGNumberCanvas alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		selfView.recognitionCanvas.hidden = YES;
		[selfView addSubview:selfView.recognitionCanvas];
    	[selfView.recognitionCanvas setValue:@YES forKey:@"deliversTouchesForGesturesToSuperview"];
        [[NSNotificationCenter defaultCenter] addObserver:selfView selector:@selector(activateSigne) name:@"ActivateSigne" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:selfView selector:@selector(deactivateSigne) name:@"DeactivateSigne" object:nil];
		selfView.injected = YES;
		/*
		borderLayer = [CALayer layer];
		CGRect borderFrame = CGRectMake(0, 0, (self.frame.size.width),(self.frame.size.height));
		[borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
		[borderLayer setFrame:borderFrame];
		[borderLayer setCornerRadius:kCornerRadius];
		[borderLayer setBorderWidth:kBorderWidth];
		[borderLayer setBorderColor:[[UIColor redColor] CGColor]];
		[self.layer addSublayer:borderLayer];
		borderLayer.hidden = YES;
		*/
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

	// type = 101 -> Home button
	// type = 102 -> vol up
	// type = 103 -> vol down
	// type = 104 -> Power button
    

	// force = 0 -> button released
	// force = 1 -> button pressed
	if ([arg1.allPresses.allObjects count] <= 1) return %orig;
	UIPress *press0 = arg1.allPresses.allObjects[0];
	UIPress *press1 = arg1.allPresses.allObjects[1];
	// If volume up + down or volume down + up has been pressed
	;
	if (activationStyle == 1) 
	{
		if (((unsigned)((press1.type) - 102)) <= 1 && ((unsigned)((press0.type) - 102)) <= 1 && press0.force + press1.force == 2) 
		{
			toggleSigne();
			return NO;
		}
	}
	else if (activationStyle == 0)
	{
		if (press0.type + press1.type == 207 && press1.force + press0.force == 2) 
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

// This is either genius or horrible. 

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
