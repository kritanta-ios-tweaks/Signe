//
//
//
//
//
//
//
//

#include "SIGRootListController.h"
#import <AppList/AppList.h>
#import <spawn.h>

@implementation SIGRootListController

- (instancetype)init 
{
	self = [super init];

	// Since the rest of the view
	self.showHeader = YES;

	return self;
}
- (NSArray *)specifiers {

	BOOL _tcFDPInstalled = [[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.p2kdev.floatingdockplus13.list"];
	_tcFDPInstalled = _tcFDPInstalled || [[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.imkpatil.floatingdockplus.list"];

	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	for (PSSpecifier *specifier in _specifiers) {
		if([[specifier propertyForKey:@"id"] isEqualToString:@"APGH"] && _tcFDPInstalled) [specifier setProperty:@"!! Note: It looks like you're using FloatingDockPlus; This tweak has been known to cause issues with drawings being invisible." forKey:@"footerText"];
	}

	return _specifiers;
}
- (void)viewWillAppear:(BOOL)animated {
	[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[self.class]].tintColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.38 alpha:1.0];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]] setOnTintColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.38 alpha:1.0]];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[self.class]] setTintColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.38 alpha:1.0]];
    
    [super viewWillAppear:animated];


	if (!self.showHeader) return;

	self.navigationController.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.38 alpha:1.0];

	//[self scrollViewDidScroll:self.scrollView];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];


	if (!self.showHeader) return;

	self.navigationController.navigationController.navigationBar.translucent = YES;
	//self.navigationController.navigationBar.tintColor = [UIColor systemBlueColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];


	if (!self.showHeader) return;

    self.navigationController.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.38 alpha:1.0];
}
- (void)viewDidLoad
{
	[super viewDidLoad];
	// [UIColor colorWithRed:0.00 green:0.27 blue:0.35 alpha:1.0];
	if (!self.showHeader) return;

	self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring"
								style:UIBarButtonItemStylePlain
								target:self
								action:@selector(respring:)];
	self.respringButton.tintColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.38 alpha:1.0];
	self.navigationItem.rightBarButtonItem = self.respringButton;

	self.iconView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/SignePrefs.bundle/icon@2x.png"]];
	self.iconView.contentMode = UIViewContentModeScaleAspectFit;
	self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
	self.iconView.alpha = 1.0;
	self.navigationItem.titleView = self.iconView;

	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,280,[[UIScreen mainScreen] bounds].size.width, 200)];
	self.headerView.backgroundColor = [UIColor colorWithRed:0.00 green:0.31 blue:0.39 alpha:0.0];
	UILabel *signeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 70, 300, 50)];
	signeLabel.font=[UIFont boldSystemFontOfSize:38];
	signeLabel.textColor = [UIColor whiteColor];
	signeLabel.text = @"Signe";
	[self.headerView addSubview:signeLabel];
	UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 120, 300, 50)];
	versionLabel.font=[UIFont systemFontOfSize:15 weight:UIFontWeightThin];
	versionLabel.textColor = [UIColor whiteColor];
	versionLabel.text = @"A Dynamic Gesture Recognizer";
	[self.headerView addSubview:versionLabel];
	//[self.view addSubview:self.headerView];
	//[self.view sendSubviewToBack:self.headerView];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.showHeader) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, 170)];
	if (!self.overflowView)
	{
		self.overflowView = [[UIView alloc] initWithFrame:CGRectMake(0,-310,[[UIScreen mainScreen] bounds].size.width,480)];
		self.overflowView.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.38 alpha:1.0];;
		CAGradientLayer *gradient = [CAGradientLayer layer];

		gradient.frame = self.overflowView.bounds;
		gradient.colors = @[(id)[UIColor colorWithRed:0.29 green:0.28 blue:0.49 alpha:1.0].CGColor, (id)[UIColor colorWithRed:0.11 green:0.11 blue:0.20 alpha:1.0].CGColor];

		[self.overflowView.layer insertSublayer:gradient atIndex:0];
		[self.overflowView addSubview:self.headerView];
		[tableView addSubview:self.overflowView];
	}

	//[tableView setContentInset:UIEdgeInsetsMake(150+tableView.contentInset.top, 0, 0, 0)];
	//self.automaticallyAdjustsScrollViewInsets = false;
	if (!self.startContentOffset) self.startContentOffset = tableView.contentOffset.y;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (!self.showHeader) return;
    CGFloat offsetY = scrollView.contentOffset.y;
	if (!self.kick) 
		{
			self.kick = YES;
			offsetY = self.startContentOffset;
		}
	if (offsetY < 200 - self.startContentOffset) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 1.0;
        }];
    }
	if (offsetY > self.startContentOffset) return;
	CGFloat height = 250 + (offsetY - self.startContentOffset);
	CGFloat desiredY = 0.35 * height;
	self.headerView.subviews[0].frame = CGRectMake(15, desiredY, 100, 50);
	CGFloat aheight = 230 + ((offsetY - self.startContentOffset)/4);
	CGFloat adesiredY = 0.60 * aheight;
	self.headerView.subviews[1].frame = CGRectMake(15, adesiredY, 300, 50);
}


