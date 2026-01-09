import SQLiteData
import SwiftUI

struct GamesView: View {
    @FetchAll(animation: .default) var games: [Game]
    @State var isNewGamePresented = false
    @State var newGameTitle = ""
    @Dependency(\.defaultDatabase) var database

    var body: some View {
        List {
            ForEach(games) { game in
                Text(game.title)
                    .font(.headline)
            }
            .onDelete { offsets in
                withErrorReporting {
                    try database.write { db in
                        try Game.find(offsets.map { games[$0].id })
                            .delete()
                            .execute(db)
                    }
                }

            }
        }
        .navigationTitle("Games")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isNewGamePresented = true
                } label: {
                    Label("Add Game", systemImage: "plus")
                }
            }
        }
        .alert("Create new game", isPresented: $isNewGamePresented) {
            TextField("Game title", text: $newGameTitle)
            Button("Save") {
                withErrorReporting {
                    try database.write { db in
                        try Game
                            .insert {
                                Game.Draft(title: newGameTitle)
                            }
                            .execute(db)
                    }
                    newGameTitle = ""
                }
            }
            Button(role: .cancel) {}
        }
    }
}

#Preview {
    // swiftlint:disable:next redundant_discardable_let
    let _ = prepareDependencies {
        // swiftlint:disable:next force_try
        try! $0.bootstrapDatabase()
    }
    NavigationStack {
        GamesView()
    }
}
