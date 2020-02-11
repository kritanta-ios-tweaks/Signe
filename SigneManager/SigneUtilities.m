#include "SigneUtilities.h"
#include "SigneManager.h"
#include "../Signe.h"
#import "../MediaRemote.h"

@implementation SigneUtilities


+ (instancetype)sharedUtilities
{
    static SigneUtilities *sharedUtilities = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedUtilities = [[[self class] alloc] init];
    });
    return sharedUtilities;
}


- (instancetype)init
{
    self = [super init];

    if (self) {
        // Setup our commands, commandKeys initialization and shouldContinueAfterAlert set to NO (false)
        /*
        Play Song(?) / check
        Pause Song / check
        Skip song
        Previous Song
        Airplane mode / check
        Turn on data / check*/

        self.commands = [@{
            @"sbreload": [NSValue valueWithPointer:@selector(sbreload)],
            @"respring": [NSValue valueWithPointer:@selector(respring)],
            @"safemode": [NSValue valueWithPointer:@selector(enterSafeMode)],
            @"uicache": [NSValue valueWithPointer:@selector(runUICache)],
            @"wifi": [NSValue valueWithPointer:@selector(setWifiStatus)],
            @"bluetooth": [NSValue valueWithPointer:@selector(setBTStatus)],
            @"cellular": [NSValue valueWithPointer:@selector(setCellularStatus)],
            @"airplane": [NSValue valueWithPointer:@selector(setAirplaneMode)],
            @"playPauseMedia": [NSValue valueWithPointer:@selector(playPauseMedia)],
            @"skipMedia": [NSValue valueWithPointer:@selector(skipMedia)],
            @"previousMedia":[NSValue valueWithPointer:@selector(previousMedia)],
            @"siri": [NSValue valueWithPointer:@selector(toggleSiri)],
            @"controlCenter": [NSValue valueWithPointer:@selector(presentControlCenter)],
            @"notificationCenter": [NSValue valueWithPointer:@selector(presentNotificationCenter)],
            @"flashlight": [NSValue valueWithPointer:@selector(toggleFlashlight)],
        } mutableCopy];
        self.commandKeys = [[NSMutableDictionary alloc] init];
        self.shouldContinueAfterAlert = NO;

        self.wifiEnabled = [[objc_getClass("SBWiFiManager") sharedInstance] wiFiEnabled];
        self.bluetoothEnabled = [[objc_getClass("BluetoothManager") sharedInstance] enabled];
        self.cellularEnabled = [[objc_getClass("VideosPlaybackSettings") sharedSettings] isCellularDataEnabled];
        self.airplaneModeEnabled = [[[objc_getClass("RadiosPreferences") alloc] init] airplaneMode];
        self.flashlight = [[AVFlashlight alloc] init];
        self.flashlightEnabled = NO;
        
    }

    return self;
}


-(BOOL)keyHasCommand:(NSString *)key {
    // Return YES if the command exists for our key (numbers 0-9)
    return ([self.commandKeys objectForKey:key] || [[self.commandKeys objectForKey:key] isEqualToString:@""]);
}


#pragma mark Commands

- (void)sbreload 
{
    if (self.shouldContinueAfterAlert) {
        pid_t pid;
        int status;

        const char *args[] = {"sbreload", NULL, NULL, NULL};
        posix_spawn(&pid, "usr/bin/sbreload", NULL, NULL, (char *const *)args, NULL);
        waitpid(pid, &status, WEXITED);
    }
    else 
    {
        [self showAlertController:@"Are you sure you want to respring?" selector:@selector(sbreload)];
    }
}


- (void)respring
{
    if (self.shouldContinueAfterAlert) 
    {
        pid_t pid;
        int status;

        const char* args[] = {"killall", "-9", "backboardd", NULL};
        posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
        waitpid(pid, &status, WEXITED);
    }
    else 
    {
        // Show the alert, pass the selector to this method
        [self showAlertController:@"Are you sure you want to respring?" selector:@selector(respring)];
    }
    
}


- (void)enterSafeMode 
{
    if (self.shouldContinueAfterAlert)
    {
        pid_t pid;
        int status;

        const char* args[] = {"killall", "-SEGV", "SpringBoard", NULL};
        posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
        waitpid(pid, &status, WEXITED);
    }
    else 
    {
        // Show the alert, pass the selector to this method
        [self showAlertController:@"Are you sure you want to enter safe mode?" selector:@selector(enterSafeMode)];
    }
    
}


- (void)runUICache 
{
    if (self.shouldContinueAfterAlert) 
    {
        pid_t pid;
        int status;

        const char* args[] = {"uicache", "-a", "-r", NULL};
        posix_spawn(&pid, "/usr/bin/uicache", NULL, NULL, (char* const*)args, NULL);
        waitpid(pid, &status, WEXITED);
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 20.0, false);
    }
    else 
    {
        // Show the alert, pass the selector to this method
        [self showAlertController:@"Are you sure you want to run uicache? Your device will respring after a moment." selector:@selector(runUICache)];
    }
}

- (void)setWifiStatus
{
    if (self.wifiEnabled)
    {
        [[objc_getClass("SBWiFiManager") sharedInstance] setWiFiEnabled:NO];
        self.wifiEnabled = NO;
    }
    else
    {
        [[objc_getClass("SBWiFiManager") sharedInstance] setWiFiEnabled:YES];
        self.wifiEnabled = YES;
    }
}

