//
//  ViewController.swift
//  HoneyDo
//
//  Created by Rigel Preston on 10/25/16.
//  Copyright © 2016 Rigel Preston. All rights reserved.
//

import UIKit

class honeyDoViewController: UITableViewController, ItemDetailViewControllerDelegate {
   // var items: [HoneydolistItem]  // <- declares that items of array will hold HoneydolistItems objects but doesn't give them value
    var checklist: HoneyDoCategories!
    
    //required init?(coder aDecoder: NSCoder) {
        
       // items = [HoneydolistItem]() // <- instantiates (to represent 'an abstraction' by a concrete instance) the array. Has no HoneydolistItem objects yet.
        //super.init(coder: aDecoder)
        //loadHoneydolistItems()
        //}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = checklist.name
        // Do any additional setup after loading the view, typically from a nib.
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        let itemToMove = checklist.items[fromIndexPath.row]
        checklist.items.remove(at: fromIndexPath.row)
        checklist.items.insert(itemToMove, at: fromIndexPath.row)
    }
    
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HoneydolistItem", for: indexPath)
        
        let item = checklist.items[indexPath.row]
        
        configureText(for: cell, with: item)
        configureCheckmark(for: cell, with: item)  // this method reads "Configure the checkmark 'for' this cell 'with' this item"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = checklist.items[indexPath.row]
            item.toggleChecked()
            
            configureCheckmark(for: cell, with: item)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        saveHoneydolistItems()
    }
    
    /*override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }*/
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        checklist.items.remove(at: indexPath.row) // this function has the button basically built into it. No need to add the button
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
        saveHoneydolistItems()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! ItemDetailViewController
            controller.delegate = self
        } else if segue.identifier == "EditItem" {
            
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! ItemDetailViewController
            controller.delegate = self
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemToEdit = checklist.items[indexPath.row]
            }
            
        }
    }
    
    func configureCheckmark(for cell: UITableViewCell, with item: HoneydolistItem) {
        let label = cell.viewWithTag(1776) as! UILabel
        
        if item.checked {
            label.text = "√"
        } else {
            label.text = ""
        }
    }
    
    func configureText(for cell: UITableViewCell, with item: HoneydolistItem) { // sets the honeydo list's item on the cell's label
        let label = cell.viewWithTag(1775) as! UILabel // Doing this makes it a tag and bypasses the need of an @IBOutlet. If you connected the label to an outlet, that outlet could only refer to the label from one of these cells, not all of them.
        label.text = item.text
    }
    
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: HoneydolistItem) {
        let newRowIndex = checklist.items.count
        checklist.items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        dismiss(animated: true, completion: nil)
        saveHoneydolistItems()
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: HoneydolistItem) {
        if let index = checklist.items.index(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
                
            }
        }
        
        dismiss(animated: true, completion: nil)
        saveHoneydolistItems()
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func saveHoneydolistItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(checklist.items, forKey: "HoneydolistItems")
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
    }
    
    func loadHoneydolistItems() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            checklist.items = unarchiver.decodeObject(forKey: "HoneydolistItems") as! [HoneydolistItem]
            
            unarchiver.finishDecoding()
        }
    }
    
    // MARK - IBActions
    @IBAction func editHoneyDo(_ sender: Any) {
        self.isEditing = !self.isEditing
    }
    
    
    
}

