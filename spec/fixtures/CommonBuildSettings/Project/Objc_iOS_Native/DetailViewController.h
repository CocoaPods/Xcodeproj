//
//  DetailViewController.h
//  Objc_iOS_Native
//
//  Created by Samuel Giddins on 10/24/15.
//
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

