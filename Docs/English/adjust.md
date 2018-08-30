## Integrate Apptilaus with the [**Adjust SDK**](https://apptilaus.com/integrating-with-adjust/)

To integrate Apptilaus with the Adjust SDK, you must send your Adjust ADID data as `adjust_id` to the Apptilaus SDK after registering the user. To use the Apptilaus together with Adjust please add custom parameter to purchase registering method adding the following lines:

Swift:
```swift
func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
        //Your purchase processing code
        if transaction.transactionState == .purchased {
            var customParameters: [String : Any] = [:];
            if let adid = Adjust.adid() {
                customParameters["adjust_id"] = adid
            }

            ApptilausManager.shared.register(transaction: transaction, customParams: customParameters)
        }
    }
```

Objective-C:
```objc
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
    
    
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            NSMutableDictionary<NSString *, id> *customParams = [NSMutableDictionary dictionary];
            NSString *adid = [Adjust adid];
            if (adid != nil) {
                customParams[@"adjust_id"] = adid;
            }
            [[ApptilausManager shared] registerWithTransaction:transaction customParams:customParams];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            NSLog(@"Transaction %@ failed with error: %@", transaction, transaction.error);
        }
        
        
    }
}
```