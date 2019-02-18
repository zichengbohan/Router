//
//  ViewController.m
//  Router
//
//  Created by xbm on 2019/2/18.
//  Copyright © 2019 guomei. All rights reserved.
//

#import "ViewController.h"
#import "GFRouter.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *myButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonOnclivk:(id)sender {
    NSURL *url = [NSURL URLWithString:@"scheme://host/Router1ViewController?name=xubaimiao"];
    [GFRouter openURL:url];
}

@end
