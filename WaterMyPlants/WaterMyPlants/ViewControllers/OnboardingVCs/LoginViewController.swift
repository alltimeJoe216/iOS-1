//
//  LoginViewController.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
        }
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    

}
