//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
//import MultyCoreLibrary

typealias DappBrowserScrollViewDelegate = DappBrowserViewController

class DappBrowserViewController: UIViewController, UITextFieldDelegate {
    var presenter = DappBrowserPresenter()
    
    @IBOutlet weak var browserView: UIView!
    @IBOutlet weak var blockchainTypeImageView: UIImageView!
    @IBOutlet weak var backHolderViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var refreshIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.mainVC = self
        presenter.vcViewDidLoad()        
    }
    
    func configureUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        (tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: false)
        tabBarController?.tabBar.frame = presenter.tabBarFrame!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.vcViewDidAppear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.vcViewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func updateUI() {
        blockchainTypeImageView.image = UIImage(named: presenter.defaultBlockchainType.iconString)
//        backButton.isHidden = presenter.isBackButtonHidden
//        backHolderViewLeadingConstraint.constant = presenter.isBackButtonHidden ? -36 : 0
        view.layoutIfNeeded()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let urlString = textField.text
        if urlString != nil && urlString!.count > 0 {
            presenter.loadPageWithURLString(urlString!)
        }
        return true
    }
    
    @IBAction func chooseWalletAction() {
        let walletsVC = viewControllerFrom("Receive", "ReceiveStart") as! ReceiveStartViewController
        walletsVC.presenter.isNeedToPop = true
        walletsVC.presenter.preselectedWallet = presenter.wallet
        
        walletsVC.sendWalletDelegate = self.presenter

        walletsVC.presenter.displayedBlockchainOnly = presenter.defaultBlockchainType
        self.navigationController?.pushViewController(walletsVC, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        presenter.loadPreviousPage()
    }
    
//    func logAnalytics() {
//        sendDonationAlertScreenPresentedAnalytics(code: donationForActivitySC)
//    }
    
    func presentNoInternet() {
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: false)
    }
}

extension UITextField
{
    open override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 6.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1).cgColor
        self.layer.masksToBounds = true
    }
}

extension DappBrowserScrollViewDelegate: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yContentOffset = scrollView.contentOffset.y
        var navBarTopConstant = -yContentOffset
        if yContentOffset > navigationBarView.frame.size.height {
            navBarTopConstant = -navigationBarView.frame.size.height
        } else if yContentOffset < 0  {
            navBarTopConstant = navigationBarTopConstraint.constant - yContentOffset
        }
        
        navigationBarTopConstraint.constant = navBarTopConstant
        view.layoutIfNeeded()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if navigationBarTopConstraint.constant < 0 && navigationBarTopConstraint.constant > -navigationBarView.frame.size.height {
            showNavigationBar()
        }
    }
    
    func showNavigationBar() {
        navigationBarTopConstraint.constant = 0
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.view.layoutIfNeeded()
        }
    }
}
