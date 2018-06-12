//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class TokenTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tokenImg: UIImageView!
    @IBOutlet weak var tokenName: UILabel!
    @IBOutlet weak var tokenAmountLbl: UILabel!  // add short chain name
    @IBOutlet weak var fiatPercentLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
