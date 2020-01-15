#include "SigneManager.h"



@interface UIApplication (Signe)
- (void)activateTouchRecognizer;
@property (nonatomic, assign) BOOL signeActive;
- (BOOL)launchApplicationWithIdentifier:(id)arg suspended:(BOOL)arg2;
@end

@implementation SigneManager

+ (instancetype)sharedManager
{
    static SigneManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
    });
    return sharedManager;
}
- (instancetype)init
{
    self = [super init];

    if (self) {
        self.actions = [[NSMutableDictionary alloc] init];
        self.actionLocations = [[NSMutableDictionary alloc] init];
        self.shouldDrawCharacters = YES;
        self.shouldContinueAfterAlert = NO;

    }

    return self;
}


- (void)openApplication:(NSString *)location
{
    [[UIApplication sharedApplication] launchApplicationWithIdentifier:location suspended:NO];
}

- (void)openURL:(NSString *)location
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:location] options:@{} completionHandler:nil];
}

- (void)runCommand:(NSString *)location 
{   
    if ([location isEqualToString:@"sbreload"]) 
    {
        [self respring:[NSNumber numberWithBool:YES]];
    }
    else if ([location isEqualToString:@"respring"]) 
    {
        [self respring:[NSNumber numberWithBool:NO]];
    }
    else if ([location isEqualToString:@"safemode"])
    {
        [self enterSafeMode];
    }
    else if ([location isEqualToString:@"uicache"])
    {
        [self runUICache];
    } 
}

- (void)respring:(NSNumber *)sbreload 
{
    if (self.shouldContinueAfterAlert) 
    {
        pid_t pid;
        int status;

        if ([sbreload boolValue])  // If sbreload = YES
        {
            const char *args[] = {"sbreload", NULL, NULL, NULL};
            posix_spawn(&pid, "usr/bin/sbreload", NULL, NULL, (char *const *)args, NULL);
            waitpid(pid, &status, WEXITED);
        }
        else 
        {
            const char* args[] = {"killall", "-9", "backboardd", NULL};
            posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
            waitpid(pid, &status, WEXITED);
        }
    }
    else 
    {
        // Show the alert, pass the selector to this method and the object
        // THIS IS A HACKY WAY WILL FIX ETA SON
        [self showAlertController:@"Are you sure u want to respring?" selector:@selector(respring:) withObject:sbreload];
    }
    
}

- (void)enterSafeMode {
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
        // Show the alert, pass the selector to this method and no object
        [self showAlertController:@"Are you sure u want to enter safe mode?" selector:@selector(enterSafeMode) withObject:nil];
    }
    
}

- (void)runUICache {
    //[self showAlertController:@"Are you sure u want to run uicache?"];
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
        // Show the alert, pass the selector to this method and no object
        [self showAlertController:@"Are you sure u want to run uicache? Your device will respring after a moment." selector:@selector(runUICache) withObject:nil];
    }
}


- (void)setBundleToOpen:(NSString *)bundle forKey:(NSString *)key
{
    [self.actions setValue:[NSValue valueWithPointer:@selector(openApplication:)] forKey:key];
    [self.actionLocations setValue:bundle forKey:key];
}

- (void)setURLToOpen:(NSString *)url forKey:(NSString *)key
{
    [self.actions setValue:[NSValue valueWithPointer:@selector(openURL:)] forKey:key];
    [self.actionLocations setValue:url forKey:key];
}

- (void)setCommandToRun:(NSString *)command forKey:(NSString *)key
{
    [self.actions setValue:[NSValue valueWithPointer:@selector(runCommand:)] forKey:key];
    [self.actionLocations setValue:command forKey:key];
}

- (void)performActionForKey:(NSString *)key
{
    SEL action = [[self.actions objectForKey:key] pointerValue];
    if (action == nil) return;
    [self performSelector:action withObject:(NSString *)[self.actionLocations objectForKey:key]];
}


-(void)showAlertController:(NSString *)alertMessage selector:(SEL)method withObject:(id)object
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
            // Call the method that has been passed, if the user clicks yes.
            // Might not be the best way?
            [self performSelector:method withObject:object];
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