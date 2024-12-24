//
//  Cue.swift
//  qhelper
//
//  Created by Arthur Efremenko on 12/22/24.
//

import Foundation

class Cue {
    var name: String?
    var unique_id: String?
    var type: CueType
    var pre_wait_time: Float?
    var number: String
    var children: [Cue] = []
    var is_lx_cue: Bool = true
    var file_path: String?
    
    init(name: String? = nil, pre_wait_time: Float? = nil, children: [Cue] = [],
         number: String = "", is_lx_cue: Bool = true, file_path: String? = nil,
         unique_id: String? = nil, type: CueType) {
        self.name = name
        self.type = type
        self.pre_wait_time = pre_wait_time
        self.number = number
        self.children = children
        self.is_lx_cue = is_lx_cue
        self.file_path = file_path
        self.unique_id = unique_id
    }
    
    /**
     Adds a child to this cue's children list.
     
     - Parameter child: Cue to be added as a child.
     */
    func add_child(_ child: Cue) {
        children.append(child)
    }
    
    /**
     Sets the `unique_id` of this cue to be the given unique ID.
     
     - Parameter unique_id: Unique ID to be set.
     */
    func set_unique_id(_ unique_id: String) {
        self.unique_id = unique_id
    }
    
    /**
     Updates the unique ID of this cue to be the unique ID returned in the QLab response
     with the index corresponding to the integer value of the current unique id of this cue.
     Also performs this reccursively on the children of this cue.
     
     - Parameter qlab_responses: List of QLab responses received by the server.
     */
    func update_unique_id(qlab_responses: [QLabResponse]) {
        if unique_id == nil { return }
        
        if let index = Int(self.unique_id!) {
            if index != 0 && index < qlab_responses.count {
                self.unique_id = qlab_responses[index].data
            }
        }
        
        for child in children {
            child.update_unique_id(qlab_responses: qlab_responses)
        }
    }
}
