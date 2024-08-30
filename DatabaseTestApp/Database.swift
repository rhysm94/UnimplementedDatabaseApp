//
//  Database.swift
//  DatabaseTestApp
//
//  Created by Rhys Morgan on 30/08/2024.
//

import Dependencies
import DependenciesMacros

@DependencyClient
struct Database {
  var migrate: @Sendable () async throws -> Void
  var savePerson: @Sendable (Person) async throws -> Void
  var getPerson: @Sendable (Person.ID) async throws -> Person?
  var fetchPeople: @Sendable () async throws -> [Person]
}

extension Database: TestDependencyKey {
  static var testValue: Database { Self() }
}

extension DependencyValues {
  var database: Database {
    get { self[Database.self] }
    set { self[Database.self] = newValue }
  }
}
