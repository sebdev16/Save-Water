//
//  WaterActivity.m
//  Save Water
//
//  Created by Assistant on 21/04/26.
//

#import "WaterActivity.h"

NSString * WaterActivityDisplayName(WaterActivityType type) {
    switch (type) {
        case WaterActivityTypeBath: return @"Baño";
        case WaterActivityTypeGarden: return @"Riego de jardín";
        case WaterActivityTypeLaundry: return @"Lavado de ropa";
        case WaterActivityTypeCarWash: return @"Lavado de auto";
    }
}

NSString * WaterActivityPrompt(WaterActivityType type) {
    switch (type) {
        case WaterActivityTypeBath: return @"¿Cuántos minutos te bañaste?";
        case WaterActivityTypeGarden: return @"¿Cuántos minutos regaste?";
        case WaterActivityTypeLaundry: return @"¿Cuántas cargas de ropa lavaste?";
        case WaterActivityTypeCarWash: return @"¿Cuántas veces lavaste el auto?";
    }
}

NSString * WaterActivityUnitSuffix(WaterActivityType type) {
    switch (type) {
        case WaterActivityTypeBath:
        case WaterActivityTypeGarden:
            return @"min"; // minutos
        case WaterActivityTypeLaundry:
        case WaterActivityTypeCarWash:
            return @"veces"; // eventos/cargas
    }
}

static inline double clampNonNegative(double x) { return x < 0 ? 0 : x; }

// Conversión a litros usando promedios sencillos.
double WaterActivityLitersForQuantity(WaterActivityType type, double quantity) {
    quantity = clampNonNegative(quantity);
    switch (type) {
        case WaterActivityTypeBath:
            return quantity * 10.0; // 10 L/min
        case WaterActivityTypeGarden:
            return quantity * 15.0; // 15 L/min
        case WaterActivityTypeLaundry:
            return quantity * 60.0; // 60 L por carga
        case WaterActivityTypeCarWash:
            return quantity * 150.0; // 150 L por evento
    }
}
