//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = WalletChooseViewController

class WalletChooseViewController: UIViewController, AnalyticsProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyDataSourceLabel: UILabel!
    @IBOutlet weak var qrAmountLbl: UILabel!
    
    let presenter = WalletChoosePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyDataSourceLabel.text = localize(string: Constants.youDontHaveWalletString) + presenter.transactionDTO.sendAddress!.addressBlockchainValue.shortName
        
        self.enableSwipeToBack()
        self.registerCell()
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
        self.presenter.walletChoooseVC = self
        self.presenter.getWallets()
        self.checkAmountFromQr()
        sendAnalyticsEvent(screenName: screenSendFrom, eventName: screenSendFrom)
    }
    
    func registerCell() {
        let walletCell = UINib(nibName: "WalletTableViewCell", bundle: nil)
        self.tableView.register(walletCell, forCellReuseIdentifier: "walletCell")
    }
    
    func checkAmountFromQr() {
        if presenter.transactionDTO.sendAmountString != nil {
            qrAmountLbl.text = "Amount from QR: \(presenter.transactionDTO.sendAmountString!) \(presenter.transactionDTO.blockchain?.shortName ?? "")"
        } else {
            qrAmountLbl.isHidden = true
        }
    }

    @IBAction func backAction(_ sender: Any) {
        presenter.transactionDTO.choosenWallet = nil
        self.navigationController?.popViewController(animated: true)
        sendAnalyticsEvent(screenName: screenSendFrom, eventName: closeTap)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendDetailsVC" {
            let detailsVC = segue.destination as! SendDetailsViewController
            presenter.transactionDTO.choosenWallet = presenter.filteredWalletArray[presenter.selectedIndex!]
            detailsVC.presenter.transactionDTO = presenter.transactionDTO
        } 
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: false)
    }
}

extension WalletChooseViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfWallets()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let walletCell = self.tableView.dequeueReusableCell(withIdentifier: "walletCell") as! WalletTableViewCell
        walletCell.arrowImage.image = nil
        walletCell.wallet = presenter.filteredWalletArray[indexPath.row]
        walletCell.fillInCell()
        
        return walletCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if presenter.filteredWalletArray[indexPath.row].isThereAvailableAmount() == false {
            presenter.presentAlert(message: localize(string: Constants.noFundsString), blockchain: presenter.filteredWalletArray[indexPath.row].blockchain)
            
            return
        }
        
        if presenter.transactionDTO.sendAmountString != nil {
            if !presenter.filteredWalletArray[indexPath.row].isThereEnoughAmount(presenter.transactionDTO.sendAmountString!) {
                presenter.presentAlert(message: nil, blockchain: presenter.filteredWalletArray[indexPath.row].blockchain)
                
                return
            }
        }
        
        let isValidDTO = DataManager.shared.isAddressValid(address: presenter.transactionDTO.sendAddress!, for: presenter.filteredWalletArray[indexPath.row])
        
        if !isValidDTO.isValid {
            presenter.presentAlert(message: localize(string: Constants.notValidAddressString), blockchain: presenter.filteredWalletArray[indexPath.row].blockchain)
            
            return
        }
        
        self.presenter.selectedIndex = indexPath.row
        self.performSegue(withIdentifier: presenter.destinationSegueString(), sender: Any.self)
        
        sendAnalyticsEvent(screenName: screenSendFrom, eventName: "\(walletWithChainTap)\(presenter.filteredWalletArray[indexPath.row].chain)")
    }
    
    func updateUI() {
        self.tableView.reloadData()
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
