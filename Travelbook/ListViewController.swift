//
//  ListViewController.swift
//  Travelbook
//
//  Created by Jim Allan on 26/06/2020.
//  Copyright © 2020 Jim Allan. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    var titleArray = [String]()
    var idArray = [UUID]()
    var selectedTitle = ""
    var selectedTitleID : UUID?
    var chosenTitle = ""
    var chosenTitleID : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(removeButtonClicked))  //added 3/7
        tableView.delegate = self
        tableView.dataSource = self
   
        getData()
    
    }
    
    override func viewWillAppear(_ animated: Bool) { // observe the newPlace post from VC and trigger get data function
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
        
    }
    
    
    
   @objc func getData () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                    self.titleArray.append(title)
                    }
                
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    tableView.reloadData()
            }
            
        }
            
        } catch {
            print("Error")
        }
        
        
    }
    
    
    @objc func addButtonClicked () {
        chosenTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        print(indexPath.row)
        return cell
    }
    // Get information from index path
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        chosenTitle = titleArray[indexPath.row]
        chosenTitleID = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = chosenTitle
            destinationVC.selectedTitleID = chosenTitleID
            
        }
    }
    
    // added 3/7
    @objc func removeButtonClicked () {
       // Function not used
        
    }
        
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            
            let idString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            do {
            let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                titleArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                    
                                } catch {
                                    print("There was an error")
                                }
                                
                                break
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    
                }
            } catch {
                print("error")
            }
            
           // landmarkNames.remove(at: indexPath.row)
            //titleArray.remove(at: indexPath.row)
            //idArray.remove(at: indexPath.row)
            //landmarkImages.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        
        }
    }
   
}
