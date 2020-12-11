#import <Preferences/PSListController.h>
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import <AppList/AppList.h>

@interface SIGRootListController : PSListController{
    UITableView * _table;
}

@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIView *overflowView;
@property (nonatomic, assign) CGFloat startContentOffset;
@property (nonatomic, assign) BOOL kick;
@property (nonatomic, assign) BOOL showHeader;

@property (nonatomic, retain) UIBarButtonItem *respringButton;
@property (nonatomic, retain) UIImageView *titleLabel;
@property (nonatomic, retain) UIImageView *iconView;

@end


@interface SIGNumberOneController : SIGRootListController

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)removeAllSavedSpecifiers;

@end


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


@interface SIGNumberSevenController : SIGRootListController

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)removeAllSavedSpecifiers;

@end


@interface SIGNumberEightController : SIGRootListController

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)removeAllSavedSpecifiers;

@end


@interface SIGNumberNineController : SIGRootListController

@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;

-(void)removeAllSavedSpecifiers;

@end
