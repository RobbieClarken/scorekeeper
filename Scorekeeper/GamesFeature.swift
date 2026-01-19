import SQLiteData
import SwiftUI

struct GamesView: View {
    @Selection struct Row {
        let game: Game
        let isShared: Bool
        let playerCount: Int
    }

    @FetchAll var rows: [Row]
    @State var isNewGamePresented = false
    @State var newGameTitle = ""
    @Dependency(\.defaultDatabase) var database

    var body: some View {
        List {
            ForEach(rows, id: \.game.id) { row in
                NavigationLink {
                    GameView(game: row.game)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(row.game.title).font(.headline)
                            if row.isShared {
                                Text("\(Image(systemName: "network")) Shared")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text("\(row.playerCount)")
                        Image(systemName: "person.2.fill").foregroundStyle(.gray)
                    }
                }
            }
            .onDelete { offsets in
                withErrorReporting {
                    try database.write { db in
                        try Game.find(offsets.map { rows[$0].game.id })
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
        .task {
            await withErrorReporting {
                try await $rows.load(
                    Game
                        .group(by: \.id)
                        .leftJoin(Player.all) { $0.id.eq($1.gameID) }
                        .order { $1.count().desc() }
                        .leftJoin(SyncMetadata.all) { $0.syncMetadataID.eq($2.id) }
                        .select {
                            GamesView.Row.Columns(
                                game: $0,
                                isShared: $2.isShared.ifnull(false),
                                playerCount: $1.count(),
                            )
                        },
                    animation: .default,
                )
                .task
            }
        }
    }
}

// swiftlint:disable force_try
// swiftlint:disable redundant_discardable_let
#Preview {
    @Previewable @Dependency(\.defaultDatabase) var database
    @Previewable @Dependency(\.defaultSyncEngine) var syncEngine
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
    }
    NavigationStack {
        GamesView()
    }
    .task {
        let game = try! await database.read { db in try Game.fetchOne(db)! }
        try! await syncEngine.sendChanges()
        _ = try! await syncEngine.share(record: game) { _ in }
    }
}
// swiftlint:enable force_try
// swiftlint:enable redundant_discardable_let
