//
//  Notes.swift
//  InstantNotes
//
//  Created by Peter Lizak on 17/02/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import Foundation


// Attention: Keeping the notes inside the HomeViewController and updateing it would be more appropriate
// Signelton is used here because we don't have a real BE, so we can keep our Notes up-to-date
// Create a singelton class to hold all the notes
class Notes {
    
    static let sharedInstance = Notes()
    var collection = [Note]()
    
    func addNote(note:Note)->Void{
        collection.append(note)
    }
    
    func updateNote(note:Note)->Void{
        if let row = Notes.sharedInstance.collection.index(where: {$0.id == note.id}) {
            Notes.sharedInstance.collection[row].title = note.title
        }
    }
    
    func removeNote(note:Note)->Void{
        Notes.sharedInstance.collection = Notes.sharedInstance.collection.filter { $0.id != note.id }
    }
    
    // Attention: This is only a "sample solution", with real server this would not work for serveral reasons
    // When creating a new note the server should return it's ID for further reference
    // Our server does not, so we just generate one to distinguish the Note localy
    func generateNextNoteId() -> Int{
        return ((Notes.sharedInstance.collection.last?.id)!) + 1
    }
}
