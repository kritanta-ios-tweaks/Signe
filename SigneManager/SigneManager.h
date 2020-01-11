@interface SigneManager : NSObject 

@property (nonatomic, retain) NSMutableDictionary *actions;
@property (nonatomic, retain) NSMutableDictionary *actionLocations;

+ (instancetype)sharedManager;

- (void)setBundleToOpen:(NSString *)bundle forKey:(NSString *)key;
- (void)setURLToOpen:(NSString *)url forKey:(NSString *)key;
- (void)performActionForKey:(NSString *)key;
- (SEL)actionForKey:(NSString *)key;

@end