//
//  ContentView.swift
//  DatabaseTestApp
//
//  Created by Rhys Morgan on 29/08/2024.
//

import Dependencies
import SwiftUI

struct ContentView: View {
  @Dependency(\.database) var database

  @State private var isLoading = false
  @State private var people: [Person] = []
  @State private var error: (any Error)?

  var body: some View {
    List {
      Group {
        if isLoading {
          ProgressView()
        }

        ForEach(people) { person in
          VStack(alignment: .leading) {
            Text(person.name)

            Text("Born \(person.dateOfBirth.formatted(dobFormat))")
              .font(.caption)
          }
        }
      }
    }
    .task {
      isLoading = true
      error = nil

      do {
        try await database.migrate()
      } catch {
        self.error = error
      }

      await fetchPeople()
    }
    .refreshable {
      await fetchPeople()
    }
    .alert(
      "An error occurred!",
      isPresented: Binding(get: { error != nil }, set: { _ in error = nil }),
      presenting: error,
      actions: { _ in
        Button("OK") {}
      },
      message: { error in
        Text(error.localizedDescription)
      }
    )

    .navigationTitle("People")
  }

  private func fetchPeople() async {
    isLoading = true
    defer { isLoading = false }
    error = nil
    do {
      people = try await database.fetchPeople()
    } catch {
      self.error = error
    }
  }
}

let dobFormat = Date.FormatStyle().day().month().year()

#Preview {
  withDependencies {
    $0.database.fetchPeople = {
      try await Task.sleep(for: .seconds(1))
      return [
        Person(
          name: "Rhys",
          dateOfBirth: try! dobFormat.parse("22-10-94"),
          favouriteColour: "Blue"
        )
      ]
    }
  } operation: {
    ContentView()
  }
}
