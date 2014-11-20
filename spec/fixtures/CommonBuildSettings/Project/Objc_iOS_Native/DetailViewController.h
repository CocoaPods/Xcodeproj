//
//  DetailViewController.h
//  Objc_iOS_Native
//
//  Created by Kyle Fuller on 27/10/2014.
//
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

