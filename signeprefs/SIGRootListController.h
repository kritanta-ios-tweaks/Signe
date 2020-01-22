#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <AppList/AppList.h>

@interface SIGRootListController : PSListController

@end


@interface SIGNumberOneController : SIGRootListController

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)removeAllSavedSpecifiers;

@end
/*

@interface SIGNumberZeroController : SIGRootListController

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)removeAllSavedSpecifiers;

@end

@interface SIGNumberTwoController : SIGRootListController

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)removeAllSavedSpecifiers;

@end

@interface SIGNumberThreeController : SIGRootListController

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)removeAllSavedSpecifiers;

@end

@interface SIGNumberFourController : SIGRootListController

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)removeAllSavedSpecifiers;

@end

@interface SIGNumberFiveController : SIGRootListController

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)removeAllSavedSpecifiers;

@end

@interface SIGNumberSixController : SIGRootListController

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)removeAllSavedSpecifiers;

@end
*/