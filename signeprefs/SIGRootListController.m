#include "SIGRootListController.h"

@implementation SIGRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

@end



@implementation DrawCustomizationSettingsPrefs

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"DrawCustomizationSettings" target:self];
	}

	return _specifiers;
}

@end