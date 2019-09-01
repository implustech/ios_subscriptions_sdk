import StoreKit
import AdSupport

public class ApptilausManager: NSObject {
    static let kLastSessionRegisteredPrefix = "last_session_registered_"
    
    public typealias CompletionHandler = (_ success: Bool, _ error: Error?) -> ()
    
    @objc public static let shared = ApptilausManager()
    
    @objc public var userId: String?
    @objc public var baseUrl: String = "https://api.apptilaus.com/"
    
    private var appId: String?
    private var appToken: String?
    private var delegates: Set<TransactionProductRequestDelegate> = []
    
    @objc public func setup(withAppId appId:String, appToken: String, enableSessionTracking: Bool = false) {
        self.appId = appId
        self.appToken = appToken
        
        if (enableSessionTracking) {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(registerSessionIfNeeded(_:)),
                                                   name: UIApplication.didBecomeActiveNotification,
                                                   object: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func unretain(delegate: TransactionProductRequestDelegate) {
        self.delegates.remove(delegate)
    }
    
    @objc private func registerSessionIfNeeded(_ notification: Notification) {
        guard let appId = self.appId else {
            print("[Apptilaus]: appId not set")
            return
        }
        
        guard let baseUrl = URL(string: self.baseUrl) else {
            print("[Apptilaus]: failed to create request URL with base URL \(self.baseUrl), app ID \(String(describing: self.appId))")
            return
        }

        let now = Date()
        let nowMillis = now.timeIntervalSince1970 * 1000
        let cal = Calendar.current
        let todayComponents = cal.dateComponents([.day, .month, .year], from: now)

        let key = ApptilausManager.kLastSessionRegisteredPrefix + appId
        
        let timeParamName: String
        
        if let lastCallMillis = UserDefaults.standard.value(forKey: key) as? Double {
            let lastCall = Date(timeIntervalSince1970: lastCallMillis / 1000)
            
            let lastCallComponents = cal.dateComponents([.day, .month, .year], from: lastCall)
            
            if (todayComponents == lastCallComponents) {
                print("[Apptilaus]: already registered session today")

                return; //already registered session today
            }
            
            timeParamName = "dp_session"
        } else {
            timeParamName = "dp_install"
        }
        
        var queryItems:[URLQueryItem] = []
                
        queryItems.append(URLQueryItem(name: timeParamName, value: String(lround(nowMillis))))
        
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            queryItems.append(URLQueryItem(name: "ios_idfa", value: ASIdentifierManager.shared().advertisingIdentifier.uuidString))
        } else {
            queryItems.append(URLQueryItem(name: "ios_idfa", value: "00000000-0000-0000-0000-000000000000"))
        }
        
        if let idfv = UIDevice.current.identifierForVendor {
            queryItems.append(URLQueryItem(name: "ios_idfv", value: idfv.uuidString))
        }
        
        let url = baseUrl.appendingPathComponent("v1/device/\(appId)/")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        
        guard let requestUrl = components?.url else {
            print("[Apptilaus]: failed to create request URL with base URL \(url), params \(String(describing: components))")
            return;
        }
                
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "App-Bundle")
        
        let task = URLSession.shared.dataTask(with: request) { (dataOpt, responseOpt, errOpt) in
            if let error = errOpt {
                print("[Apptilaus]: session was not registered, due to error: \(error)")
            } else if let response = responseOpt,
                let httpResponse = response as? HTTPURLResponse,
                (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
                print("[Apptilaus]: session API HTTP Error \(httpResponse.statusCode)")
                if let data = dataOpt {
                    print(String(data: data, encoding: .utf8) ?? "invalid response encoding")
                }
            } else {
                UserDefaults.standard.set(nowMillis, forKey: key)
                print("[Apptilaus]: session registered")
            }
        }
        task.resume()
    }
    
