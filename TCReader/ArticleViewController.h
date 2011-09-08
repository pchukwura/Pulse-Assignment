//
//  ArticleViewController.h
//  TCReader
//
//  Created by Patrick Chukwura on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleViewController : UIViewController
{
    IBOutlet UIWebView *webview;
}

@property (nonatomic, retain) IBOutlet UIWebView *webview;

@end
