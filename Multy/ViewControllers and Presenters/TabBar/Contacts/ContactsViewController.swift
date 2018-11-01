//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias TableViewDelegate = ContactsViewController
private typealias TableViewDataSource = ContactsViewController
private typealias LocalizeDelegate = ContactsViewController
private typealias AnalyticsDelegate = ContactsViewController

class ContactsViewController: UIViewController, CancelProtocol {

    @IBOutlet weak var donatView: UIView!
    var presenter = ContactsPresenter()
    @IBOutlet weak var donationTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noContactsImageView: UIImageView!
    @IBOutlet weak var noContactsLabel: UILabel!
//    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var addNewBtn: UIButton!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    //delegate's ivars
    var chooseContactsAddressDelegate: ChooseContactsAddressProtocol?
    var choosenWallet: UserWalletRLM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.mainVC = self
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setupView()
        ipadFix()
        sendAnalyticsEvent(screenName: screenContacts, eventName: screenContacts)
        
        presenter.tabBarFrame = tabBarController?.tabBar.frame
        presenter.registerCell()
        presenter.checkEmptyState()
        if chooseContactsAddressDelegate != nil {
            addNewBtn.isHidden = true
            backButton.isHidden = false
            backImageView.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.fetchPhoneContacts()
        
        tabBarController?.tabBar.frame = presenter.tabBarFrame!
        (self.tabBarController as? CustomTabBarViewController)?.changeViewVisibility(isHidden: chooseContactsAddressDelegate != nil)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentStatusStyle
    }
    
    func ipadFix() {
        if screenHeight == heightOfiPad {
            self.donationTopConstraint.constant = 0
        }
    }
    
    @IBAction func donatAction(_ sender: Any) {
        unowned let weakSelf =  self
        self.presentDonationAlertVC(from: weakSelf, with: "io.multy.addingContacts50")
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
        logDonationAnalytics()
    }
    
    func setupView() {
        self.donatView.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9994150996, alpha: 1)
        self.donatView.layer.borderWidth = 1
        
//        floatingView.layer.cornerRadius = floatingView.frame.width/2
//        addNewBtn.makeBlueGradient()
    }
    
    func cancelAction() {
        self.makePurchaseFor(productId: "io.multy.addingContacts5")
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: false)
    }
    
    func donate50(idOfProduct: String) {
        self.makePurchaseFor(productId: idOfProduct)
    }
    
    func presentNoInternet() {
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: false)
    }
    
    @IBAction func addUser(_ sender: Any) {
        presentiPhoneContacts()
        logContactsAnalytics()
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Storyboard.contactVCSegueID {
            let contactVC = segue.destination as! ContactViewController
            let indexPath = sender as! IndexPath
            contactVC.presenter.contact = presenter.contacts[indexPath.row]
            contactVC.presenter.indexPath = indexPath
            contactVC.chooseContactsAddressDelegate = chooseContactsAddressDelegate
            contactVC.choosenWallet = choosenWallet
        }
    }
}

extension TableViewDelegate : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "contactVC", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension AnalyticsDelegate: AnalyticsProtocol {
    func logDonationAnalytics() {
        sendDonationAlertScreenPresentedAnalytics(code: donationForContactSC)
    }
    
    func logContactsAnalytics() {
        sendAnalyticsEvent(screenName: contactsScreen, eventName: openiPhoneContacts)
    }
    
    func logAddedContactAnalytics() {
        sendAnalyticsEvent(screenName: contactsScreen, eventName: contactAdded)
    }
}

extension TableViewDataSource : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EPContactCell
        cell.accessoryType = UITableViewCellAccessoryType.none
        //Convert CNContact to EPContact
        let contact = presenter.contacts[indexPath.row]
        cell.updateContactsinUI(contact, indexPath: indexPath, subtitleType: .cryptoAddresses)
        
        return cell
    }
}

extension ContactsViewController: EPPickerDelegate {
    func epContactPicker(_: EPContactsPicker, didSelectContact contact: EPContact) {
        if contact.contactId == nil {
            return
        }
        
        presenter.updateContactInfo(contact.contactId!, withAddress: nil, nil, nil) { [unowned self] (result) in
            DispatchQueue.main.async {
                self.logAddedContactAnalytics()
                self.presenter.fetchPhoneContacts()
            }
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Contacts"
    }
}