    @objc public func register(transaction: SKPaymentTransaction, customParams: [String : Any]? = nil) {
        guard let appId = self.appId else {
            print("[Apptilaus]: appId not set")
            return
        }
        
        guard let appToken = self.appToken else {
            print("[Apptilaus]: appToken not set")
            return
        }

        let requestDelegate = TransactionProductRequestDelegate(with: transaction,
                                                                appId: appId,
                                                                appToken: appToken,
                                                                userId: self.userId,
                                                                baseUrl: self.baseUrl,
                                                                customParams: customParams ?? [ : ],
                                                                completion: self.unretain)
        delegates.insert(requestDelegate)
        
        let request = SKProductsRequest(productIdentifiers: [transaction.payment.productIdentifier])
        request.delegate = requestDelegate
        request.start()
    }
    
    @objc public func gdprOptOut(customParams: [String : Any]? = nil, completionHandler: @escaping CompletionHandler = {_,_ in }) {
        guard let baseUrl = URL(string: self.baseUrl) else {
            print("[Apptilaus]: failed to create request URL with base URL \(self.baseUrl), app ID \(String(describing: self.appId))")
            return
        }
        
        var queryItems:[URLQueryItem] = []
        
        let idfaString: String
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            idfaString = "00000000-0000-0000-0000-000000000000"
        }
        queryItems.append(URLQueryItem(name: "ios_idfa", value: idfaString))
        
        if let idfv = UIDevice.current.identifierForVendor {
            queryItems.append(URLQueryItem(name: "ios_idfv", value: idfv.uuidString))
        }
        
        if let customParams = customParams {
            for key in customParams.keys {
                let dpKey = "dp_\(key)"
                queryItems.append(URLQueryItem(name: dpKey, value: String(describing: customParams[key]!)))
            }
        }
        
        let url = baseUrl.appendingPathComponent("v1/optout")

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        
        guard let requestUrl = components?.url else {
            print("[Apptilaus]: failed to create request URL with base URL \(url), params \(String(describing: components))")
            return;
        }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "App-Bundle")

        let task = URLSession.shared.dataTask(with: request) { (dataOpt, responseOpt, errOpt) in
            let success: Bool
            if let error = errOpt {
                success = false
                print("[Apptilaus]: optOut was not registered, due to error: \(error)")
            } else if let response = responseOpt,
                let httpResponse = response as? HTTPURLResponse,
                (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
                success = false
                print("[Apptilaus]: optOut API HTTP Error \(httpResponse.statusCode)")
                if let data = dataOpt {
                    print(String(data: data, encoding: .utf8) ?? "invalid response encoding")
                }
            } else {
                success = true
                print("[Apptilaus]: optOut processed")
            }
            completionHandler(success, errOpt)
        }
        task.resume()
    }
}

private class TransactionProductRequestDelegate: NSObject, SKProductsRequestDelegate {
    private let transaction: SKPaymentTransaction
    private let appId: String
    private let appToken: String
    private let userId: String?
    private let customParams: [String : Any]
    private let completion: (TransactionProductRequestDelegate) -> ()
    private let baseUrl: String
    
    init(with transaction: SKPaymentTransaction,
         appId: String,
         appToken: String,
         userId: String?,
         baseUrl: String,
         customParams: [String : Any],
         completion: @escaping (TransactionProductRequestDelegate)->()) {
        self.transaction = transaction
        self.appId = appId
        self.appToken = appToken
        self.userId = userId
        self.baseUrl = baseUrl
        self.customParams = customParams
        self.completion = completion
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let productId = self.transaction.payment.productIdentifier
        let productOpt = response.products.first { $0.productIdentifier == productId }
        if let product = productOpt {
            self.register(product: product)
        } else {
            print("[Apptilaus]: failed to get product with identifier \"\(productId)\"")
        }
    }
    
    private func register(product: SKProduct) {
        guard let params = self.params(for: product) else {
            print("[Apptilaus]: failed to create request parameters")
            return
        };
        
        guard let json = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) else {
            print("[Apptilaus]: failed to serialize request parameters to JSON:")
            print("[Apptilaus]: \(params.debugDescription)")
            return
        }
        
