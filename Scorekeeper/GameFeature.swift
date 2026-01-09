import SQLiteData
import SwiftUI

let NO_PLAYERS_CHANGE_ME = true
let PLAYERS_CHANGE_ME: [Player] = []

struct GameView: View {

    @State var isGamePresented_CHANGE_ME = false
    @State var playerName_CHANGE_ME = ""

    init(game: Game) {
    }

    var body: some View {
        Form {
            if NO_PLAYERS_CHANGE_ME {
                ContentUnavailableView {
                    Label("No players", systemImage: "person.3.fill")
                } description: {
                    Button("Add player") {  // Action
                    }
                }
            } else {
                Section {
                    ForEach(PLAYERS_CHANGE_ME) { player in
                        HStack {
                            Button {
                                // Action
                            } label: {
                                if let image = UIImage(data: "CHANGE_ME".data(using: .utf8)!) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Rectangle()
                                }
                            }
                            .foregroundStyle(Color.gray)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .transaction { $0.animation = nil }

                            Text(player.name)
                            Spacer()
                            Button {
                                // Action
                            } label: {
                                Image(systemName: "minus")
                            }
                            Text("\(player.score)")
                            Button {
                                // Action
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                    .onDelete { _ in
                        // CHANGE_ME
                    }
                } header: {
                    HStack {
                        Text("Players")
                        Spacer()
                        Button {
                            // Action
                        } label: {
                            Image(systemName: "arrow.down")
                        }
                    }
                }
            }
        }
        .navigationTitle("CHANGE_ME")
        .toolbar {
            ToolbarItem {
                Button {
                    // Action
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem {
                Button {
                    // Action
                } label: {
                    Image(systemName: "plus")
                }
                .alert("New player", isPresented: $isGamePresented_CHANGE_ME) {
                    TextField("Player name", text: $playerName_CHANGE_ME)
                    Button("Save") {  // Action
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
    }
}

#Preview {
    let game = prepareDependencies {
        // swiftlint:disable:next force_try
        try! $0.bootstrapDatabase()
        // swiftlint:disable:next force_try
        return try! $0.defaultDatabase.read { db in
            try Game.fetchOne(db)!
        }
    }

    NavigationStack {
        GameView(game: game)
    }
}
