//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class TransactionPresenter: NSObject {
    var transctionVC: TransactionViewController?
    
    let receiveBackColor = UIColor(red: 95/255, green: 204/255, blue: 125/255, alpha: 1.0)
    let sendBackColor = UIColor(red: 0/255, green: 183/255, blue: 255/255, alpha: 1.0)
    let waitingConfirmationBackColor = UIColor(red: 249/255, green: 250/255, blue: 255/255, alpha: 1.0)
    let rejectedColor = UIColor(red: 235/255, green: 20/255, blue: 59/255, alpha: 1.0)
    
    var histObj = HistoryRLM()
    var blockchainType = BlockchainType.init(blockchain: BLOCKCHAIN_BITCOIN, net_type: -1)
    var wallet = UserWalletRLM() {
        didSet {
            blockchain = wallet.blockchainType.blockchain
        }
    }
    
    var blockchain: Blockchain?
    var selectedAddress: String?
    
    func blockedAmount(for transaction: HistoryRLM) -> UInt64 {
        var sum = UInt64(0)
        
        if transaction.txStatus.intValue == TxStatus.MempoolIncoming.rawValue {
            sum += transaction.txOutAmount.uint64Value
        } else if transaction.txStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
            for tx in transaction.txOutputs {
                sum += tx.amount.uint64Value
            }
        }
        
        return sum
    }
    
    func setupUI(isRejected: Bool, isIncoming: Bool) {
        if isRejected {
            transctionVC?.makeBackColor(color: rejectedColor)
            transctionVC?.transactionImg.image = #imageLiteral(resourceName: "warninngBig")
            if isIncoming {
                transctionVC?.titleLbl.text = transctionVC?.localize(string: Constants.incomingRejectedTransactionString)
            } else if isIncoming == false {                        
                transctionVC?.titleLbl.text = transctionVC?.localize(string: Constants.outcomingRejectedTransactionString)
                transctionVC?.viewInBlockchainBtn.setTitle("Resend", for: .normal)
            }
        } else {
            transctionVC?.titleLbl.text = transctionVC?.localize(string: Constants.transactionInfoString)
            if isIncoming {
                transctionVC?.makeBackColor(color: receiveBackColor)
            } else {
                transctionVC?.makeBackColor(color: sendBackColor)
                transctionVC?.transactionImg.image = #imageLiteral(resourceName: "sendBigIcon")
            }
        }
    }
}


