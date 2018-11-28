//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class BannerTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var mainVC: UIViewController?
    
    weak var delegate : UICollectionViewDelegate? {
        didSet {
            self.collectionView.delegate = delegate
        }
    }
    
    weak var dataSource: UICollectionViewDataSource? {
        didSet {
            self.collectionView.dataSource = dataSource
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        let portfolioCollectionCell = UINib.init(nibName: "PortfolioCollectionViewCell", bundle: nil)
        self.collectionView.register(portfolioCollectionCell, forCellWithReuseIdentifier: "portfolioCollectionCell")
        
        let donationCell = UINib.init(nibName: "DonationCollectionViewCell", bundle: nil)
        self.collectionView.register(donationCell, forCellWithReuseIdentifier: "donatCell")
        
        let magicReceiverCell = UINib.init(nibName: "MagicReceiverCollectionViewCell", bundle: nil)
        self.collectionView.register(magicReceiverCell, forCellWithReuseIdentifier: "magicReceiverCVCReuseID")
    }
}
