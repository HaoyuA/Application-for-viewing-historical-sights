//
//  CoreDataController.swift
//  FIT5140-Assign1
//
//  Created by 张昊宇 on 1/9/19.
//  Copyright © 2019 Haoyu Zhang. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject,DatabaseProtocol,NSFetchedResultsControllerDelegate {
    
    

    let DEFAULT_SIGHT_NAME = "Default Sight"
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    var allSightsFetchedResultsController: NSFetchedResultsController<Sight>?
    
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "Sights")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        super.init()
        
        // If there are no heroes in the database assume that the app is running
        // for the first time. Create the default team and initial superheroes.
        if fetchAllSights().count == 0 {
            createDefaultEntries()
        }
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    func addSight(name: String, desc: String,latitude: Double,longitude: Double,icon: String,photo:String) -> Sight {
        let sight = NSEntityDescription.insertNewObject(forEntityName: "Sight", into:
            persistantContainer.viewContext) as! Sight
        sight.name = name
        sight.desc = desc
        sight.latitude = latitude
        sight.longitude = longitude
        sight.icon = icon
        sight.photo = photo
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return sight
    }
    
//    func ifEntityExist(name: String) -> Bool{
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sight")
//        fetchRequest.predicate = NSPredicate(format: "someField = %d", name)
//
//        var results: [NSManagedObject] = []
//
//        do {
//            results = try persistantContainer.viewContext.fetch(fetchRequest)
//        }
//        catch {
//            print("error executing fetch request: \(error)")
//        }
//
//        return results.count > 0
//    }
    
    
    
    func deleteSight(sight: Sight) {
        persistantContainer.viewContext.delete(sight)
        // This less efficient than batching changes and saving once at end.
        saveContext()
    }
    
    
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        
        
        if listener.listenerType == ListenerType.sights  {
            listener.onSightListChange(change: .update, sights: fetchAllSights())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllSights() -> [Sight] {
        if allSightsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Sight> = Sight.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allSightsFetchedResultsController = NSFetchedResultsController<Sight>(fetchRequest:
                fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil,
                              cacheName: nil)
            allSightsFetchedResultsController?.delegate = self
            do {
                try allSightsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var sights = [Sight]()
        if allSightsFetchedResultsController?.fetchedObjects != nil {
            sights = (allSightsFetchedResultsController?.fetchedObjects)!
        }
        
        return sights
    }
    
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allSightsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.sights{
                listener.onSightListChange(change: .update, sights: fetchAllSights())
                }
            }
        }
        
    }
     //MARK: - Default entries
    lazy var defaultSight: Sight = {
        var Sights = [Sight]()

        let request: NSFetchRequest<Sight> = Sight.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", DEFAULT_SIGHT_NAME)
        request.predicate = predicate
        do {
            try Sights = persistantContainer.viewContext.fetch(Sight.fetchRequest()) as! [Sight]
        } catch {
            print("Fetch Request failed: \(error)")
        }

        if Sights.count == 0 {
            return addSight(name: DEFAULT_SIGHT_NAME, desc: "", latitude: 0, longitude: 0, icon: "", photo: "")
        }
        else {
            return Sights.first!
        }
    }()
    
    func createDefaultEntries() {
        let _ = addSight(name: "Melbourne Museum", desc: "A visit to Melbourne Museum is a rich, surprising insight into life in Victoria. It shows you Victoria's intriguing permanent collections and bring you brilliant temporary exhibitions from near and far. You'll see Victoria's natural environment, cultures and history through different perspectives.", latitude: -37.8031931, longitude: 144.9717675, icon: "icon5", photo: "pic2")
        let _ = addSight(name: "Flinders Street Station", desc: "Stand beneath the clocks of Melbourne's iconic railway station, as tourists and Melburnians have done for generations. Take a train for outer-Melbourne explorations, join a tour to learn more about the history of the grand building, or go underneath the station to see the changing exhibitions that line Campbell Arcade.", latitude: -37.8174, longitude: 144.9673, icon: "icon7", photo: "pic1")
        let _ = addSight(name: "Brighton Bathing Boxes", desc: "Built well over a century ago in response to very Victorian ideas of morality and seaside bathing, the bathing boxes remain almost unchanged. All retain classic Victorian architectural features with timber framing, weatherboards and corrugated iron roofs, though they also bear the hallmarks of individual licencees' artistic and colourful embellishments.", latitude: -37.92102, longitude: 144.98733, icon: "icon4", photo: "pic3")
        let _ = addSight(name: "Como House and Garden", desc: "Built in 1847, Como House and Garden is one of Melbourne most glamorous stately homes. A unique blend of Australian Regency and classic Italianate architecture, Como House offers a rare glimpse into the opulent lifestyles of former owners, the Armytage family, who lived there for over a century.", latitude: -37.8379104, longitude: 145.0037089, icon: "icon4", photo: "pic4")
        let _ = addSight(name: "Polly Woodside", desc: "Experience the turbulent trials of history at sea and steer your way through blustering tales from the ship’s 17 world voyages, above and below deck. Polly Woodside offers a range of activities for visitors including an award-winning interactive gallery on its history, children’s Crew Calls and Pirate Days.", latitude: -37.824345, longitude: 144.9535632, icon: "icon4", photo: "pic5")
        let _ = addSight(name: "Koorie Heritage Trust", desc: "The Koorie Heritage Trust offers an inclusive and engaging environment for all visitors. As an Aboriginal owned and managed organisation, they take great pride in their ability to develop and deliver an authentic and immersive urban Aboriginal arts and cultural experience in a culturally safe environment that cannot be duplicated by any other arts and cultural organisation in Melbourne.", latitude: -37.8175485, longitude: 144.96740522, icon: "icon4", photo: "pic6")
        let _ = addSight(name: "Werribee Park and Mansion", desc: "Enjoy a perfect day out at Werribee Park. Experience the grandeur of Werribee Mansion, discover Victoria's unique pastoral history down at the farm and homestead, relax with family and friends on the Great lawn surrounded by stunning formal gardens, and so much more.", latitude: -37.9283837, longitude: 144.678672, icon: "icon5", photo: "pic7")
        let _ = addSight(name: "Victoria Police Museum", desc: "From the largest collection of Kelly Gang armour in Australia to forensic evidence from some of Melbourne's most notorious crimes, the Victoria Police Museum presents visitors with an intriguing insight into the social history of policing and crime.", latitude: -37.821847, longitude: 144.9529443, icon: "icon5", photo: "pic8")
        let _ = addSight(name: "Chinese Museum", desc: "Marvel at the world’s biggest processional Dai Loong Dragon, experience Finding Gold and discover the new One Million Stories Exhibition, showcasing the contribution Chinese Australians have made to Australian Society over 200 years.", latitude: -37.8107583, longitude: 144.9691694, icon: "icon5", photo: "pic9")
        let _ = addSight(name: "Australian National Aviation Museum", desc: "The Australian National Aviation Museum is located at Moorabbin Airport. With one of the most important collections of aircraft and engines in Australia this is a fantastic place for those interested in aviation history and technology, and a great place for kids and adults alike to wander around and even look inside a number of aircraft", latitude: -37.9760854, longitude: 145.0905326, icon: "icon5", photo: "pic10")
        let _ = addSight(name: "Melbourne Steam Engine Club", desc: "The Melbourne Steam Traction Engine Club operates a vintage engine museum set in six hectares of parkland in the south eastern suburb of Scoresby. In all, there are several hundred engines and related exhibits housed in a number of exhibition sheds around the grounds.", latitude: -37.9044388214431, longitude:145.214053244983, icon: "icon5", photo: "pic11")
        let _ = addSight(name: "Royal Botanic Gardens", desc: "Attracting over 1,900,000 visitors annually, Melbourne Gardens is a treasured part of cultural life and a valuable asset to the heritage rich city. With its stunning vistas, tranquil lakes and diverse plant collections, the Gardens are a place of continual discovery and delight.", latitude:-37.8303689, longitude:144.9796056, icon: "icon6", photo: "pic12")
        let _ = addSight(name: "Fitzroy Gardens", desc: "Visit a world of green in the heart of the city at Melbourne's Fitzroy Gardens, and while away hours marvelling at the tiny doorways of the historic Captain Cook's Cottage, the carved Fairies Tree, the model Tudor Village, the conservatory, myriad fountains and statues, and shady avenues of grand trees.", latitude:-37.81402, longitude:144.98018, icon: "icon6", photo: "pic13")
        let _ = addSight(name: "Rippon Lea Estate", desc: "Make yourself at home exploring over 20 rooms in the original estate, its sweeping heritage grounds, a picturesque lake and waterfall, an original 19th century fruit orchard and the largest fernery in the Southern Hemisphere.", latitude:-37.87793882, longitude:144.9979202, icon: "icon6", photo: "pic14")
         let _ = addSight(name: " Southern Cross Station", desc: "Southern Cross Station is serviced by Melbourne's metropolitan trains and is the terminus for regional V/Line trains and interstate services. Several metropolitan, regional and interstate bus services operate from the station, including the Skybus service to and from Melbourne (Tullamarine) Airport.", latitude:-37.8183, longitude:144.95335, icon: "icon1", photo: "pic15")
       
    }
}
