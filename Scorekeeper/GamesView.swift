import SQLiteData
import SwiftUI

struct GamesView: View {
    @FetchAll var games: [Game]

    var body: some View {
        List {
            ForEach(games) { game in
                Text(game.title)
                    .font(.headline)
            }
        }
        .navigationTitle("Games")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Label("Add Game", systemImage: "plus")
                }
            }
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }
    NavigationStack {
        GamesView()
    }
}
