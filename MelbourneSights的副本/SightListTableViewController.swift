//
//  SightListTableViewController.swift
//  FIT5140-Assign1
//
//  Created by 张昊宇 on 1/9/19.
//  Copyright © 2019 Haoyu Zhang. All rights reserved.
//

import UIKit
import CoreData
import MapKit


class SightListTableViewController: UITableViewController,UISearchResultsUpdating,DatabaseListener {
    
    var mapViewController: MapViewController?
    var locationList = [LocationAnnotation]()

    let SECTION_SIGHT = 0;
    let SECTION_COUNT = 1;
    let CELL_SIGHT = "sightCell"
    
   
    var allSights: [Sight] = []
    var filteredSights: [Sight] = []
    weak var sightDelegate: AddSightDelegate?
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        
        
        //filteredSights = allSights
        
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Sights"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented.
        definesPresentationContext = true
        
       
    }

    // MARK: - Table view data source
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Database Listener
    
    var listenerType = ListenerType.sights
    
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        allSights = sights
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            filteredSights = allSights.filter({(sight: Sight) -> Bool in
                return sight.name!.contains(searchText)
            })
        }
        else {
            filteredSights = allSights;
        }
        
        tableView.reloadData();
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == SECTION_SIGHT {
            return filteredSights.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
            let sightCell = tableView.dequeueReusableCell(withIdentifier: CELL_SIGHT, for: indexPath) as!
            SightTableViewCell
            let sight = filteredSights[indexPath.row]
            
            sightCell.nameLabel.text = sight.name
            sightCell.descriptionLabel.text = sight.desc
            let icon = sight.icon
            let image = sight.photo
            if (UIImage(named:"picture/"+image! ) != nil)
            {
             sightCell.imageLabel.image = UIImage(named: "picture/"+image!)
            }
            else
            {
              sightCell.imageLabel.image = loadImageData(fileName: image!)
            }
        
            //sightCell.iconImageLabel = UIImageView(frame: CGRect(x: 50.0, y: 50.0, width: 50.0, height: 50.0))
            sightCell.iconImageLabel.image = UIImage(named: "icon/"+icon!)

            return sightCell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sight = self.allSights[indexPath.row]
        let annotation = LocationAnnotation(title: sight.name!, subtitle: sight.desc!, lat: sight.latitude, long: sight.longitude, icon: sight.icon!, image: sight.photo!)
        
        //Call focusOn() method in mapviewcontroller to focus on selected annotation
        mapViewController?.focusOn(annotation: annotation)
        navigationController?.popViewController(animated: true)
        
    }
    
    func addSight(newSight: Sight) -> Bool {
        allSights.append(newSight)
        filteredSights.append(newSight)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: filteredSights.count - 1, section: 0)], with: .automatic)
        tableView.endUpdates()
        tableView.reloadSections([SECTION_COUNT], with: .automatic)
        return true
    }
    
    
    
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle:
            UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler:
            nil))
        self.present(alertController, animated: true, completion: nil)
    }

     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createSightSegue" {
            let destination = segue.destination as! CreateSightViewController
            destination.mapViewController = self.mapViewController
        }
    }

    
     //Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_SIGHT {
            databaseController?.deleteSight(sight: filteredSights[indexPath.row])
            mapViewController?.allSights.remove(at:indexPath.row)
        }
    }
    

    
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        
        return image
    }
    
    @IBAction func sortAtoZ(_ sender: Any) {
        filteredSights.sort(by: { $0.name!.compare($1.name!) == ComparisonResult.orderedAscending})
        tableView.reloadData()
    }
    @IBAction func sortZtoA(_ sender: Any) {
        filteredSights.sort(by: { $0.name!.compare($1.name!) == ComparisonResult.orderedDescending})
        tableView.reloadData()
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
