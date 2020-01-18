#include <spawn.h>

@interface SigneUtilities : NSObject

@property (nonatomic, retain) NSMutableDictionary *commands;
@property (nonatomic, retain) NSMutableDictionary *commandKeys;
@property (nonatomic, assign) BOOL shouldContinueAfterAlert;

+ (instancetype)sharedUtilities;

- (BOOL)keyHasCommand:(NSString *)key;
- (void)setCommandToRun:(NSString *)command forKey:(NSString *)key;
- (void)runCommand:(NSString *)commandName;
- (NSString *)getCommandForKey:(NSString *)key;
- (void)performCommandForKey:(NSString *)commandKey;
- (void)showAlertController:(NSString *)alertMessage selector:(SEL)method;


@end