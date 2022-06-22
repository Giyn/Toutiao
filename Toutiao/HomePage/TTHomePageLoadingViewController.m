//
//  TTLoadingViewController.m
//  Toutiao
//
//  Created by 肖扬 on 2022/6/21.
//

#import "Masonry.h"
#import "TTHomePageLoadingViewController.h"

@interface TTHomePageLoadingViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation TTHomePageLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:self.indicator];
    [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
    }];
    // Do any additional setup after loading the view from its nib.
    self.indicator.transform = CGAffineTransformScale(_indicator.transform, 2, 2);
    [self.indicator startAnimating];
    self.view.backgroundColor = UIColor.blackColor;
    self.indicator.color = UIColor.whiteColor;
}

@end