- (void)respring:(id)sender {
	  pid_t pid;
    const char* args[] = {"killall", "backboardd", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

@end

@implementation SIGNumberOneController


- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"One" target:self];
	}

	self.savedSpecifiers = [[NSMutableDictionary alloc] init];
	for (PSSpecifier *specifier in _specifiers) {
		[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}

	return _specifiers;
}

-(void)viewDidLoad {
	self.showHeader = NO;
	[super viewDidLoad];

	[self setPreferenceValue:[self readPreferenceValue:[self specifierForID:@"rotationMode1ID"]] specifier:[self specifierForID:@"rotationMode1ID"]];
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"oneChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode1ID"];
	
	if (rotationSpecifier == specifier) {
		NSNumber *valueObj = (NSNumber *)value;
		[self removeAllSavedSpecifiers];
		if (valueObj.intValue == 1) { // If the user chose to open an app
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"oneChooseAppsList"]] afterSpecifierID:@"selectedConfigID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"selectedConfigID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"selectedConfigID"];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}



@end



@implementation SIGNumberZeroController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Zero" target:self];
	}

	self.savedSpecifiers = [[NSMutableDictionary alloc] init];
	for (PSSpecifier *specifier in _specifiers) {
		[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}

	return _specifiers;
}

-(void)viewDidLoad {
	self.showHeader = NO;
	[super viewDidLoad];

	[self setPreferenceValue:[self readPreferenceValue:[self specifierForID:@"rotationMode0ID"]] specifier:[self specifierForID:@"rotationMode0ID"]];
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"zeroChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode0ID"];
	
	if (rotationSpecifier == specifier) {
		NSNumber *valueObj = (NSNumber *)value;
		[self removeAllSavedSpecifiers];
		if (valueObj.intValue == 1) { // If the user chose to open an app
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"zeroChooseAppsList"]] afterSpecifierID:@"selectedConfigID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"selectedConfigID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"selectedConfigID"];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}


@end



@implementation SIGNumberTwoController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Two" target:self];
	}

	self.savedSpecifiers = [[NSMutableDictionary alloc] init];
	for (PSSpecifier *specifier in _specifiers) {
		[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}

	return _specifiers;
}

-(void)viewDidLoad {
	self.showHeader = NO;
	[super viewDidLoad];

	[self setPreferenceValue:[self readPreferenceValue:[self specifierForID:@"rotationMode2ID"]] specifier:[self specifierForID:@"rotationMode2ID"]];
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"twoChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode2ID"];
	
	if (rotationSpecifier == specifier) {
		NSNumber *valueObj = (NSNumber *)value;
		[self removeAllSavedSpecifiers];
		if (valueObj.intValue == 1) { // If the user chose to open an app
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"twoChooseAppsList"]] afterSpecifierID:@"selectedConfigID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"selectedConfigID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"selectedConfigID"];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}


@end


@implementation SIGNumberThreeController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Three" target:self];
	}

	self.savedSpecifiers = [[NSMutableDictionary alloc] init];
	for (PSSpecifier *specifier in _specifiers) {
		[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}

	return _specifiers;
}

-(void)viewDidLoad {
	self.showHeader = NO;
	[super viewDidLoad];

	[self setPreferenceValue:[self readPreferenceValue:[self specifierForID:@"rotationMode3ID"]] specifier:[self specifierForID:@"rotationMode3ID"]];
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"threeChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode3ID"];
	
	if (rotationSpecifier == specifier) {
		NSNumber *valueObj = (NSNumber *)value;
		[self removeAllSavedSpecifiers];
		if (valueObj.intValue == 1) { // If the user chose to open an app
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"threeChooseAppsList"]] afterSpecifierID:@"selectedConfigID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"selectedConfigID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"selectedConfigID"];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}

@end



@implementation SIGNumberFourController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Four" target:self];
	}

	self.savedSpecifiers = [[NSMutableDictionary alloc] init];
	for (PSSpecifier *specifier in _specifiers) {
		[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}

	return _specifiers;
}

-(void)viewDidLoad {
	self.showHeader = NO;
	[super viewDidLoad];

	[self setPreferenceValue:[self readPreferenceValue:[self specifierForID:@"rotationMode4ID"]] specifier:[self specifierForID:@"rotationMode4ID"]];
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"fourChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode4ID"];
	
	if (rotationSpecifier == specifier) {
		NSNumber *valueObj = (NSNumber *)value;
		[self removeAllSavedSpecifiers];
		if (valueObj.intValue == 1) { // If the user chose to open an app
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"fourChooseAppsList"]] afterSpecifierID:@"selectedConfigID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"selectedConfigID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"selectedConfigID"];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}


