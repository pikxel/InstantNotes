//
//  NotesClassTests.swift
//  InstantNotesTests
//
//  Created by Peter Lizak on 17/02/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import XCTest
@testable import InstantNotes


class NotesClassTests: XCTestCase {

    func testAddingNotes()
    {
        let note = Note(id: 1, title: "Test Note")
        Notes.sharedInstance.addNote(note:note)
        
        XCTAssertTrue(Notes.sharedInstance.collection.contains(where: {($0.id == 1)}), "Adding Note does not work")
    }
    
    func testUpdateNote()
    {
        var note = Note(id: 1, title: "Test Note")
        Notes.sharedInstance.addNote(note:note)
        
        note.title = "Test Note Edited"
        Notes.sharedInstance.updateNote(note: note)
        
        XCTAssertTrue(Notes.sharedInstance.collection.contains(where: {($0.title == note.title)}), "Updating Note does not work")
    }
    
    func testRemoveNote()
    {
        let note = Note(id: 1, title: "Test Note")
        Notes.sharedInstance.addNote(note:note)
        
        Notes.sharedInstance.removeNote(note: note)
        
        XCTAssertTrue(!Notes.sharedInstance.collection.contains(where: {($0.id == note.id)}), "Removing Note does not work")
    }
    
    func testGenerationOfIds(){
        let note = Note(id: 1, title: "Test Note")
        Notes.sharedInstance.addNote(note:note)
        
        XCTAssertTrue(Notes.sharedInstance.generateNextNoteId() != 1, "Generating unique ID does not work")
    }


}
