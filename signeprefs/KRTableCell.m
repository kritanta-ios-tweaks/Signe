//
// KRTableCell.m
//  
// This code is directly from HBTintedTableCell in Cephie 
// Don't fix what ain't broke
//

#import "KRTableCell.h"

@implementation KRTableCell

- (void)tintColorDidChange {
	[super tintColorDidChange];
	self.textLabel.textColor = self.tintColor;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
	[super refreshCellContentsWithSpecifier:specifier];

	if ([self respondsToSelector:@selector(tintColor)]) {
		self.textLabel.textColor = self.tintColor;
	}
}

@end