@end



@implementation SIGNumberFiveController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Five" target:self];
	}

	self.savedSpecifiers = [[NSMutableDictionary alloc] init];
	for (PSSpecifier *specifier in _specifiers) {
		[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}

	return _specifiers;
}

-(void)viewDidLoad {
	self.showHeader = NO;
	[super viewDidLoad];

	[self setPreferenceValue:[self readPreferenceValue:[self specifierForID:@"rotationMode5ID"]] specifier:[self specifierForID:@"rotationMode5ID"]];
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"fiveChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode5ID"];
	
	if (rotationSpecifier == specifier) {
		NSNumber *valueObj = (NSNumber *)value;
		[self removeAllSavedSpecifiers];
		if (valueObj.intValue == 1) { // If the user chose to open an app
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"fiveChooseAppsList"]] afterSpecifierID:@"selectedConfigID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"selectedConfigID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"selectedConfigID"];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}


@end


@implementation SIGNumberSixController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Six" target:self];
	}

	self.savedSpecifiers = [[NSMutableDictionary alloc] init];
	for (PSSpecifier *specifier in _specifiers) {
		[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}

	return _specifiers;
}

-(void)viewDidLoad {
	self.showHeader = NO;
	[super viewDidLoad];

	[self setPreferenceValue:[self readPreferenceValue:[self specifierForID:@"rotationMode6ID"]] specifier:[self specifierForID:@"rotationMode6ID"]];
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"sixChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode6ID"];
	
	if (rotationSpecifier == specifier) {
		NSNumber *valueObj = (NSNumber *)value;
		[self removeAllSavedSpecifiers];
		if (valueObj.intValue == 1) { // If the user chose to open an app
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"sixChooseAppsList"]] afterSpecifierID:@"selectedConfigID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"selectedConfigID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"selectedConfigID"];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}

@end

@implementation SIGNumberSevenController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Seven" target:self];
	}

	self.savedSpecifiers = [[NSMutableDictionary alloc] init];
	for (PSSpecifier *specifier in _specifiers) {
		[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}

	return _specifiers;
}

-(void)viewDidLoad {
	self.showHeader = NO;
	[super viewDidLoad];

	[self setPreferenceValue:[self readPreferenceValue:[self specifierForID:@"rotationMode7ID"]] specifier:[self specifierForID:@"rotationMode7ID"]];
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"sevenChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode7ID"];
	
	if (rotationSpecifier == specifier) {
		NSNumber *valueObj = (NSNumber *)value;
		[self removeAllSavedSpecifiers];
		if (valueObj.intValue == 1) { // If the user chose to open an app
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"sevenChooseAppsList"]] afterSpecifierID:@"selectedConfigID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"selectedConfigID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"selectedConfigID"];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}

@end

@implementation SIGNumberEightController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Eight" target:self];
	}

	self.savedSpecifiers = [[NSMutableDictionary alloc] init];
	for (PSSpecifier *specifier in _specifiers) {
		[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}

	return _specifiers;
}

-(void)viewDidLoad {
	self.showHeader = NO;
	[super viewDidLoad];

	[self setPreferenceValue:[self readPreferenceValue:[self specifierForID:@"rotationMode8ID"]] specifier:[self specifierForID:@"rotationMode8ID"]];
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"eightChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode8ID"];
	
	if (rotationSpecifier == specifier) {
		NSNumber *valueObj = (NSNumber *)value;
		[self removeAllSavedSpecifiers];
		if (valueObj.intValue == 1) { // If the user chose to open an app
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"eightChooseAppsList"]] afterSpecifierID:@"selectedConfigID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"selectedConfigID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"selectedConfigID"];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}

@end

@implementation SIGNumberNineController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Nine" target:self];
	}

	self.savedSpecifiers = [[NSMutableDictionary alloc] init];
	for (PSSpecifier *specifier in _specifiers) {
		[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
	}

	return _specifiers;
}

-(void)viewDidLoad {
	self.showHeader = NO;
	[super viewDidLoad];

	[self setPreferenceValue:[self readPreferenceValue:[self specifierForID:@"rotationMode9ID"]] specifier:[self specifierForID:@"rotationMode9ID"]];
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"nineChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode9ID"];
	
	if (rotationSpecifier == specifier) {
		NSNumber *valueObj = (NSNumber *)value;
		[self removeAllSavedSpecifiers];
		if (valueObj.intValue == 1) { // If the user chose to open an app
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"nineChooseAppsList"]] afterSpecifierID:@"selectedConfigID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"selectedConfigID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"selectedConfigID"];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}


@end