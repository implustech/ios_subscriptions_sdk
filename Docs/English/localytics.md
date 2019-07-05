## Integrate Apptilaus with the [**Localytics SDK**](https://apptilaus.com/integrating-with-localytics/)

To integrate Apptilaus with the Localytics SDK, you must send your Localytics `client_id` data as `localytics_id` to the Apptilaus SDK after registering the user. To use the Apptilaus together with Localytics please add custom parameter to purchase registering method adding the following lines:

Swift:
```swift
func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
        //Your purchase processing code
        if transaction.transactionState == .purchased {
            var customParameters: [String : Any] = [:];
            if let adid = Localytics.client_id() {
                customParameters["localytics_id"] = adid
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
            NSString *localytics_id = [Localytics client_id];
            if (localytics_id != nil) {
                customParams[@"localytics_id"] = adid;
            }
            [[ApptilausManager shared] registerWithTransaction:transaction customParams:customParams];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            NSLog(@"Transaction %@ failed with error: %@", transaction, transaction.error);
        }
        
        
    }
}
```
