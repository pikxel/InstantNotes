//
//  API.swift
//  InstantNotes
//
//  Created by Peter Lizak on 13/02/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import Foundation
import UIKit

let baseUrlString = "http://private-9aad-note10.apiary-mock.com/notes"

class APIManager {

    static func getNotes(handlerDone:@escaping (_ data:[Note])  -> Void,handlerFailed:@escaping () -> Void) ->Void  {
        
        // Construct the URL object, add subpath if needed
        let url = constructURL()
        
        // Construct the URLRequest object, define the method and add the body if needed
        let request = constructRequest(url: url, method: "GET") as URLRequest
        
        // Perform the request and take the server response
        performRequest(request: request, handlerDone: { data in
            
            // Server responded ok, parse the response
            parseNotes(dataFromServer: data, handlerDone: {parsedData in
                
                // Send the parsed object array for the ViewController, return done
                handlerDone(parsedData)
            })
        }) {
            
            // Could not reach the server, return fail
            handlerFailed()
        }
    }
    
    static func getNote(note:Note, handlerDone: @escaping (_ data:Note)  -> Void,handlerFailed:@escaping () -> Void) ->Void {
        
        // Construct the URL object, add subpath if needed
        let url = constructURL(subPath: String(note.id))
        
        // Construct the URLRequest object, define the method and add the body if needed
        let request = constructRequest(url: url, method: "GET") as URLRequest
        
        // Perform the request and take the server response
        performRequest(request: request, handlerDone: { data in
            
            // Server responded ok, parse the response
            parseNote(dataFromServer: data, handlerDone: {parsedData in
                
                // Send the parsed object for the ViewController, return done
                handlerDone(parsedData)
            })
        }) {
            
            // Could not reach the server, return fail
            handlerFailed()
        }
    }
    
    
    
    static func createNote(note:Note, handlerDone:@escaping (_ newNoteID:Int)  -> Void,handlerFailed:@escaping () -> Void) ->Void  {
        
        // Construct the URL object, add subpath if needed
        let url = constructURL()
        
        // Construct the URLRequest object, define the method and add the body if needed
        let request = constructRequest(url: url, method: "POST", title:note.title) as URLRequest
        
        // Perform the request and take the server response
        performRequest(request: request, handlerDone: { data in
            
            // When creating a new note the server should return it's ID for further reference
            // In our cases it is does't, so just generate one to distinguish the Note localy
            // Attention: This is only a "sample solution", with real server this would not work
            let newNoteId = Notes.sharedInstance.generateNextNoteId()
            handlerDone(newNoteId)
        }) {
            
            
            // Could not reach the server, return fail
            handlerFailed()
        }
    }
    
    static func updateNote(note:Note, handlerDone:@escaping ()  -> Void,handlerFailed:@escaping () -> Void) ->Void  {
        
        // Construct the URL object, add subpath if needed
        let url = constructURL(subPath: String(note.id))
        
        // Construct the URLRequest object, define the method and add the body if needed
        let request = constructRequest(url: url, method: "PUT", title:note.title) as URLRequest
        
        // Perform the request and take the server response
        performRequest(request: request, handlerDone: { data in

            // Note update successfully. Return done
            handlerDone()
        }) {
            
            // Could not reach the server, return fail
            handlerFailed()
        }
    }
    
    static func deleteNote(note:Note,handlerDone:@escaping ()  -> Void,handlerFailed:@escaping () -> Void) ->Void {
        
        // Construct the URL object, add subpath if needed
        let url = constructURL(subPath: String(note.id))
        
        // Construct the URLRequest object, define the method and add the body if needed
        let request = constructRequest(url: url, method: "DELETE") as URLRequest
        
        // Perform the request and take the server response
        performRequest(request: request, handlerDone: { data in
            
            // Note deleted successfully. Return done
            handlerDone()
        }) {

            // Could not reach the server, return fail
            handlerFailed()
        }
    }
    
    static func performRequest(request:URLRequest,handlerDone: @escaping (_ data:Data)  -> Void,handlerFailed: @escaping ()  -> Void){
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            guard let data = data else {handlerFailed(); return}
            handlerDone(data)
        }
        task.resume()
    }
    
    static func parseNote(dataFromServer:Data,handlerDone: @escaping (_ json:Note) ->Void) ->Void {
        do {
            let note = try JSONDecoder().decode(Note.self, from: dataFromServer)
            handlerDone(note)
        } catch {
            
            // A handler could be defined here for handeling bad response from server
            print("API:An error occurred while parsing server response parseNote")
        }
    }
    
    static func parseNotes(dataFromServer:Data,handlerDone: @escaping (_ json:[Note]) ->Void) ->Void {
        do {
            let notes = try JSONDecoder().decode([Note].self, from: dataFromServer)
            handlerDone(notes)
        } catch {
            
            // A handler could be defined here for handeling bad response from server
            print("API:An error occurred while parsing server response parseNotes")
        }
    }

    static func constructRequest(url:URL, method:String, title:String?=nil) ->URLRequest{
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Add the httpBody if present
        if(title != nil){
            request.httpBody = String("title="+title!).data(using: .utf8)
        }
        
        return request
    }

    static func constructURL(subPath:String? = nil)->URL{
        let url = subPath != nil ? baseUrlString + "/" + subPath! : baseUrlString
        return URL(string: url)!
    }
}

