//
//  ViewController.m
//  Save Water
//
//  Created by Jesus Miguel Ramos Hernandez on 20/04/26.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import "WaterStore.h"
#import "WaterActivity.h"

@interface ViewController ()
@property (nonatomic) UILabel *todayLabel;
@property (nonatomic) UILabel *weekLabel;
@property (nonatomic) UIStackView *buttonsStack;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.navigationItem.title = @"Registro diario";

    UILabel *title = [[UILabel alloc] init];
    title.text = @"Registra tus actividades";
    title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    title.textAlignment = NSTextAlignmentCenter;
    title.numberOfLines = 0;

    self.todayLabel = [[UILabel alloc] init];
    self.todayLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.todayLabel.textAlignment = NSTextAlignmentCenter;

    self.weekLabel = [[UILabel alloc] init];
    self.weekLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.weekLabel.textAlignment = NSTextAlignmentCenter;
    self.weekLabel.numberOfLines = 0;

    UIButton *bathBtn = [self bigButtonWithTitle:@"Baño" systemImage:@"shower" action:@selector(tapBath)];
    UIButton *gardenBtn = [self bigButtonWithTitle:@"Riego de jardín" systemImage:@"leaf" action:@selector(tapGarden)];
    UIButton *laundryBtn = [self bigButtonWithTitle:@"Lavado de ropa" systemImage:@"tshirt" action:@selector(tapLaundry)];
    UIButton *carBtn = [self bigButtonWithTitle:@"Lavado de auto" systemImage:@"car" action:@selector(tapCar)];

    self.buttonsStack = [[UIStackView alloc] initWithArrangedSubviews:@[bathBtn, gardenBtn, laundryBtn, carBtn]];
    self.buttonsStack.axis = UILayoutConstraintAxisVertical;
    self.buttonsStack.spacing = 12;
    self.buttonsStack.distribution = UIStackViewDistributionFillEqually;

    UIStackView *root = [[UIStackView alloc] initWithArrangedSubviews:@[title, self.todayLabel, self.weekLabel, self.buttonsStack]];
    root.axis = UILayoutConstraintAxisVertical;
    root.spacing = 16;
    root.alignment = UIStackViewAlignmentFill;

    root.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:root];

    [NSLayoutConstraint activateConstraints:@[
        [root.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor],
        [root.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor],
        [root.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:16],
        [self.buttonsStack.heightAnchor constraintEqualToConstant:320]
    ]];

    [self updateSummary];
}

- (UIButton *)bigButtonWithTitle:(NSString *)title systemImage:(NSString *)systemImage action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    btn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    btn.layer.cornerRadius = 12;
    btn.backgroundColor = [UIColor systemGray6Color];
    btn.contentEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16);

    UIImage *img = [UIImage systemImageNamed:systemImage];
    [btn setImage:img forState:UIControlStateNormal];
    btn.tintColor = [UIColor systemBlueColor];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 8);

    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)tapBath { [self promptForType:WaterActivityTypeBath]; }
- (void)tapGarden { [self promptForType:WaterActivityTypeGarden]; }
- (void)tapLaundry { [self promptForType:WaterActivityTypeLaundry]; }
- (void)tapCar { [self promptForType:WaterActivityTypeCarWash]; }

- (void)promptForType:(WaterActivityType)type {
    NSString *title = WaterActivityDisplayName(type);
    NSString *message = WaterActivityPrompt(type);
    NSString *suffix = WaterActivityUnitSuffix(type);

    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = [NSString stringWithFormat:@"0 %@", suffix];
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [ac addAction:[UIAlertAction actionWithTitle:@"Guardar" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        double qty = [ac.textFields.firstObject.text doubleValue];
        if (qty < 0) qty = 0;
        [[WaterStore shared] addEntryForTodayWithType:type quantity:qty];
        [weakSelf showConfirmationForType:type quantity:qty];
        [weakSelf updateSummary];
    }]];

    [self presentViewController:ac animated:YES completion:nil];
}

- (void)showConfirmationForType:(WaterActivityType)type quantity:(double)qty {
    double liters = WaterActivityLitersForQuantity(type, qty);
    NSString *msg = [NSString stringWithFormat:@"Registrado: %.0f L", liters];
    UIAlertController *ok = [UIAlertController alertControllerWithTitle:WaterActivityDisplayName(type) message:msg preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:ok animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ok dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

- (void)updateSummary {
    WaterStore *store = [WaterStore shared];
    NSDate *today = [NSDate date];
    double todayLiters = [store totalLitersForDay:today];
    self.todayLabel.text = [NSString stringWithFormat:@"Hoy: %.0f L", todayLiters];

    double week = [store totalLitersForWeekContainingDate:today];
    double goal = store.weeklyGoalLiters;
    NSString *status = week <= goal ? @"¡Vas bien!" : @"Atención: te estás pasando";
    NSString *detail = [NSString stringWithFormat:@"Semana: %.0f / %.0f L\n%@", week, goal, status];
    self.weekLabel.text = detail;
}

@end
