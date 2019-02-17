//
//  NoteEditorController.swift
//  InstantNotes
//
//  Created by Peter Lizak on 15/02/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import UIKit
import Foundation

class NoteEditorController:  UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // NoteEditor accepts an optional Note argument, which is passed before the segue (HomeViewController->prepare)
    // New note: Default definition of a Note object is used when no Note object was sent from HomeViewController
    // Edit note: Note was sent from HomeViewController, the sent Note overwrites the default
    var note = Note(id: -1 , title: "")
    var navigationTitle:String?

    override func viewDidLoad() {
        super.viewDidLoad()
  
        // Determine if the Note that was sent is new or editing, and set the title accordingly
        setNavigationTitle()
        
        // Fetch the textView text from the Note object
        textView.text = note.title
    }
    
    private func setNavigationTitle(){
        self.title = self.note.id == -1 ? "New Note" : "Edit Note"
    }
    
    @IBAction func editingDonePressed(_ sender: Any) {
        
        // Disable the Done button to prevent multiply calls of this function
        self.doneButton.isEnabled = false
        
        // User finishd the editing, get the input from textField and assign it our Note Object
        // For better performance implement the textViewDidChange to catch every change
        note.title = textView.text
        
        // Determine what API service to use by checking the Note ID
        // Remember when the Note ID is -1 it is a new note
        // When ID > 0 it is editing
        if(self.note.id == -1 ){
            self.createNewNote()
        }else {
            self.updateNote()
        }
    }
    
    private func createNewNote(){
        
        // Call the API to create a new note
        APIManager.createNote(note: self.note, handlerDone: {  newNoteId  in
            DispatchQueue.main.async {

                // Note created successfully, assign the ID returned by the server to our Note object
                self.note.id = newNoteId as Int
                
                // Push the Note object to our Note array
                Notes.sharedInstance.addNote(note: self.note)
                
                self.navigationController?.popViewController(animated: true)
            }
        }, handlerFailed: {
            
            // An error occured while communicating with the server
            // Print the error and return to HomeViewController
            DispatchQueue.main.async {
              self.printAlert()
            }

        })
    }
    
    private func updateNote(){
        
        // Call the API to update the Note
        APIManager.updateNote(note: self.note, handlerDone: {
            DispatchQueue.main.async {
                
                // Server update was successful, apply the changes to our internal array also
                Notes.sharedInstance.updateNote(note: self.note)
                
                self.navigationController?.popViewController(animated: true)
            }
        }, handlerFailed: {
            
            // An error occured while communicating with the server
            // Print the error and return to HomeViewController
            DispatchQueue.main.async {
                self.printAlert()
            }
        })
    }
    
    private func printAlert(){
        
        // Create the alert controller
        let alertController = UIAlertController(title: "Something went wrong.", message: "We can't reach the server right now. ", preferredStyle: UIAlertController.Style.alert)
        
        //  Create the actions
        alertController.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
        }))
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
}

