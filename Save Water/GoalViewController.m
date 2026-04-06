//
//  GoalViewController.m
//  Save Water
//
//  Created by Jesus Miguel Ramos Hernandez on 20/04/26.
//

#import "GoalViewController.h"
#import "WaterStore.h"

@interface GoalViewController ()
@property (nonatomic) UILabel *summaryLabel;
@property (nonatomic) UISlider *slider;
@end

@implementation GoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationItem.title = @"Meta semanal";

    UILabel *desc = [[UILabel alloc] init];
    desc.text = @"Define tu meta semanal de litros";
    desc.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    desc.numberOfLines = 0;

    self.summaryLabel = [[UILabel alloc] init];
    self.summaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.summaryLabel.numberOfLines = 0;

    self.slider = [[UISlider alloc] init];
    self.slider.minimumValue = 500;
    self.slider.maximumValue = 10000;
    self.slider.value = (float)[WaterStore shared].weeklyGoalLiters;
    [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];

    UIButton *save = [UIButton buttonWithType:UIButtonTypeSystem];
    [save setTitle:@"Guardar meta" forState:UIControlStateNormal];
    save.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    [save addTarget:self action:@selector(saveTapped) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[desc, self.summaryLabel, self.slider, save]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:24]
    ]];

    [self updateSummary];
}

- (void)sliderChanged:(UISlider *)sender { [self updateSummary]; }

- (void)updateSummary {
    double goal = round(self.slider.value / 100.0) * 100.0;
    self.summaryLabel.text = [NSString stringWithFormat:@"Meta: %.0f L/semana", goal];
}

- (void)saveTapped {
    double roundedGoal = round(self.slider.value / 100.0) * 100.0;
    [WaterStore shared].weeklyGoalLiters = roundedGoal;
    UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"Meta guardada" message:@"Tu meta semanal ha sido actualizada" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:ok animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ok dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

@end
