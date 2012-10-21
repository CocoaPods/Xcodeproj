//
//  CPDetailViewController.h
//  iOS application
//
//  Created by Fabio Pelosin on 09/10/12.
//  Copyright (c) 2012 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
