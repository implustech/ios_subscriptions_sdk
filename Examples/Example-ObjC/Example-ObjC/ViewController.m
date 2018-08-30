//
//  ViewController.m
//  Example-ObjC
//
//  Created by Юрий Буянов on 17/09/2018.
//  Copyright © 2018 Example Ltd. All rights reserved.
//

#import "ViewController.h"
#import <StoreKit/StoreKit.h>
#import <Apptilaus/Apptilaus-umbrella.h>

@interface ViewController ()<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic) IBOutletCollection(UIButton) NSArray<UIButton *> *buttons;
@property (nonatomic) NSArray<SKProduct *> *products;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    NSArray<NSString *> *productIds = @[@"test.purchase.one",
                                        @"test.subscription.renew.week",
                                        @"test.subscription.norenew.week"];
    
    SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
    req.delegate = self;
    
    [req start];
}

- (IBAction)buttonTap:(UIButton *)sender {
    NSUInteger index = [self.buttons indexOfObject:sender];
    if (index != NSNotFound && index < self.products.count) {
        SKProduct *product = self.products[index];
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
    }
}


#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    for (NSUInteger i = 0; i < MIN(response.products.count, self.buttons.count); i++) {
        SKProduct *product = response.products[i];
        formatter.locale = product.priceLocale;
        NSString *title = [NSString stringWithFormat:@"%@ %@", product.localizedTitle, [formatter stringFromNumber:product.price]];
        [self.buttons[i] setTitle:title forState:UIControlStateNormal];
    }
    
    self.products = [response.products copy];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            NSDictionary<NSString *, id> *customParams = @{
                 @"foo": @"bar",
                 @"goats_count": @123
            };
            [[ApptilausManager shared] registerWithTransaction:transaction customParams:customParams];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            NSLog(@"Transaction %@ failed with error: %@", transaction, transaction.error);
        }
    }
}

@end
