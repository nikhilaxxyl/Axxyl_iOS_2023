//
//  TripStartedView.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 05/12/22.
//

import UIKit

class TripStartedView: UIView {
    @IBOutlet var etaBtn : UIButton!
    @IBOutlet var destinationLbl : UILabel!
    @IBOutlet var originLbl : UILabel!
    @IBOutlet var amountLbl : UILabel!
    @IBOutlet var cardNumberLbl : UILabel!
    @IBOutlet weak var bottomConstriant: NSLayoutConstraint!
    @IBAction func changeDestinationBtnPressed(_ sender: Any) {
    }
}
