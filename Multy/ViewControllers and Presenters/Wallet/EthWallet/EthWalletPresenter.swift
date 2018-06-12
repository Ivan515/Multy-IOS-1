//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class EthWalletPresenter: NSObject {
    var mainVC : EthWalletViewController?
    
    var topCellHeight = CGFloat(0)
    
    var isTherePendingAmount = false
    var wallet : UserWalletRLM? {
        didSet {
            isTherePendingAmount = wallet!.ethWallet?.pendingWeiAmountString != "0"
            mainVC?.titleLbl.text = self.wallet?.name
            mainVC?.collectionView.reloadData()
            if isUpdateBySocket != nil && isUpdateBySocket == true {
                mainVC?.makeConstantsForAnimation()
            }
        }
    }
    var account : AccountRLM?
    var isUpdateBySocket: Bool?
    
    var transactionsArray = [TransactionRLM]()
    var isThereAvailableAmount: Bool {
        get {
            return wallet!.ethWallet!.balance != "0"
        }
    }
    
    var historyArray = [HistoryRLM]() {
        didSet {
            reloadTableView()
        }
    }
    
    func reloadTableView() {
        if historyArray.count > 0 {
            mainVC?.hideEmptyLbls()
        }
        
        let contentOffset = mainVC!.tableView.contentOffset
        mainVC!.tableView.reloadData()
        mainVC!.tableView.layoutIfNeeded()
        mainVC!.tableView.setContentOffset(contentOffset, animated: false)
        
        self.mainVC!.refreshControl.endRefreshing()
    }
    
    func registerCells() {
        let walletHeaderCell = UINib.init(nibName: "EthWalletHeaderTableViewCell", bundle: nil)
        self.mainVC?.tableView.register(walletHeaderCell, forCellReuseIdentifier: "EthWalletHeaderCellID")
        
        //        let walletCollectionCell = UINib.init(nibName: "MainWalletCollectionViewCell", bundle: nil)
        //        self.mainVC?.tableView.register(walletCollectionCell, forCellReuseIdentifier: "WalletCollectionViewCellID")
        
        let transactionCell = UINib.init(nibName: "TransactionWalletCell", bundle: nil)
        self.mainVC?.tableView.register(transactionCell, forCellReuseIdentifier: "TransactionWalletCellID")
        
        let transactionPendingCell = UINib.init(nibName: "TransactionPendingCell", bundle: nil)
        self.mainVC?.tableView.register(transactionPendingCell, forCellReuseIdentifier: "TransactionPendingCellID")
        
        let headerCollectionCell = UINib.init(nibName: "EthWalletHeaderCollectionViewCell", bundle: nil)
        self.mainVC?.collectionView.register(headerCollectionCell, forCellWithReuseIdentifier: "MainWalletCollectionViewCellID")
        
        let tokenTableViewCell = UINib.init(nibName: "TokenTableViewCell", bundle: nil)
        self.mainVC?.tokensTable.register(tokenTableViewCell, forCellReuseIdentifier: "tokenCell")
    }
    
    func fixConstraints() {
        if #available(iOS 11.0, *) {
            //OK: Storyboard was made for iOS 11
        } else {
            self.mainVC?.tableViewTopConstraint.constant = 0
        }
    }
    
    func numberOfTransactions() -> Int {
        return self.historyArray.count
    }
    
    func isTherePendingMoney(for indexPath: IndexPath) -> Bool {
        let transaction = historyArray[indexPath.row]
        
        return transaction.txStatus.intValue == TxStatus.MempoolIncoming.rawValue
    }
    
    
    
    func getNumberOfPendingTransactions() -> Int {
        var count = 0
        
        for transaction in historyArray {
            if wallet!.blockedAmount(for: transaction) > 0 {
                count += 1
            }
        }
        
        return count
    }
    
    
    func blockUI() {
        self.mainVC?.spiner.startAnimating()
        
//        self.mainVC?.view.isUserInteractionEnabled = false
//        mainVC?.loader.show(customTitle: "Updating")

    }
    
    func unlockUI() {
        self.mainVC?.spiner.stopAnimating()
        self.mainVC?.spiner.isHidden = true
//        self.mainVC?.view.isUserInteractionEnabled = true
//        self.mainVC?.loader.hide()
    }
    
    func getHistoryAndWallet() {
//        blockUI()
        DataManager.shared.getOneWalletVerbose(walletID: wallet!.walletID, blockchain: BlockchainType.create(wallet: wallet!)) { (wallet, error) in
            if wallet != nil {
                self.wallet = wallet
            }
            DataManager.shared.getTransactionHistory(currencyID: self.wallet!.chain, networkID: self.wallet!.chainType, walletID: self.wallet!.walletID) { (histList, err) in
                //            self.unlockUI()
                self.mainVC?.spiner.stopAnimating()
                if err == nil && histList != nil {
                    //                self.mainVC!.refreshControl.endRefreshing()
                    //                self.mainVC!.tableView.isUserInteractionEnabled = true
                    //                self.mainVC!.tableView.contentOffset.y = 0
                    //                self.mainVC!.tableView.contentOffset =
                    self.historyArray = histList!.sorted(by: { $0.blockTime > $1.blockTime })
                    self.mainVC!.isSocketInitiateUpdating = false
                }
            }
        }
    }
    
    // TABLE
    func makeCellFor(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEqual(mainVC?.tableView) {
            let countOfHistObjs = numberOfTransactions()
            
            if indexPath.row < countOfHistObjs && isTherePendingMoney(for: indexPath) {
                let pendingTrasactionCell = tableView.dequeueReusableCell(withIdentifier: "TransactionPendingCellID") as! TransactionPendingCell
                pendingTrasactionCell.selectionStyle = .none
                pendingTrasactionCell.histObj = historyArray[indexPath.row]
                pendingTrasactionCell.wallet = wallet
                pendingTrasactionCell.fillCell()
                
                return pendingTrasactionCell
            } else {
                let transactionCell = self.mainVC!.tableView.dequeueReusableCell(withIdentifier: "TransactionWalletCellID") as! TransactionWalletCell
                transactionCell.selectionStyle = .none
                if countOfHistObjs > 0 {
                    if indexPath.row >= countOfHistObjs {
                        transactionCell.changeState(isEmpty: true)
                    } else {
                        transactionCell.histObj = historyArray[indexPath.row]
                        transactionCell.wallet = wallet!
                        transactionCell.fillCell()
                        transactionCell.changeState(isEmpty: false)
                        self.mainVC?.hideEmptyLbls()
                        if indexPath.row != 1 {
                            transactionCell.changeTopConstraint()
                        }
                    }
                } else {
                    transactionCell.changeState(isEmpty: true)
                    self.mainVC?.fixForiPad()
                }
                
                return transactionCell
            }
        } else { // if if tableView.isEqual(mainVC?.tokensTable) {
            let tokenCell = tableView.dequeueReusableCell(withIdentifier: "tokenCell") as! TokenTableViewCell
            
            return tokenCell
        }
    }
    
    func makeHeightForCellIn(tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        if tableView.isEqual(mainVC?.tableView) {
            if indexPath.row < numberOfTransactions() && isTherePendingMoney(for: indexPath) { // <= since we begins from 1
                return 135
            } else {
                return 70
            }
        } else { // if if tableView.isEqual(mainVC?.tokensTable) {
            return 70
        }
    }
    
    func makeNumberOfRowIn(tableView: UITableView) -> Int {
        if tableView.isEqual(mainVC?.tableView) {
            let countOfHistObjects = numberOfTransactions()
            if countOfHistObjects > 0 {
                mainVC?.tableView.isScrollEnabled = true
                if countOfHistObjects < 10 {
                    return 10
                } else {
                    return countOfHistObjects
                }
            } else {
                if screenHeight == heightOfX {
                    return 13
                }
                return 10
            }
        } else { // if if tableView.isEqual(mainVC?.tokensTable) {
            //FIX IT: return number of tokens in wallet
            return 9
        }
    }
}
