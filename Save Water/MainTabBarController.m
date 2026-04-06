//
//  MainTabBarController.m
//  Save Water
//
//  Created by Jesus Miguel Ramos Hernandez on 20/04/26.
//


#import "MainTabBarController.h"
#import "ViewController.h"
#import "HistoryViewController.h"
#import "GoalViewController.h"
#import "TipsViewController.h"

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    ViewController *registerVC = [[ViewController alloc] init];
    registerVC.title = @"Registro";
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:registerVC];
    nav1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Registro" image:[UIImage systemImageNamed:@"plus.circle"] tag:0];

    HistoryViewController *historyVC = [[HistoryViewController alloc] init];
    historyVC.title = @"Historial";
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:historyVC];
    nav2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Historial" image:[UIImage systemImageNamed:@"chart.bar"] tag:1];

    GoalViewController *goalVC = [[GoalViewController alloc] init];
    goalVC.title = @"Meta";
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:goalVC];
    nav3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Meta" image:[UIImage systemImageNamed:@"target"] tag:2];

    TipsViewController *tipsVC = [[TipsViewController alloc] init];
    tipsVC.title = @"Consejos";
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:tipsVC];
    nav4.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Consejos" image:[UIImage systemImageNamed:@"lightbulb"] tag:3];

    self.viewControllers = @[nav1, nav2, nav3, nav4];
}

@end
