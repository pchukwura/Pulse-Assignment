//
//  HeadlineCell.m
//  TCReader
//
//  Created by Patrick Chukwura on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HeadlineCell.h"

@implementation HeadlineCell

@synthesize headlineLabel, subtextLabel, thumbnail;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [headlineLabel release];
    [subtextLabel release];
    [thumbnail release];
    [super dealloc];
}

@end
