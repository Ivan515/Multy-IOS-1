//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = DonationCollectionViewCell

class DonationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var midLbl: UILabel!
    @IBOutlet weak var botView: UIView!
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var assetsView: UIView!
    @IBOutlet weak var assetsSumLbl: UILabel!
    @IBOutlet weak var decimalPartLbl: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var leftPrView: UIView!
    @IBOutlet weak var rigthPrView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func makeCellBy(index: Int, assetsInfo: String?) {
        switch index {
        case 1:
            //First Banner
//            self.bannerImg.isHidden = false
//            self.bannerImg.image = UIImage(named: "dragonereumAppBanner900X6001001")
//            self.bannerImg.layer.masksToBounds = true
//            self.setupUIfor(view: botView, color: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 1))
            assetsView.isHidden = true
            self.backgroundImg.image = #imageLiteral(resourceName: "portfolioDonationImage")
            self.midLbl.text = localize(string: Constants.cryptoPortfolioString)
            self.bannerImg.isHidden = true
            self.setupUIfor(view: botView, color: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.6))
        case 2:
            assetsView.isHidden = true
            self.backgroundImg.image = #imageLiteral(resourceName: "chartsDonationImage")
            self.midLbl.text = localize(string: Constants.currenciesChartsString)
            self.bannerImg.isHidden = true
            self.setupUIfor(view: botView, color: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.6))
        case 0:
            assetsView.isHidden = false
            let assetsInfoComponents = assetsInfo!.components(separatedBy: CharacterSet(charactersIn: ".,"))
            assetsSumLbl.text = assetsInfoComponents[0] //integer part
            decimalPartLbl.text = assetsInfoComponents.count > 1 ? ".\(assetsInfoComponents[1])" : ".00"   //decimal part1
            setupUIfor(view: botView, color: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.6))
        default: break
        }
    }
    
    func setupUIfor(view: UIView, color: CGColor ) {
        view.layer.shadowColor = color
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
//        if screenHeight == heightOfiPad || screenHeight == heightOfFive {   // ipad fix
//            self.backgroundImg.contentMode = .scaleToFill
//        }
    }

}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Assets"
    }
}
