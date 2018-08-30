## Integrate Apptilaus with the [**Amplitude SDK**](https://apptilaus.com/integrating-with-appmetrica/)

To integrate Apptilaus with the Amplitude SDK, you must send your Amplitude Device ID data as `amplitude_id` to the Apptilaus SDK after registering the user. To use the Apptilaus together with Amplitude please add custom parameter to purchase registering method adding the following lines:

Swift:
```swift
func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
        //Your purchase processing code
        if transaction.transactionState == .purchased {            
            var customParameters: [String : Any] = [:]
            if let deviceId = Aplitude.instance().deviceId {
                customParameters["amplitude_id"] = deviceId
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
            NSString *deviceId = [Amplitude instance].deviceId;
            if (deviceId != nil) {
                customParams[@"amplitude_id"] = deviceId;
            }
            [[ApptilausManager shared] registerWithTransaction:transaction customParams:customParams];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            NSLog(@"Transaction %@ failed with error: %@", transaction, transaction.error);
        }
        
        
    }
}
```