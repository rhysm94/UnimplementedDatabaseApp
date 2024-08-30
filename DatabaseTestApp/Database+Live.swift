//
//  Database+Live.swift
//  DatabaseTestApp
//
//  Created by Rhys Morgan on 30/08/2024.
//

import GRDB
import UnimplementedGRDB
import Dependencies

extension Database: DependencyKey {
  static var liveValue: Database {
    let hasMigrated = LockIsolated(false)
    let database = LockIsolated<any DatabaseWriterProvider>(.unimplemented)

    return Self(
      migrate: {
        guard !hasMigrated.value else { return }
        defer { hasMigrated.setValue(true) }

        let dbQueue = try DatabaseQueue()

        var migrator = DatabaseMigrator()
        migrator.registerVersion1()
        try migrator.migrate(dbQueue)

        // Swap around the values
        database.setValue(dbQueue)
      },
      savePerson: { person in
        try await database.value.writer.write { db in
          try person.save(db)
        }
      },
      getPerson: { personID in
        try await database.value.reader.read { db in
          try Person.fetchOne(db, id: personID)
        }
      },
      fetchPeople: {
        try await database.value.reader.read { db in
          try Person.fetchAll(db)
        }
      }
    )
  }
}
