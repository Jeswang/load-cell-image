//
//  CoreTextTableViewCell.h
//  load-cell-image
//
//  Created by jeswang on 14/12/30.
//  Copyright (c) 2014年 rainy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTAttributedTextContentView;
@interface CoreTextTableViewCell : UITableViewCell

@property (nonatomic, readwrite) IBOutlet DTAttributedTextContentView *attributedTextContextView;

@end
