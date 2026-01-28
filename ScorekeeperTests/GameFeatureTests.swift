import CustomDump
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

@testable import Scorekeeper

extension BaseSuite {
    @Suite(
        .dependencies {
            try $0.defaultDatabase.write { db in
                try db.seed {
                    Game.Draft(id: UUID(-1), title: "G1")
                    Game.Draft(id: UUID(-2), title: "G2")
                    Game.Draft(id: UUID(-3), title: "G3")

                    Player.Draft(id: UUID(-1), gameID: UUID(-1), name: "P1", score: 1)
                    Player.Draft(id: UUID(-2), gameID: UUID(-1), name: "P2", score: 3)
                    Player.Draft(id: UUID(-3), gameID: UUID(-1), name: "P3", score: 2)
                }
            }
        }
    )

    struct GameFeatureTests {
        @Dependency(\.defaultDatabase) var database

        func basics() async throws {
            let game = try await #require(
                database.read { db in try Game.find(UUID(-1)).fetchOne(db) }
            )
            let model = GameModel(game: game)
            await model.task()
            expectNoDifference(
                model.rows,
                [
                    GameModel.Row(
                        player: Player(id: UUID(-2), gameID: UUID(-1), name: "P2", score: 3)),
                    GameModel.Row(
                        player: Player(id: UUID(-3), gameID: UUID(-1), name: "P3", score: 2)),
                    GameModel.Row(
                        player: Player(id: UUID(-1), gameID: UUID(-1), name: "P1", score: 1)),
                ]
            )
        }

        @Test() func addPlayer() async throws {
            let game = try await #require(
                database.read { db in try Game.find(UUID(-1)).fetchOne(db) }
            )
            let model = GameModel(game: game)
            await model.task()

            model.addPlayerButtonTapped()
            model.newPlayerName = "P4"
            model.saveNewPlayerButtonTapped()

            try await model.$rows.load()

            expectNoDifference(
                model.rows,
                [
                    GameModel.Row(
                        player: Player(id: UUID(-2), gameID: UUID(-1), name: "P2", score: 3)),
                    GameModel.Row(
                        player: Player(id: UUID(-3), gameID: UUID(-1), name: "P3", score: 2)),
                    GameModel.Row(
                        player: Player(id: UUID(-1), gameID: UUID(-1), name: "P1", score: 1)),
                    GameModel.Row(
                        player: Player(id: UUID(0), gameID: UUID(-1), name: "P4", score: 0)),
                ]
            )
        }

    }
}
