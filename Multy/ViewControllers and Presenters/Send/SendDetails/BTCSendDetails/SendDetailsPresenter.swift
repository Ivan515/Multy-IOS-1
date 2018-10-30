//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

private typealias LocalizeDelegate = SendDetailsPresenter
private typealias CustomFeeRateDelegate = SendDetailsPresenter

class SendDetailsPresenter: NSObject {
    
    var vc: SendDetailsViewController?
    var transactionDTO = TransactionDTO() {
        didSet {
            availableSumInCrypto = transactionDTO.choosenWallet!.availableBalance
            availableSumInFiat = transactionDTO.choosenWallet!.availableAmountInFiat
            cryptoName = transactionDTO.blockchain!.shortName
            fiatName = transactionDTO.choosenWallet!.fiatName
            feeRates = defaultFeeRates()
        }
    }
    
    var availableSumInCrypto    : BigInt?
    var availableSumInFiat      : BigInt?
    
    var selectedIndexOfSpeed: Int? {
        didSet {
            if oldValue != selectedIndexOfSpeed {
                updateTransaction()
            }
        }
    }
    
    // Donation
    var isDonationSwitchedOn : Bool? {
        didSet {
            if isDonationSwitchedOn != nil {
                donationInCrypto = isDonationSwitchedOn! ? BigInt("\(minBTCDonationAmount)") : BigInt.zero()
            } else {
                donationInCrypto = nil
            }
            vc?.updateDonationUI()
        }
    }
    
    var donationInCrypto: BigInt? {
        didSet {
            if oldValue != donationInCrypto {
                updateTransaction()
                vc?.updateDonationUI()
            }
        }
    }
    
    var donationInFiat: BigInt? {
        get {
            guard donationInCrypto != nil else {
                return nil
            }
            
            return donationInCrypto! * transactionDTO.choosenWallet!.exchangeCourse
        }
    }
    
    var cryptoName = ""
    var fiatName = ""
    
    var customFee: BigInt? {
        didSet {
            if oldValue != customFee {
                vc?.tableView.reloadData()
            }
        }
    }
    
    var feeRates : NSDictionary? {
        didSet {
            vc?.tableView.reloadData()
            updateCellsVisibility()
        }
    }
    
    var isDonationAvailable : Bool {
        get {
            let blockchainType = BlockchainType.create(wallet: transactionDTO.choosenWallet!)
            return blockchainType.blockchain == BLOCKCHAIN_BITCOIN
        }
    }
    
    
    func vcViewDidLoad() {
        vc?.setupUI()
        requestFee()
    }
    
    func vcViewWillAppear() {
    }
    
    func requestFee() {
        DataManager.shared.getFeeRate(currencyID: transactionDTO.choosenWallet!.chain.uint32Value,
                                      networkID: transactionDTO.choosenWallet!.chainType.uint32Value,
                                      ethAddress: transactionDTO.sendAddress,
                                      completion: { [weak self] (dict, error) in
                                        guard self != nil else {
                                            return
                                        }
                                        
                                        self!.vc?.loader.hide()
                                        
                                        if dict != nil {
                                            self!.feeRates = dict!["speeds"] as? NSDictionary
                                        } else {
                                            print("Did failed getting feeRate")
                                        }
        })
    }
    
    func defaultFeeRates() -> NSDictionary {
        return transactionDTO.blockchain == BLOCKCHAIN_BITCOIN ? DefaultFeeRates.btc.hashValue : DefaultFeeRates.eth.hashValue
    }
    
    func feeRateForIndex(_ index: Int) -> (name: String, value: BigInt) {
        switch index {
        case 0:
            return (localize(string: Constants.veryFastString), BigInt("\(feeRates!["VeryFast"])"))
        case 1:
            return (localize(string: Constants.fastString), BigInt("\(feeRates!["Fast"]!)"))
        case 2:
            return (localize(string: Constants.mediumString), BigInt("\(feeRates!["Medium"]!)"))
        case 3:
            return (localize(string: Constants.slowString), BigInt("\(feeRates!["Slow"]!)"))
        case 4:
            return (localize(string: Constants.verySlowString), BigInt("\(feeRates!["VerySlow"]!)"))
        case 5:
            return (localize(string: Constants.customString), customFee ?? BigInt.zero())
        default:
            return ("", BigInt.zero())
        }
    }
    
    func updateTransaction() {
        if selectedIndexOfSpeed != nil {
            let feeRate = feeRateForIndex(selectedIndexOfSpeed!)
            transactionDTO.feeRate = feeRate.value
        }
        
        transactionDTO.donationAmount = donationInCrypto
    }
    
    func segueToAmount() {
        if self.availableSumInCrypto == nil || availableSumInCrypto! < 0.0 {
            self.vc?.presentWarning(message: "Wrong wallet data. Please download wallet data again.")
            
            return
        }
        
        if isDonationSwitchedOn != nil && isDonationSwitchedOn! {
            if self.donationInCrypto! > self.availableSumInCrypto!  {
                self.vc?.presentWarning(message: "Your donation more than you have in wallet.\n\nDonation sum: \(self.donationInCrypto!.cryptoValueString(for: transactionDTO.choosenWallet!.blockchain)) \(self.cryptoName)\n Sum in Wallet: \(self.availableSumInCrypto!.cryptoValueString(for: transactionDTO.choosenWallet!.blockchain)) \(self.cryptoName)")
            } else if self.donationInCrypto! == self.availableSumInCrypto! {
                self.vc?.presentWarning(message: "Your donation is equal your wallet sum.\n\nDonation sum: \(self.donationInCrypto!.cryptoValueString(for: transactionDTO.choosenWallet!.blockchain)) \(self.cryptoName)\n Sum in Wallet: \(self.availableSumInCrypto!.cryptoValueString(for: transactionDTO.choosenWallet!.blockchain)) \(self.cryptoName)")
            } else {
                self.vc?.performSegue(withIdentifier: "sendEthVC", sender: Any.self)
            }
        } else {
            self.vc?.performSegue(withIdentifier: "sendEthVC", sender: Any.self)
        }
    }
    
    func updateCellsVisibility () {
        var cells = vc?.tableView.visibleCells
        let selectedCell = selectedIndexOfSpeed == nil ? nil : cells![selectedIndexOfSpeed!]
        
        for cell in cells! {
            cell.alpha = (cell === selectedCell) ? 1.0 : 0.3
            
            if !cell.isKind(of: CustomTrasanctionFeeTableViewCell.self) {
                (cell as! TransactionFeeTableViewCell).checkMarkImage.isHidden = (cell !== selectedCell)
            }
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}

extension CustomFeeRateDelegate: CustomFeeRateProtocol {
    func customFeeData(firstValue: Int?, secValue: Int?) {
        guard firstValue != nil else {
            return
        }
        
        customFee = BigInt("\(firstValue!)")
        vc?.sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(transactionDTO.choosenWallet!.chain)", eventName: customFeeSetuped)
    }

    
    func setPreviousSelected(index: Int?) {
        self.vc?.tableView.selectRow(at: [0,index!], animated: false, scrollPosition: .none)
        self.vc?.tableView.delegate?.tableView!(self.vc!.tableView, didSelectRowAt: [0,index!])
        self.selectedIndexOfSpeed = index!
    }
}
