//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class JoinMultiSigPresenter: NSObject {

    var mainVC: JoinMultiSigViewController?
    
    func validate(inviteCode: String) {
        // fix it: set !=
        if inviteCode.count < inviteCodeCount {
            mainVC!.presentAlert(with: mainVC?.localize(string: Constants.badInviteCodeString))
            return
        }
        
        DataManager.shared.validateInviteCode(code: inviteCode) { result in
            switch result {
            case .success(let value):
                let isExists = value["exists"] as! Int
                
                if isExists != 0 {
                    let currencyID = value["currencyid"] as! UInt32
                    let networkID = value["networkid"] as! UInt32
                    let blockchainType = BlockchainType.create(currencyID: currencyID, netType: networkID)
                    self.mainVC!.navigationController?.popViewController(animated: true)
                    self.mainVC!.blockchainTransferDelegate?.setBlockchain(blockchain: blockchainType)
                    self.mainVC!.qrDelegate?.qrData(string: inviteCode, tag: "joinMS")
                } else {
                    self.mainVC!.textView.text = ""
                    self.mainVC!.captureSession?.startRunning()
                    self.mainVC!.presentAlert(with: self.mainVC?.localize(string: Constants.msIsFull))
                }
               
            case .failure(let error):
                self.mainVC?.presentAlert(with: error)
            }
        }
    }
}