-(void)setBTStatus 
{   
    BluetoothManager *bManager = (BluetoothManager *)[objc_getClass("BluetoothManager") sharedInstance];
    if (self.bluetoothEnabled)
    {
        [bManager setEnabled:NO];
        [bManager setPowered:NO];
        self.bluetoothEnabled = NO;
    }
    else 
    {
        [bManager setEnabled:YES];
        [bManager setPowered:YES];
        self.bluetoothEnabled = YES;
    }

}

-(void)setCellularStatus 
{
    if (self.cellularEnabled)
    {
        [[objc_getClass("VideosPlaybackSettings") sharedSettings] setCellularDataEnabled:NO];
        self.cellularEnabled = NO;

    }
    else
    {
        [[objc_getClass("VideosPlaybackSettings") sharedSettings] setCellularDataEnabled:YES];
        self.cellularEnabled = YES;

    }
}

-(void)setAirplaneMode 
{
    if (self.airplaneModeEnabled) 
    {
        [[[objc_getClass("RadiosPreferences") alloc] init] setAirplaneMode:NO];
        self.airplaneModeEnabled = NO;
    }
    else 
    {
        [[[objc_getClass("RadiosPreferences") alloc] init] setAirplaneMode:YES];
        self.airplaneModeEnabled = YES;
    }
}


-(void)playPauseMedia 
{
    MRMediaRemoteSendCommand(kMRTogglePlayPause, 0);
}

-(void)skipMedia 
{
    MRMediaRemoteSendCommand(kMRNextTrack, 0);
}

-(void)previousMedia
{
    MRMediaRemoteSendCommand(kMRPreviousTrack, 0);
}

-(void)toggleSiri 
{
    SBAssistantController *ac = [objc_getClass("SBAssistantController")sharedInstance];
    [ac handleSiriButtonDownEventFromSource:1 activationEvent:1];
    [ac handleSiriButtonUpEventFromSource:1];
}

-(void)presentControlCenter
{
    if ([[objc_getClass("SBControlCenterController") sharedInstance] isVisible]) 
    {
        [[objc_getClass("SBControlCenterController") sharedInstance] dismissAnimated:YES];
    }
    else 
    {
        [[objc_getClass("SBControlCenterController") sharedInstance] presentAnimated:YES];
    }
    
}

-(void)presentNotificationCenter 
{   
    if ([[objc_getClass("SBCoverSheetPresentationManager") sharedInstance] isVisible]) 
    { // If visibile
        [[objc_getClass("SBCoverSheetPresentationManager") sharedInstance] setCoverSheetPresented:NO animated:YES withCompletion:nil];
    }
    else 
    { // If not visible
        [[objc_getClass("SBCoverSheetPresentationManager") sharedInstance] setCoverSheetPresented:YES animated:YES withCompletion:nil];
    }
    
}

-(void)toggleFlashlight
{
    if (self.flashlightEnabled) // if on
    {
        [self.flashlight setFlashlightLevel:0 withError:nil];
        self.flashlightEnabled = NO;
    }
    else // if off
    {
        [self.flashlight setFlashlightLevel:1 withError:nil];
        self.flashlightEnabled = YES;
    }
}

#pragma mark Set Commands

- (void)setCommandToRun:(NSString *)command forKey:(NSString *)key
{
    // Set the command for the key (numbers 0-9)
    [self.commandKeys setValue:command forKey:key];
    if ([command isEqualToString:@""]) return;
    [[SigneManager sharedManager] setBundleToOpen:@"" forKey:key];
}

- (NSString *)getCommandForKey:(NSString *)key
{
    // Get the actual command by the key (numbers 0-9) and return it
    NSString *commandKey = [self.commandKeys objectForKey:key] ?: nil;

    return commandKey;
}

- (void)performCommandForKey:(NSString *)commandKey
{
    // Get the selector for our command by the commandKey and perform the command's selector
    SEL commandToRun = [[self.commands objectForKey:commandKey] pointerValue];
    if (commandToRun == nil) return;
    SuppressPerformSelectorLeakWarning([self performSelector:commandToRun]);
}

- (void)showAlertController:(NSString *)alertMessage selector:(SEL)method
{
    // Setup a UIWindow to show the Alert Controller, because this class does not subclass UIViewController
    UIWindow *topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    topWindow.rootViewController = [UIViewController new];
    topWindow.windowLevel = UIWindowLevelAlert + 1;


    // Setup the Alert Controller and its actions
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"WARNING" 
                                message:alertMessage preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
         handler:^(UIAlertAction *action) {
            self.shouldContinueAfterAlert = YES;
            // Call the method that has been passed as selector, if the user clicks yes.
            // Might not be the best way?
            SuppressPerformSelectorLeakWarning([self performSelector:method]);
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
         handler:^(UIAlertAction *action) {
            self.shouldContinueAfterAlert = NO;
    }];

    [alertController addAction:yesAction];
    [alertController addAction:cancelAction];

    // Show the top window and present our view controller
    [topWindow makeKeyAndVisible];
    [topWindow.rootViewController presentViewController:alertController animated:YES completion:nil];

}

@end