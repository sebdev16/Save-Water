//
//  WaterStore.m
//  Save Water
//
//  Created by Assistant on 21/04/26.
//

#import "WaterStore.h"

static NSString * const kEntriesKey = @"WaterStore.entries";
static NSString * const kWeeklyGoalKey = @"WaterStore.weeklyGoal";

@implementation WaterEntry

+ (BOOL)supportsSecureCoding { return YES; }

- (instancetype)initWithDate:(NSDate *)date type:(WaterActivityType)type quantity:(double)quantity liters:(double)liters {
    if (self = [super init]) {
        _date = date;
        _type = type;
        _quantity = quantity;
        _liters = liters;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeInteger:self.type forKey:@"type"];
    [coder encodeDouble:self.quantity forKey:@"quantity"];
    [coder encodeDouble:self.liters forKey:@"liters"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSDate *date = [coder decodeObjectOfClass:[NSDate class] forKey:@"date"] ?: [NSDate date];
    WaterActivityType type = [coder decodeIntegerForKey:@"type"];
    double quantity = [coder decodeDoubleForKey:@"quantity"];
    double liters = [coder decodeDoubleForKey:@"liters"];
    return [self initWithDate:date type:type quantity:quantity liters:liters];
}

@end

@interface WaterStore ()
@property (nonatomic) NSMutableArray<WaterEntry *> *entries;
@property (nonatomic) NSCalendar *calendar;
@end

@implementation WaterStore

+ (instancetype)shared {
    static WaterStore *instance; static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] initPrivate]; });
    return instance;
}

- (instancetype)initPrivate {
    if (self = [super init]) {
        _calendar = [NSCalendar currentCalendar];
        [self load];
    }
    return self;
}

- (instancetype)init { [NSException raise:@"Singleton" format:@"Use +shared"]; return nil; }

- (void)load {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSData *data = [defaults objectForKey:kEntriesKey];
    if (data) {
        NSError *error = nil;
        NSSet *set = [NSSet setWithObjects:[NSArray class], [WaterEntry class], nil];
        NSArray *decoded = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:data error:&error];
        if ([decoded isKindOfClass:[NSArray class]]) {
            self.entries = [decoded mutableCopy];
        }
    }
    if (!self.entries) { self.entries = [NSMutableArray array]; }

    double goal = [defaults doubleForKey:kWeeklyGoalKey];
    if (goal <= 0) goal = 2500.0; // valor inicial razonable
    _weeklyGoalLiters = goal;
}

- (void)save {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.entries requiringSecureCoding:YES error:&error];
    if (data) { [defaults setObject:data forKey:kEntriesKey]; }
    [defaults setDouble:self.weeklyGoalLiters forKey:kWeeklyGoalKey];
}

- (NSDate *)stripTime:(NSDate *)date {
    NSDateComponents *c = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    return [self.calendar dateFromComponents:c];
}

- (void)addEntryForTodayWithType:(WaterActivityType)type quantity:(double)quantity {
    double liters = WaterActivityLitersForQuantity(type, quantity);
    WaterEntry *e = [[WaterEntry alloc] initWithDate:[self stripTime:[NSDate date]] type:type quantity:quantity liters:liters];
    [self.entries addObject:e];
    [self save];
}

- (NSArray<WaterEntry *> *)entriesForDay:(NSDate *)day {
    NSDate *d = [self stripTime:day];
    NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(WaterEntry *obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [[self stripTime:obj.date] isEqualToDate:d];
    }];
    return [self.entries filteredArrayUsingPredicate:p];
}

- (double)totalLitersForDay:(NSDate *)day {
    double sum = 0;
    for (WaterEntry *e in [self entriesForDay:day]) { sum += e.liters; }
    return sum;
}

- (NSDateInterval *)weekIntervalContainingDate:(NSDate *)date {
    NSDate *start = nil; NSTimeInterval interval = 0;
    [self.calendar rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&start interval:&interval forDate:date];
    return [[NSDateInterval alloc] initWithStartDate:start duration:interval];
}

- (NSDateInterval *)monthIntervalContainingDate:(NSDate *)date {
    NSDate *start = nil; NSTimeInterval interval = 0;
    [self.calendar rangeOfUnit:NSCalendarUnitMonth startDate:&start interval:&interval forDate:date];
    return [[NSDateInterval alloc] initWithStartDate:start duration:interval];
}

- (double)totalLitersForWeekContainingDate:(NSDate *)date {
    NSDateInterval *w = [self weekIntervalContainingDate:date];
    double sum = 0;
    for (WaterEntry *e in self.entries) {
        if ([w containsDate:e.date]) sum += e.liters;
    }
    return sum;
}

- (double)totalLitersForMonthContainingDate:(NSDate *)date {
    NSDateInterval *m = [self monthIntervalContainingDate:date];
    double sum = 0;
    for (WaterEntry *e in self.entries) {
        if ([m containsDate:e.date]) sum += e.liters;
    }
    return sum;
}

- (NSArray<NSDictionary<NSString *,id> *> *)dailyTotalsFrom:(NSDate *)start to:(NSDate *)end {
    NSMutableArray *result = [NSMutableArray array];
    NSDate *day = start;
    // Iterate while day < end (end is exclusive, e.g., next Monday 00:00 for a week)
    while ([day compare:end] == NSOrderedAscending) {
        double liters = [self totalLitersForDay:day];
        [result addObject:@{ @"date": day, @"liters": @(liters) }];
        NSDateComponents *add = [[NSDateComponents alloc] init];
        add.day = 1;
        day = [self.calendar dateByAddingComponents:add toDate:day options:0];
    }
    return result;
}

- (void)setWeeklyGoalLiters:(double)weeklyGoalLiters {
    _weeklyGoalLiters = weeklyGoalLiters > 0 ? weeklyGoalLiters : 0;
    [self save];
}

@end
