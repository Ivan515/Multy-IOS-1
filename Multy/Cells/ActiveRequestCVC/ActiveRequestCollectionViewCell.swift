//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import Lottie

class ActiveRequestCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var requestImage: UIImageView!
    @IBOutlet weak var satisfiedImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        requestImage.layer.cornerRadius = requestImage.frame.size.width/2
        requestImage.layer.masksToBounds = true
    }

    var request : PaymentRequest!
    
    func fillInCell() {
        requestImage.image  = UIImage(named: request!.requestImageName)
        satisfiedImage.isHidden = !self.request.satisfied 
    }
}