        guard let baseUrl = URL(string: self.baseUrl) else {
            print("[Apptilaus]: failed to create request URL with base URL \(self.baseUrl), app ID \(self.appId)")
            return
        }
        
        let url = baseUrl.appendingPathComponent("v1/purchase/\(self.appId)/")
        var request = URLRequest(url: url)
        request.httpBody = json
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(self.appToken, forHTTPHeaderField: "App-Token")
        request.setValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "App-Bundle")

        let task = URLSession.shared.dataTask(with: request) { (dataOpt, responseOpt, errOpt) in
            if let error = errOpt {
                print("[Apptilaus]: transaction \(String(describing: self.transaction.transactionIdentifier)) was not registered, due to error: \(error)")
            } else if let response = responseOpt,
                        let httpResponse = response as? HTTPURLResponse,
                        (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
                print("[Apptilaus]: transaction \(String(describing: self.transaction.transactionIdentifier)) API HTTP Error \(httpResponse.statusCode)")
                if let data = dataOpt {
                    print(String(data: data, encoding: .utf8) ?? "invalid response encoding")
                }
            } else {
                print("[Apptilaus]: Purchase Processed")
            }
            self.completion(self)
        }
        task.resume()
    }
    
    private func params(for product: SKProduct) -> [String : Any]? {
        var params: [String : Any] = [:]
        
        if let podVersion = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            params["sdk_version"] = podVersion
        }
        
        if transaction.transactionState != .purchased {
            print("[Apptilaus]: transaction \(transaction) is in incorrect state (\(transaction.transactionState))")
            return nil
        }
        
        
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            params["ios_idfa"] = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            params["ios_idfa"] = "00000000-0000-0000-0000-000000000000"
        }
        
        if let idfv = UIDevice.current.identifierForVendor {
            params["ios_idfv"] = idfv.uuidString
        } else {
            print("[Apptilaus]: identifierForVendor is not available")
            return nil
        }
        
        if let txId = transaction.transactionIdentifier {
            params["transaction_id"] = txId
        } else {
            print("[Apptilaus]: transactionIdentifier is empty")
            return nil
        }
        
        if let txDate = transaction.transactionDate {
            let millis = UInt64(txDate.timeIntervalSince1970 * 1000)
            params["transaction_date"] = millis
        }
        
        if let originalTransaction = transaction.original {
            if let originalTxId = originalTransaction.transactionIdentifier {
                params["original_transaction_id"] = originalTxId
            }
            if let originalTxDate = originalTransaction.transactionDate {
                let millis = UInt64(originalTxDate.timeIntervalSince1970 * 1000)
                params["original_transaction_date"] = millis
            }
        }
        
        if let receiptUrl = Bundle.main.appStoreReceiptURL,
            let receiptData = try? Data(contentsOf: receiptUrl) {
            params["receipt"] = receiptData.base64EncodedString()
        } else {
            print("[Apptilaus]: cannot read AppStore receipt")
            return nil
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2;
        formatter.minimumFractionDigits = 2;
        formatter.decimalSeparator = ".";

        params["price"] = formatter.string(from: product.price)
        
        if let currencyCode = product.priceLocale.currencyCode {
            params["currency"] = currencyCode
        } else {
            print("[Apptilaus]: cannot get price currencyCode")
            return nil
        }
        
        if let regionCode = product.priceLocale.regionCode {
            params["region"] = regionCode
        } else {
            print("[Apptilaus]: cannot get price regionCode")
            return nil
        }
        
        if let userId = self.userId {
            params["user_id"] = userId
        } //user_id is optional, so no `else`
        
        
        for key in customParams.keys {
            let dpKey = "dp_\(key)"
            params[dpKey] = customParams[key]!
        }
        
        return params
    }
}
