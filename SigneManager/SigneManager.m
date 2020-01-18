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
    static dispatch_once_t onceToken = 0;
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

- (void)performActionForKey:(NSString *)key
{
    SEL action = [[self.actions objectForKey:key] pointerValue];
    if (action == nil) return;
    [self performSelector:action withObject:(NSString *)[self.actionLocations objectForKey:key]];
}

@end