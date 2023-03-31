//
//  FareDetailsViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 10/12/22.
//

import UIKit

class FareDetailsViewController: UIViewController {

    var fareAmount = "0.0"
    var taxesAmount = "0.0"
    var waitingChargesAmount = "0.0"
    var tipAmount = "0.0"
    var totalAmount = "0.0"
    
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var tipLbl: UILabel!
    @IBOutlet weak var waitingChargesLbl: UILabel!
    @IBOutlet weak var taxesLbl: UILabel!
    @IBOutlet weak var fareLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    func updateUI() {
        self.fareLbl.text = "$" + self.totalAmount
        self.taxesLbl.text = "$" + self.taxesAmount
        self.waitingChargesLbl.text = "$" + self.waitingChargesAmount
        self.tipLbl.text = "$" + self.tipAmount
        self.totalLbl.text = "$" + self.totalAmount
    }

    @IBAction func closeModelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
