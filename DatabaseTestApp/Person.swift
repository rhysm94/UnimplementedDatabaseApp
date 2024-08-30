//
//  Person.swift
//  DatabaseTestApp
//
//  Created by Rhys Morgan on 30/08/2024.
//

import Foundation
import GRDB

struct Person: Codable, Identifiable {
  var id: UInt64?
  var name: String
  var dateOfBirth: Date
  var favouriteColour: String
}

extension Person: FetchableRecord {}
extension Person: PersistableRecord {}
