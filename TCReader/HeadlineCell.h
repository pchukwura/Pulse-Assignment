//
//  HeadlineCell.h
//  TCReader
//
//  Created by Patrick Chukwura on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeadlineCell : UITableViewCell{
    IBOutlet UILabel *headlineLabel;
    IBOutlet UILabel *subtextLabel;
    IBOutlet UIImageView *thumbnail;
}

@property (nonatomic, retain) IBOutlet UILabel *headlineLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtextLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnail;

@end
