//
//  WaterActivity.h
//  Save Water
//
//  Created by Assistant on 21/04/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WaterActivityType) {
    WaterActivityTypeBath = 0,       // Baño (ducha)
    WaterActivityTypeGarden = 1,     // Riego de jardín
    WaterActivityTypeLaundry = 2,    // Lavado de ropa (cargas)
    WaterActivityTypeCarWash = 3     // Lavado de auto
};

FOUNDATION_EXPORT NSString * WaterActivityDisplayName(WaterActivityType type);
FOUNDATION_EXPORT NSString * WaterActivityPrompt(WaterActivityType type);
FOUNDATION_EXPORT NSString * WaterActivityUnitSuffix(WaterActivityType type); // "min" o "veces"
FOUNDATION_EXPORT double WaterActivityLitersForQuantity(WaterActivityType type, double quantity);

// Valores promedio usados (referenciales y ajustables):
// - Ducha: ~10 L/min
// - Riego con manguera: ~15 L/min
// - Lavado de ropa (lavadora eficiente): ~60 L por carga
// - Lavado de auto (manguera): ~150 L por evento

NS_ASSUME_NONNULL_END
