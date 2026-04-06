//
//  HistoryViewController.m
//  Save Water
//
//  Created by Assistant on 21/04/26.
//

#import "HistoryViewController.h"
#import "WaterStore.h"

@interface HistoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UISegmentedControl *segmented;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray<NSDictionary<NSString *, id> *> *rows; // date, liters
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationItem.title = @"Historial";

    self.segmented = [[UISegmentedControl alloc] initWithItems:@[@"Semana", @"Mes"]];
    self.segmented.selectedSegmentIndex = 0;
    [self.segmented addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmented;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.tableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    WaterStore *store = [WaterStore shared];
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];

    NSDate *start = nil; NSDate *end = nil;
    if (self.segmented.selectedSegmentIndex == 0) {
        // Semana
        NSDateInterval *w = [self weekIntervalContainingDate:now calendar:cal];
        start = w.startDate; end = w.endDate;
    } else {
        // Mes
        NSDateInterval *m = [self monthIntervalContainingDate:now calendar:cal];
        start = m.startDate; end = m.endDate;
    }
    self.rows = [store dailyTotalsFrom:start to:end];
    [self.tableView reloadData];
}

- (NSDateInterval *)weekIntervalContainingDate:(NSDate *)date calendar:(NSCalendar *)cal {
    NSDate *start = nil; NSTimeInterval interval = 0;
    [cal rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&start interval:&interval forDate:date];
    return [[NSDateInterval alloc] initWithStartDate:start duration:interval];
}

- (NSDateInterval *)monthIntervalContainingDate:(NSDate *)date calendar:(NSCalendar *)cal {
    NSDate *start = nil; NSTimeInterval interval = 0;
    [cal rangeOfUnit:NSCalendarUnitMonth startDate:&start interval:&interval forDate:date];
    return [[NSDateInterval alloc] initWithStartDate:start duration:interval];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.rows.count; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) { cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId]; }
    NSDictionary *row = self.rows[indexPath.row];
    NSDate *date = row[@"date"];
    NSNumber *liters = row[@"liters"];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    df.timeStyle = NSDateFormatterNoStyle;

    cell.textLabel.text = [df stringFromDate:date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f L", liters.doubleValue];
    return cell;
}

@end
