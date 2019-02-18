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
    
    enum Mode
    {
        case EDITING
        case PREVIEW
    }
    
    // NoteEditor accepts an optional Note argument, which is passed before the segue (HomeViewController->prepare)
    // New note: Default definition of a Note object is used when no Note object was sent from HomeViewController
    // Edit note: Note was sent from HomeViewController, the sent Note overwrites the default
    var note = Note(id: -1 , title: "")
    var navigationTitle:String?
    
    // Set mode editing as default, because passing Note object from HomeViewController is optional
    var editorMode:Mode = Mode.EDITING
   
    override func viewDidLoad() {
        super.viewDidLoad()
  
        // When Note is passed from HomeViewController, it's Preview Mode
        // When creating a new Note, it's Editing mode
        setEditorMode()
        
        // Fetch the textView text from the Note object
        textView.text = note.title
    }
    
    private func setEditorMode(){
        
        //  If The Note ID is -1 the Note was not passed from HomeViewController, we use our default definition, and are creating a new Note, editor should show up
        // Else we have received a Note object from HomeViewController, so it's a preview mode
        if(self.note.id == -1){
            setEditingMode()
        } else {
           setPreviewMode()
        }
    }
    
    private func setPreviewMode(){
        
        // Store the preview mode
        self.editorMode = Mode.PREVIEW
        
        // Show the navigation in preview mode
        self.navigationPreviewMode()
        
        // Disable user interaction
        self.textView.isUserInteractionEnabled = false
    }
    
    
    private func navigationPreviewMode(){
        
        // Title show Preview mode
        self.title = "Preview"
        
        // Enable edit button
        showEditButton()
    }
    
    
    private func setEditingMode(){
        
        // Store the editing
        self.editorMode = Mode.EDITING
        
        // Apply Editing mode on Navigation
        self.navigationEditingMode()
        
        // Apply Editing mode on TextView
        self.textViewEditingMode()
    }
    
    private func navigationEditingMode(){
        
        // Title show Editor mode
        self.title = "Editor"
        
        // Enable save button
        showSaveButton()
    }
    
    private func textViewEditingMode(){
    
        // Focus on textView and open keyboard
        self.textView.becomeFirstResponder()
        
        // Enable user interaction to make changes
        self.textView.isUserInteractionEnabled = true
        
        // Give focus to the text field and make the keyboard appear.
        let newPosition = textView.endOfDocument
        textView.selectedTextRange = self.textView.textRange(from:newPosition, to: newPosition)
    }
    
    @IBAction func editingDonePressed(_ sender: Any) {
        
        if(self.editorMode == Mode.EDITING){
            
            // Disable the Done button to prevent multiply calls of this function
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
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
        } else {
            setEditingMode()
        }
    
    }
    
    
    private func showEditButton(){
        
        // We call this on main thread
        let newButton = UIBarButtonItem(barButtonSystemItem: .edit , target: self, action: #selector(self.editingDonePressed(_:)))
        self.navigationItem.rightBarButtonItem = newButton
        
    }
    
    private func showSaveButton(){
        
        // We call this on main thread
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.editingDonePressed(_:)))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    private func createNewNote(){
        
        // Test internet connection
        if(!ReachabilityManager.isConnectedToNetwork()){
            
            // There is no internet, print the error
            self.printAlert(alertTitle: "There is no internet", alertMessage: "Turn on your wifi or data")
            return
        }
        
        // Call the API to create a new note
        APIManager.createNote(note: self.note, handlerDone: {  newNoteId  in
            DispatchQueue.main.async {

                // Note created successfully, assign the ID returned by the server to our Note object
                self.note.id = newNoteId as Int
                
                // Push the Note object to our Note array
                Notes.sharedInstance.addNote(note: self.note)
                
                self.setPreviewMode()
            }
        }, handlerFailed: {
            
            DispatchQueue.main.async {
            
              // An error occured while communicating with the server
              self.printAlert(alertTitle:"Something went wrong.",alertMessage: "We can't reach the server right now.")
            }
        })
    }
    
    private func updateNote(){
        
        // Test internet connection
        if(!ReachabilityManager.isConnectedToNetwork()){
            
            // There is no internet, print the error
            self.printAlert(alertTitle: "There is no internet", alertMessage: "Turn on your wifi or data")
            return
        }
        
        // Call the API to update the Note
        APIManager.updateNote(note: self.note, handlerDone: {
            DispatchQueue.main.async {
                
                // Server update was successful, apply the changes to our internal array also
                Notes.sharedInstance.updateNote(note: self.note)
                
                // Open Editing Mode again. This actually does not really makes sense, we should store
                // the Note internaly while there is no internet connection
                self.setPreviewMode()
            }
        }, handlerFailed: {
            
            DispatchQueue.main.async {
                
            // An error occured while communicating with the server
            self.printAlert(alertTitle:"Something went wrong.",alertMessage: "We can't reach the server right now. ")
            }
            
        })
    }
    
    private func printAlert(alertTitle:String, alertMessage:String){
        
        // Create the alert controller
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        
        //  Create the actions
        
        alertController.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.default, handler: { _ in
           
            // Open Editing Mode again. This actually does not really makes sense, we should store
            // the Note internaly while there is no internet connection
            self.setEditingMode()
        }))
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
}

