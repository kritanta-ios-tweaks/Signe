#include <spawn.h>

@interface SigneManager : NSObject 

// For the commands: sbreload, uicache etc.

@property (nonatomic, assign) BOOL shouldDrawCharacters;
@property (nonatomic, retain) UIColor * strokeColor;
@property (nonatomic, assign) float strokeSize;

@property (nonatomic, retain) NSMutableDictionary *actions;
@property (nonatomic, retain) NSMutableDictionary *actionLocations;

@property (nonatomic, assign) BOOL shouldContinueAfterAlert;

+ (instancetype)sharedManager;


- (void)toggleEditor;

- (void)showAlertController:(NSString *)alertMessage selector:(SEL)method withObject:(id)object;
- (void)setBundleToOpen:(NSString *)bundle forKey:(NSString *)key;
- (void)setURLToOpen:(NSString *)url forKey:(NSString *)key;
- (void)setCommandToRun:(NSString *)command forKey:(NSString *)key;
- (void)performActionForKey:(NSString *)key;
- (SEL)actionForKey:(NSString *)key;
- (void)respring:(NSNumber *)sbreload;
- (void)enterSafeMode;
- (void)runUICache;

@end