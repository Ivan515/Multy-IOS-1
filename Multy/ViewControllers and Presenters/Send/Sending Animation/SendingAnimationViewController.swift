//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import ZFRippleButton

private typealias LocalizeDelegate = SendingAnimationViewController

class SendingAnimationViewController: UIViewController, AnalyticsProtocol {

    @IBOutlet var backView: UIView!
    @IBOutlet weak var sendingImage: UIImageView!
    @IBOutlet weak var sendingLbl: UILabel!
    @IBOutlet weak var closeBtn: ZFRippleButton!
    @IBOutlet weak var transactionInfoView: UIView!
    @IBOutlet weak var transactionAddressLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
    @IBOutlet weak var addressNameLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var warningLabel: UILabel!
    
    let presenter = SendingAnimationPresenter()
    
    let when = DispatchTime.now() + 0.1 // change 2 to desired number of seconds

    var chainId: Int?
    var indexForTabBar: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.sendingAnimationVC = self
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.sendOK()
        }
        
        if chainId == nil {
            return
        }
        
        if presenter.fromVCType == Optional<PopDestination>(.exchange) {
            warningLabel.isHidden = false
        }
        
        sendAnalyticsEvent(screenName: "\(screenSendSuccessWithChain)\(chainId!)", eventName: "\(screenSendSuccessWithChain)\(chainId!)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewControllerViewWillAppear()
    }
    
    func updateUI() {
        if presenter.transactionAddress != nil && presenter.transactionAmount != nil {
            transactionInfoView.isHidden = false
            transactionAmountLabel.text = presenter.transactionAmount
            
            let address = presenter.transactionAddress!
            transactionAddressLabel.text = address
            
            let addressName = DataManager.shared.name(for: address)
            if addressName.isEmpty {
                addressNameLabel.isHidden = true
                addressNameLabel.text = ""
                bottomConstraint.constant = 20
            } else {
                addressNameLabel.isHidden = false
                addressNameLabel.text = addressName
                bottomConstraint.constant = 12
            }
        } else {
            transactionInfoView.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.backView.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                  UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                    gradientOrientation: .topRightBottomLeft)
        
        self.closeBtn.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                  UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                    gradientOrientation: .horizontal)
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        if indexForTabBar == nil {
            tabBarController?.selectedIndex = 0
        } else {
            if let tbc = tabBarController as? CustomTabBarViewController {
                tbc.setSelectIndex(from: indexForTabBar!, to: indexForTabBar!)
            }
        }
        
        guard let popToVCType = presenter.fromVCType else {
            navigationController?.popToRootViewController(animated: true)
            
            return
        }
        
        switch popToVCType {
        case .exchange:
            let allVCs = navigationController!.viewControllers
            if allVCs.count > 2 {
                let destinationVC = allVCs[allVCs.count - 3]
                navigationController?.popToViewController(destinationVC, animated: true)
            } else {
                navigationController?.popToRootViewController(animated: true)
            }
        case .sendTX:
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func sendOK() {
        self.sendingImage.image = #imageLiteral(resourceName: "completeIcon")
        self.sendingLbl.text = localize(string: Constants.successString)
        self.closeBtn.isHidden = false
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
