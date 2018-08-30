import UIKit
import StoreKit
import Apptilaus

class ViewController: UIViewController {
    
    private let productIds = ["test.purchase.one",
                              "test.subscription.renew.week",
                              "test.subscription.norenew.week"]
    
    private var buttons: [UIButton] = []
    
    private var products: [String : SKProduct] = [:]
    
    @IBOutlet private var purchase1: UIButton?
    @IBOutlet private var purchase2: UIButton?
    @IBOutlet private var purchase3: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        
        self.buttons = [self.purchase1!, self.purchase2!, self.purchase3!]
        let req = SKProductsRequest(productIdentifiers: Set(self.productIds))
        req.delegate = self;
        req.start()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonTap(sender: UIButton) {
        if let index = self.buttons.index(of: sender),
            let product = self.products[self.productIds[index]] {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
        
    }
    
}

extension ViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        for product in response.products {
            self.products[product.productIdentifier] = product
            if let index = self.productIds.index(of: product.productIdentifier) {
                let button = self.buttons[index]
                formatter.locale = product.priceLocale
                let title = "\(product.localizedTitle) \(String(describing: formatter.string(from: product.price)))"
                button.setTitle(title, for: .normal)
            }
        }
        print("response: \(response.products)")
    }
}

extension ViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print ("updated tx: \(String(describing: transaction.transactionIdentifier)) state: \(transaction.transactionState))")
            if transaction.transactionState == .purchased {
                let customParameters: [String : Any] = [
                    "foo": "bar",
                    "goats_count": 123
                ];
                
                ApptilausManager.shared.register(transaction: transaction, customParams: customParameters)

                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed,
                let error = transaction.error {
                print ("tx: \(String(describing: transaction.transactionIdentifier)) failed with error: \(error)")
            }
        }
    }
    
}
