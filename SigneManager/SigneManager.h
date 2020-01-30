#include <spawn.h>

#define SuppressPerformSelectorLeakWarning(Stuff) \
    do { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
        Stuff; \
        _Pragma("clang diagnostic pop") \
    } while (0)

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

- (void)setBundleToOpen:(NSString *)bundle forKey:(NSString *)key;
- (void)setURLToOpen:(NSString *)url forKey:(NSString *)key;
- (void)performActionForKey:(NSString *)key;


@end