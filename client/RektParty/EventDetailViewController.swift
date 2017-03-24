//
//  EventDetailViewController.swift
//  RektParty
//
//  Created by stagiaire on 24/03/2017.
//  Copyright © 2017 The Grilled Birds. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {

    var event :Event? = nil
    
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventAddress: UITextField!
    @IBOutlet weak var eventStartDate: UITextField!
    @IBOutlet weak var eventEndDate: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if event != nil {
            self.eventName.text = event?.name
            self.eventAddress.text = event?.location
            self.eventStartDate.text = event?.dateStart
            self.eventEndDate.text = event?.dateStart
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnJoinEventTouchUp(_ sender: UIButton) {
        
    }
    
    @IBAction func btnCloseModalTouchUp(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
