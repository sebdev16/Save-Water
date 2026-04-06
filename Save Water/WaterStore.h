//
//  WaterStore.h
//  Save Water
//
//  Created by Assistant on 21/04/26.
//

#import <Foundation/Foundation.h>
#import "WaterActivity.h"

NS_ASSUME_NONNULL_BEGIN

@interface WaterEntry : NSObject <NSSecureCoding>
@property (nonatomic, readonly) NSDate *date; // fecha del registro (día)
@property (nonatomic, readonly) WaterActivityType type;
@property (nonatomic, readonly) double quantity; // minutos o veces, según el tipo
@property (nonatomic, readonly) double liters;   // litros calculados
- (instancetype)initWithDate:(NSDate *)date type:(WaterActivityType)type quantity:(double)quantity liters:(double)liters;
@end

/// Maneja persistencia simple y agregaciones.
@interface WaterStore : NSObject
+ (instancetype)shared;

// Registrar una actividad
- (void)addEntryForTodayWithType:(WaterActivityType)type quantity:(double)quantity;

// Obtener entradas por día (agrupadas por fecha sin hora)
- (NSArray<WaterEntry *> *)entriesForDay:(NSDate *)day;

// Totales
- (double)totalLitersForDay:(NSDate *)day;
- (double)totalLitersForWeekContainingDate:(NSDate *)date; // lunes-domingo según calendario actual
- (double)totalLitersForMonthContainingDate:(NSDate *)date;

// Historial agregados por día dentro de un rango
- (NSArray<NSDictionary<NSString *, id> *> *)dailyTotalsFrom:(NSDate *)start to:(NSDate *)end; // cada dic: @{ @"date": NSDate, @"liters": NSNumber }

// Meta semanal (litros)
@property (nonatomic) double weeklyGoalLiters; // default 2500 L, ajustable

@end

NS_ASSUME_NONNULL_END
