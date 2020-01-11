#include "BGNumberCanvas.h"
#import <AudioToolbox/AudioToolbox.h>

@interface UISystemGestureView : UIView

@property (nonatomic, retain) BGNumberCanvas *BGCanvas;
- (void)insertCanvas;
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
%hook UISystemGestureView 

// iOS 13+ Support

/* ([[[[UIApplication sharedApplication] volumeHardwareButton] buttonActions] _handleVolumeIncreaseUp] && [[[[UIApplication sharedApplication] volumeHardwareButton] buttonActions] _handleVolumeDecreaseUp]) */

%property (nonatomic, retain) BGNumberCanvas *BGCanvas;
%property (nonatomic, assign) BOOL injected; // im lazy, yes so i've seen


- (void)layoutSubviews
{
    %orig;
    if (!self.injected) 
    {
		self.BGCanvas = [[BGNumberCanvas alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
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
	[self addSubview:self.BGCanvas];
	//self.BGCanvas.hidden = NO;
}

%new
- (void)deactivateSigne
{
    [self.BGCanvas setValue:@YES forKey:@"deliversTouchesForGesturesToSuperview"];
	[self.BGCanvas clear];
	[self.BGCanvas removeFromSuperview];
	self.BGCanvas = nil;
	self.BGCanvas = [[BGNumberCanvas alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}


%end



%hook FBSystemGestureView 

// <= iOS 12 Support


%property (nonatomic, retain) BGNumberCanvas *BGCanvas;
%property (nonatomic, assign) BOOL injected; // im lazy, yes so i've seen


- (void)layoutSubviews
{
    %orig;
    if (!self.injected) 
    {
		self.BGCanvas = [[BGNumberCanvas alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    	[self.BGCanvas setValue:@YES forKey:@"deliversTouchesForGesturesToSuperview"];
		[self addSubview:self.BGCanvas];
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
	[self.BGCanvas clear];
	[self.BGCanvas setHidden:YES];
}



%end


@interface SpringBoard : NSObject
-(BOOL)_handlePhysicalButtonEvent:(id)arg1;
@property (nonatomic, assign) BOOL signeActive;
@property (nonatomic, retain) NSTimer *pressedTimer;
@end

%hook SpringBoard

%property (nonatomic, assign) BOOL signeActive;
%property (nonatomic, retain) NSTimer *pressedTimer;

-(_Bool)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1 
{
	int type = arg1.allPresses.allObjects[0].type; 
	int force = arg1.allPresses.allObjects[0].force;

	// type = 101 -> Home button
	// type = 102 -> vol up
	// type = 103 -> vol down
	// type = 104 -> Power button
    

	// force = 0 -> button released
	// force = 1 -> button pressed
	
	if (type == 103 && force == 1) //Power PRESSED
	{
		if (self.pressedTimer == nil) self.pressedTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(activateTouchRecognizer) userInfo:nil repeats:NO];
	}

	if (type == 103 && force == 0) //Power RELEASED
	{
		if (self.pressedTimer != nil) {
			[self.pressedTimer invalidate];
			self.pressedTimer = nil;
		}
	}

	return %orig;
}

%new 
- (void)activateTouchRecognizer
{
	if (!self.signeActive) // If signe not active
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