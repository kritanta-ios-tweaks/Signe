#include "SIGRootListController.h"
#import <AppList/AppList.h>

@implementation SIGRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
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
	[super viewDidLoad];

	// fix all specifiers showing up immediately
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"oneChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode1ID"];
	
	if (rotationSpecifier == specifier) { // NEEDS TO BE CLEANED UP!!
		NSNumber *valueObj = (NSNumber *)value;
		if (valueObj.intValue == 1) { // If the user chose to open an app!!
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
			
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"oneChooseAppsList"]] afterSpecifierID:@"appGroupSettingsID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"oneChooseAppsList"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"urlGroupSettingsID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"oneChooseAppsList"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"cmdGroupSettingsID"];
		}
		else { // If disabled, remove all specifiers
			[self removeAllSavedSpecifiers];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}

@end


/*
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
	[super viewDidLoad];

	// fix all specifiers showing up immediately
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"zeroChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode1ID"];
	
	if (rotationSpecifier == specifier) { // NEEDS TO BE CLEANED UP!!
		NSNumber *valueObj = (NSNumber *)value;
		if (valueObj.intValue == 1) { // If the user chose to open an app!!
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
			
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"zeroChooseAppsList"]] afterSpecifierID:@"appGroupSettingsID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"zeroChooseAppsList"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"urlGroupSettingsID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"zeroChooseAppsList"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"cmdGroupSettingsID"];
		}
		else { // If disabled, remove all specifiers
			[self removeAllSavedSpecifiers];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}

@end*/


/*
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
	[super viewDidLoad];

	// fix all specifiers showing up immediately
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"twoChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode2ID"];
	
	if (rotationSpecifier == specifier) { // NEEDS TO BE CLEANED UP!!
		NSNumber *valueObj = (NSNumber *)value;
		if (valueObj.intValue == 1) { // If the user chose to open an app!!
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
			
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"twoChooseAppsList"]] afterSpecifierID:@"appGroupSettingsID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"twoChooseAppsList"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"urlGroupSettingsID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"twoChooseAppsList"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"cmdGroupSettingsID"];
		}
		else { // If disabled, remove all specifiers
			[self removeAllSavedSpecifiers];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}

@end*/

/*
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
	[super viewDidLoad];

	// fix all specifiers showing up immediately
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"threeChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode3ID"];
	
	if (rotationSpecifier == specifier) { // NEEDS TO BE CLEANED UP!!
		NSNumber *valueObj = (NSNumber *)value;
		if (valueObj.intValue == 1) { // If the user chose to open an app!!
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
			
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"threeChooseAppsList"]] afterSpecifierID:@"appGroupSettingsID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"threeChooseAppsList"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"urlGroupSettingsID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"threeChooseAppsList"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"cmdGroupSettingsID"];
		}
		else { // If disabled, remove all specifiers
			[self removeAllSavedSpecifiers];
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
	[super viewDidLoad];

	// fix all specifiers showing up immediately
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"fourChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode4ID"];
	
	if (rotationSpecifier == specifier) { // NEEDS TO BE CLEANED UP!!
		NSNumber *valueObj = (NSNumber *)value;
		if (valueObj.intValue == 1) { // If the user chose to open an app!!
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
			
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"fourChooseAppsList"]] afterSpecifierID:@"appGroupSettingsID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"fourChooseAppsList"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"urlGroupSettingsID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"fourChooseAppsList"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"cmdGroupSettingsID"];
		}
		else { // If disabled, remove all specifiers
			[self removeAllSavedSpecifiers];
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
	[super viewDidLoad];

	// fix all specifiers showing up immediately
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"fiveChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode5ID"];
	
	if (rotationSpecifier == specifier) { // NEEDS TO BE CLEANED UP!!
		NSNumber *valueObj = (NSNumber *)value;
		if (valueObj.intValue == 1) { // If the user chose to open an app!!
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
			
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"fiveChooseAppsList"]] afterSpecifierID:@"appGroupSettingsID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"fiveChooseAppsList"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"urlGroupSettingsID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"fiveChooseAppsList"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"cmdGroupSettingsID"];
		}
		else { // If disabled, remove all specifiers
			[self removeAllSavedSpecifiers];
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
	[super viewDidLoad];

	// fix all specifiers showing up immediately
}

-(void)removeAllSavedSpecifiers {
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"sixChooseAppsList"]] animated:YES];
	[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
}


-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	PSSpecifier *rotationSpecifier = [self specifierForID:@"rotationMode6ID"];
	
	if (rotationSpecifier == specifier) { // NEEDS TO BE CLEANED UP!!
		NSNumber *valueObj = (NSNumber *)value;
		if (valueObj.intValue == 1) { // If the user chose to open an app!!
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];
			
			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"sixChooseAppsList"]] afterSpecifierID:@"appGroupSettingsID" animated:YES];
		}
		else if (valueObj.intValue == 2) { // If users chooses for URL
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"sixChooseAppsList"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] afterSpecifierID:@"urlGroupSettingsID"];
		}
		else if (valueObj.intValue == 3) { // If users chooses for commands
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"urlTextboxID"]] animated:YES];
			[self removeContiguousSpecifiers:@[self.savedSpecifiers[@"sixChooseAppsList"]] animated:YES];


			[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"cmdListID"]] afterSpecifierID:@"cmdGroupSettingsID"];
		}
		else { // If disabled, remove all specifiers
			[self removeAllSavedSpecifiers];
		}
	}

	NSLog(@"[Signe]: Set Prefs value: %@ and specifier: %@", value, specifier);
}

@end*/