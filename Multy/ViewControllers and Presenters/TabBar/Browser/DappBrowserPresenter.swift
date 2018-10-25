//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
//import MultyCoreLibrary


private typealias BrowserCacheDelegate = DappBrowserPresenter
private typealias LocalizeDelegate = DappBrowserPresenter

class DappBrowserPresenter: NSObject, BrowserCoordinatorDelegate {
    weak var mainVC: DappBrowserViewController?
    var browserCoordinator: BrowserCoordinator?
    var tabBarFrame: CGRect?
    
    var defaultBlockchainType = BlockchainType(blockchain: BLOCKCHAIN_ETHEREUM, net_type: 4)
    var defaultURLString = "https://dragonereum-alpha-test.firebaseapp.com"  //"https://app.alpha.dragonereum.io // "https://dapps.trustwalletapp.com"
    
    var dragonDLObj: DragonDLObj? {
        didSet {
            if dragonDLObj != nil {
                self.defaultBlockchainType = BlockchainType(blockchain: Blockchain(UInt32(dragonDLObj!.chainID)), net_type: dragonDLObj!.chaintType)
                self.defaultURLString = dragonDLObj!.browserURL
            }
        }
    }
    
    var isBackButtonHidden = true {
        didSet {
            if oldValue != isBackButtonHidden {
                mainVC?.updateUI()
            }
        }
    }
    
    weak var delegate: SendWalletProtocol?

    var wallet: UserWalletRLM? {
        didSet {
            if oldValue != wallet {
                if oldValue == nil {
                    loadWebViewContent()
                }
                mainVC?.updateUI()
            }
        }
    }
    
    var currentHistoryIndex : Int = 0 {
        didSet {
            isBackButtonHidden = currentHistoryIndex == 0
        }
    }
    
    func vcViewDidLoad() {
        tabBarFrame = mainVC?.tabBarController?.tabBar.frame
        loadETHWallets()
    }
    
    func vcViewWillAppear() {
        
        mainVC?.configureUI()
        mainVC?.updateUI()
    }
    
    func vcViewDidAppear() {
    }
    
    func loadETHWallets() {
        DataManager.shared.getWalletsVerbose() { [unowned self] (walletsArrayFromApi, err) in
            if err != nil {
                return
            } else {
                let walletsArray = UserWalletRLM.initArrayWithArray(walletsArray: walletsArrayFromApi!)
                //FIXME: MS wallets
                let choosenWallet = walletsArray.filter { $0.blockchainType == self.defaultBlockchainType }.sorted(by: { return $0.allETHBalance > $1.allETHBalance }).first
                
                DispatchQueue.main.async { [unowned self] in
                    if choosenWallet == nil {
                        self.createFirstWalletAndLoadBrowser()
                    } else {
                        self.wallet = choosenWallet
                    }
                }
            }
        }
    }
    
    func loadPreviousPage() {
        browserCoordinator?.runAction(action: .navigationAction(.goBack))
    }
    
    func loadPageWithURLString(_ urlString: String) {
        let url = URL(string: urlString)
        if url != nil {
            browserCoordinator?.browserViewController.goTo(url: url!)
        }
    }
    
    func didSentTransaction(transaction: SentTransaction, in coordinator: BrowserCoordinator) {
        
    }
    
    func didUpdateHistory(coordinator: BrowserCoordinator) {
        
        mainVC?.updateUI()
    }
    
    fileprivate func loadWebViewContent() {
        clear(cache: true, cookies: true)
        
        DispatchQueue.main.async { [unowned self] in
            self.browserCoordinator = BrowserCoordinator(wallet: self.wallet!, urlString: self.defaultURLString)
            self.browserCoordinator!.delegate = self
            self.mainVC!.add(self.browserCoordinator!.browserViewController, to: self.mainVC!.browserView)
            self.browserCoordinator!.start()
        }
    }
    
    fileprivate func createFirstWalletAndLoadBrowser() {
        createFirstWallets(blockchianType: defaultBlockchainType)
    }
    
    func createFirstWallets(blockchianType: BlockchainType) {
        let account = DataManager.shared.realmManager.account!
        var binData = account.binaryDataString.createBinaryData()!
        let createdWallet = UserWalletRLM()
        
        //MARK: topIndex
        let currencyID = blockchianType.blockchain.rawValue
        let networkID = blockchianType.net_type
        
        var currentTopIndex = account.topIndexes.filter("currencyID = \(currencyID) AND networkID == \(networkID)").first
        
        if currentTopIndex == nil {
            currentTopIndex = TopIndexRLM.createDefaultIndex(currencyID: NSNumber(value: currencyID), networkID: NSNumber(value: networkID), topIndex: NSNumber(value: 0))
        }
        
        let dict = DataManager.shared.createNewWallet(for: &binData, blockchain: blockchianType, walletID: currentTopIndex!.topIndex.uint32Value)
        
        createdWallet.chain = NSNumber(value: currencyID)
        createdWallet.chainType = NSNumber(value: networkID)
        createdWallet.name = "Dragonereum Wallet"
        createdWallet.walletID = NSNumber(value: Int32(dict!["walletID"] as! UInt32))
        createdWallet.addressID = NSNumber(value: Int32(dict!["addressID"] as! UInt32))
        createdWallet.address = dict!["address"] as! String
        
        if createdWallet.blockchainType.blockchain == BLOCKCHAIN_ETHEREUM {
            createdWallet.ethWallet = ETHWallet()
            createdWallet.ethWallet?.balance = "0"
            createdWallet.ethWallet?.nonce = NSNumber(value: 0)
            createdWallet.ethWallet?.pendingWeiAmountString = "0"
        }
        
        let params = [
            "currencyID"    : currencyID,
            "networkID"     : networkID,
            "address"       : createdWallet.address,
            "addressIndex"  : createdWallet.addressID,
            "walletIndex"   : createdWallet.walletID,
            "walletName"    : createdWallet.name
            ] as [String : Any]
        
        DataManager.shared.addWallet(params: params) { [unowned self] (dict, error) in
            if error == nil {
                self.loadETHWallets()
            } else {
                self.mainVC!.presentAlert(withTitle: self.localize(string: Constants.errorString), andMessage: self.localize(string: Constants.errorWhileCreatingWalletString))
            }
        }
    }
}

extension BrowserCacheDelegate {
    func clear(cache: Bool, cookies: Bool) {
        if cache { clearCache() }
        if cookies { clearCookies() }
    }
    
    fileprivate func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    
    fileprivate func clearCookies() {
        let cookieStorage = HTTPCookieStorage.shared
        
        guard let cookies = cookieStorage.cookies else { return }
        
        cookies.forEach { cookieStorage.deleteCookie($0) }
    }
}


extension DappBrowserPresenter: SendWalletProtocol {
    func sendWallet(wallet: UserWalletRLM) {
        self.wallet = wallet
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "DappBrowser"
    }
}