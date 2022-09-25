//
//  Task.swift
//  RealmApplic
//
//  Created by Владислав on 21.09.22.
//

import Foundation
import RealmSwift

class Task: Object {
    @Persisted var name = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}
