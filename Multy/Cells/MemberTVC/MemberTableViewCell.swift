//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = MemberTableViewCell

class MemberTableViewCell: UITableViewCell {
    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var memberAddressLabel: UILabel!
    @IBOutlet weak var userIndicatorLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    var hideSeparator = false {
        didSet {
            separatorView.isHidden = hideSeparator
        }
    }
    
    func fillWithMember(address: String, image: UIImage, isCurrentUser: Bool) {
        memberAddressLabel.text = address
        memberAddressLabel.textColor = #colorLiteral(red: 0.2117647059, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
        memberImageView.image = image
        if isCurrentUser {
            if !infoStackView.arrangedSubviews.contains(userIndicatorLabel) {
                userIndicatorLabel.isHidden = false
                infoStackView.addArrangedSubview(userIndicatorLabel)
            }
        } else {
            if infoStackView.arrangedSubviews.contains(userIndicatorLabel) {
                infoStackView.removeArrangedSubview(userIndicatorLabel)
                userIndicatorLabel.isHidden = true
            }
        }
        
        hideSeparator = false
    }
    
    func fillWaitingMember() {
        memberAddressLabel.text = localize(string: Constants.waitingMemberString) 
        memberAddressLabel.textColor = #colorLiteral(red: 0.5294117647, green: 0.631372549, blue: 0.7725490196, alpha: 1)
        memberImageView.image = UIImage(named: "waitingMember")
        if infoStackView.arrangedSubviews.contains(userIndicatorLabel) {
            infoStackView.removeArrangedSubview(userIndicatorLabel)
            userIndicatorLabel.isHidden = true
        }
        
        hideSeparator = false
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "CreateMultiSig"
    }
}

