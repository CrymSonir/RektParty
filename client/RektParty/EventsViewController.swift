//
//  EventsViewController.swift
//  RektParty
//
//  Created by stagiaire on 23/03/2017.
//  Copyright © 2017 The Grilled Birds. All rights reserved.
//

import UIKit
import Alamofire
import JWT
import SwiftyJSON

class EventsViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
    
    // Contient notre array d'éléments
    
    @IBOutlet weak var eventTableView: UITableView!
    var events:[Event] = []
    var window: UIWindow?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventTableView.delegate=self
        self.eventTableView.dataSource = self
        let db = UserDefaults.standard
        let parameters: Parameters = ["token": db.string(forKey: "token")!]
        Alamofire.request("http://192.168.100.100:4567/events",method: .get, parameters: parameters).responseJSON { response in
            if let JSONdata = response.result.value as? NSArray{
                let json = JSON(JSONdata)
                for (key, event):(String, JSON) in json {
                    let theEvent = Event(id: event["_id"]["$oid"].rawString()!, name:event["name"].rawString()!, dateStart:event["dateStart"].rawString()!, dateEnd:event["dateEnd"].rawString()!, privateP:event["private"].rawString()!, status: event["status"].rawString()!, location: event["location"].rawString()!, coordinates:event["coordinates"].rawString()!,organisatorId: event["organisator_id"]["$oid"].rawString()!)
                    self.events.append(theEvent)
                    
                    
                }
                
                self.eventTableView.reloadData()
            }
        }
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let event = self.events[indexPath.row]
        let cell = eventTableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = event.name
        cell?.isUserInteractionEnabled = true
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ttoto")
        let theEvent = self.events[indexPath.row]
        let eventData: Dictionary<String, String> = [
            
            "id": theEvent.id!,
            
            ]
        
        NotificationCenter.default.post(name: Notification.Name("GoToEvent"), object: nil, userInfo: eventData)
        // let tabBarController  = self.window!.rootViewController as! UITabBarController
        tabBarController?.selectedIndex = 0
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return tableEvents.count
     }*/
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
