#include "SIGNumberController.h"


@implementation SIGNumberController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"One" target:self];
	}

	return _specifiers;
}

@end