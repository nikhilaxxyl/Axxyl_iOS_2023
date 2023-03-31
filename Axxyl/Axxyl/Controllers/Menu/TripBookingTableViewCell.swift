//
//  TripBookingTableViewCell.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 30/09/22.
//

import UIKit

class TripBookingTableViewCell: UITableViewCell {

    @IBOutlet weak var dateTimeLbl: UILabel!
    
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var paymentTypeLbl: UILabel!
    @IBOutlet weak var carLbl_tripIdLbl: UILabel!
    @IBOutlet weak var pickupPointLbl: UILabel!
    @IBOutlet weak var dropPointLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setValuesFromItem(historyItem : BookingHistoryItem) {
        pickupPointLbl.text = historyItem.pickupLocation
        dropPointLbl.text = historyItem.dropLocation
        dateTimeLbl.text = historyItem.date
        priceLbl.text = "$\(historyItem.totalPrice ?? 0.0)"
    }
}
