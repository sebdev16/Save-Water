//
//  TipsViewController.m
//  Save Water
//
//  Created by Jesus Miguel Ramos Hernandez on 20/04/26.
//


#import "TipsViewController.h"

@interface TipsViewController ()
@property (nonatomic) NSArray<NSString *> *tips;
@end

@implementation TipsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Consejos";

    self.tips = @[
        @"Cierra la llave mientras te enjabonas.",
        @"Repara fugas en llaves y tuberías.",
        @"Riega el jardín por la mañana o tarde para evitar evaporación.",
        @"Usa una cubeta para lavar el auto en lugar de la manguera.",
        @"Junta agua de la regadera mientras se calienta para otros usos.",
        @"Usa lavadora con cargas completas.",
        @"Instala regaderas y llaves ahorradoras.",
        @"Cierra la llave mientras te cepillas los dientes.",
        @"Riega plantas con agua residual de lavar verduras.",
        @"Verifica tu medidor de agua para detectar consumos anormales.",
    ];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"]; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UIListContentConfiguration *content = [UIListContentConfiguration valueCellConfiguration];
    content.text = self.tips[indexPath.row];
    content.textProperties.numberOfLines = 0;
    cell.contentConfiguration = content;
    return cell;
}

@end
