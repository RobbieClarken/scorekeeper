import Dependencies
import Foundation
import SQLiteData

@Table struct Game: Identifiable {
    let id: UUID
    var title = ""
}

@Table struct Player: Identifiable {
    let id: UUID
    let gameID: Game.ID
    var name = ""
    var score = 0
}

func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    let database = try SQLiteData.defaultDatabase()
    var migrator = DatabaseMigrator()
    #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration("Create 'games' and 'players' tables") { db in
        // swiftlint:disable indentation_width
        try #sql(
            """
            CREATE TABLE "games" (
              "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
              "title" TEXT NOT NULL DEFAULT ''
            ) STRICT
            """
        )
        .execute(db)
        try #sql(
            """
            CREATE TABLE "players" (
              "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
              "gameID" TEXT NOT NULL REFERENCES "games"("id") ON DELETE CASCADE,
              "name" TEXT NOT NULL DEFAULT '',
              "score" INTEGER NOT NULL DEFAULT 0
            ) STRICT
            """
        )
        .execute(db)
        try #sql(
            """
            CREATE INDEX "index_players_on_gameID" ON "players"("gameID")
            """
        )
        .execute(db)
        // swiftlint:enable indentation_width
    }
    try migrator.migrate(database)
    if context == .preview {
        try database.seed()
    }
    return database
}

extension DependencyValues {
    mutating func bootstrapDatabase() throws {
        defaultDatabase = try appDatabase()
    }
}

extension DatabaseWriter {
    func seed() throws {
        try write { db in
            try db.seed {
                Game.Draft(title: "Family gin rummy")
                Game.Draft(title: "Weekly poker night")
                Game.Draft(title: "Mahjong with grandma")
            }
        }
    }
}
