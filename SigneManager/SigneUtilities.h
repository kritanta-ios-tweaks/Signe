@interface SigneCommands : NSObject

@property (nonatomic, retain) NSMutableDictionary *actions;
@property (nonatomic, retain) NSMutableDictionary *actionLocations;

- (void)runCommand:(NSString *)commandName;

@end