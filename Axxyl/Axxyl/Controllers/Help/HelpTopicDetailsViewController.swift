//
//  HelpTopicDetailsViewController.swift
//  Axxyl
//
//  Created by Axxyl Inc. on 25/02/23.
//

import UIKit

class HelpTopicDetailsViewController: UIViewController {

    @IBOutlet weak var headerTitleLbl: UILabel!
    var topic : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerTitleLbl.text = self.topic
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
