## Integrate Apptilaus with the [**Appsflyer SDK**](https://apptilaus.com/integrating-with-appsflyer/)

To integrate Apptilaus with the Appsflyer SDK, you must send your Appsflyer Device ID data as `appsflyer_id` to the Apptilaus SDK after registering the user. To use the Apptilaus together with Appsflyer please add custom parameter to purchase registering method adding the following lines:

Swift:
```swift
func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
        //Your purchase processing code
        if transaction.transactionState == .purchased {
            var customParameters: [String : Any] = [:]
            if let deviceId = AppsFlyerTracker.shared().getAppsFlyerUID() {
                customParameters["appsflyer_id"] = deviceId
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
            NSString *deviceId = [AppsFlyerTracker sharedTracker].getAppsFlyerUID;
            if (deviceId != nil) {
                customParams[@"appsflyer_id"] = deviceId;
            }

            [[ApptilausManager shared] registerWithTransaction:transaction customParams:customParams];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            NSLog(@"Transaction %@ failed with error: %@", transaction, transaction.error);
        }
        
        
    }
}
```