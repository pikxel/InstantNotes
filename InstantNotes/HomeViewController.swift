//
//  ViewController.swift
//  InstantNotes
//
//  Created by Peter Lizak on 13/02/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import UIKit

class HomeViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedNoteIndex = -1;
    let segueIdentifierForNoteEditor = "showNoteEditor"
    var tableViewItemIsActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initalize the tableView and set the delegates
        self.initalizeTableView()
        
        // Call the API to fetch the data from the server
        APIManager.getNotes(handlerDone:{ data in
            
               // Copy the notes from the server to our singelton collection
               Notes.sharedInstance.collection = data;
            
               // Popoluate the tableView with fetched data
               self.reloadTableView()
        }, handlerFailed: {
            
            // Connecting to the server failed, probably the user does not has internet connection
            self.printAlert(alertTitle: "Something went wrong.", alertMessage: "We can't reach the server right now.")
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
         // When returning from Note Editor, tableView must reload to see the changes made in the editor
         self.reloadTableView()
    }
    

    
    private func initalizeTableView(){
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "notes")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Notes.sharedInstance.collection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "notes") as UITableViewCell!
        
        // Set text for the tableView item
        // Show "Draft" if the Note object title is empty
        if(!Notes.sharedInstance.collection[indexPath.row].title.isEmpty){
            cell.textLabel?.text = Notes.sharedInstance.collection[indexPath.row].title
        }else {
            cell.textLabel?.text = "[Draft]"
            cell.textLabel?.textColor = UIColor.red
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Store the active note index
        selectedNoteIndex = indexPath.row
        
        // When tableView item is clicked first time, we need change the navigation bar accrodingly
        if(!tableViewItemIsActive){
            tableViewItemIsActive = true
            
            // Note is active, show the delete button to enable deletion
            showTrashButton()
            
            // Note is active, show the edit button to enable edition
            showEditButton()
        }
    }
    
    private func showTrashButton(){
            self.trashButton.tintColor = UIColor.red
            self.trashButton.isEnabled = true
    }
    
    private func hideTrashButton(){
            self.trashButton.tintColor = UIColor.clear
            self.trashButton.isEnabled = false
    }
    
    private func showEditButton(){
            let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.addOrEditNotePressed(_:)))
            self.navigationItem.rightBarButtonItem = editButton
    }
    
    private func showNewButton(){
            let newButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.addOrEditNotePressed(_:)))
            self.navigationItem.rightBarButtonItem = newButton
    }
    
    @IBAction func addOrEditNotePressed(_ sender: Any) {
        
        //User pressed the new or edit button, switch screen and show him the editor
        performSegue(withIdentifier: "showNoteEditor", sender: self)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
        // User want's to delete a note, it can't be redone
        // Show him a confirmation to confirm it
        showDeleteConfirmation()
    }
    
    private func showDeleteConfirmation(){
        
        // Create the alert controller
        let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this note ?", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) {
            UIAlertAction in
            
             // User confimred deletion, delete the note
            self.deleteNote()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            
            // User canceled the deletion, do nothing
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
   
    private func deleteNote(){
        
        // From our Note array retrieve the Note the user wish to delete
        let selectedNote = Notes.sharedInstance.collection[selectedNoteIndex]
        
        // Call the API service to delete the note
        APIManager.deleteNote(note: selectedNote, handlerDone: {
        
            // We deleted the note successfully. Remove the deleted note from our array
            // To accomplish the same result we could call also the server,to refresh the list of notes
            Notes.sharedInstance.removeNote(note: selectedNote)
            
            // Reload tableView to display changes
            self.reloadTableView();
            
            // Table view reloaded there is no active tableView item, customize the navigation accordingly
            self.navigationBarWhenTableViewItemIsNotActive()
        },handlerFailed: {
            
            // The server is unavailable or there is no internet connection
            // We could not delete the note. Print the error
            self.printAlert(alertTitle: "Something went wrong.", alertMessage: "We can't remove your note right now.")
        })
    }
    
    private func printAlert(alertTitle:String, alertMessage:String){
        
        // Create the alert controller
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        
        //  Create the actions
        alertController.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.default, handler: nil))
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func reloadTableView(){
        
        // Reset the selected row as the
        selectedNoteIndex = -1
        
        // There is no active tableView item, store it in our indicator
        tableViewItemIsActive = false
        
        // The API success callback run's on seperate thread, by which this method is called. We must force to reload tableView on main thread
        DispatchQueue.main.async {
        
            // Table view reloaded there is no active tableview item, customize the navigation accordingly
            // UI changes should be done on main thread only
            self.navigationBarWhenTableViewItemIsNotActive()
            
            self.tableView.reloadData()
        }
    }
    
    private func navigationBarWhenTableViewItemIsNotActive(){
        
        // There is no active tableView item, hide the trash buttons
        self.hideTrashButton()
        
        // There is no active tableView item , show the new button
        self.showNewButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifierForNoteEditor {
            let destinationVC = segue.destination as! NoteEditorController
            
            // If row was selected the selectedNoteIndex is not -1, it's set, and we are editing
            // If so send the selected Note to edit
            if(selectedNoteIndex != -1 ){
                destinationVC.note = Notes.sharedInstance.collection[selectedNoteIndex]

            }
        }
    }
}
