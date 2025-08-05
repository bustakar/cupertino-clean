import Foundation

struct DirectoryEntry: Codable {
    let path: String
    let name: String
    let tags: [String]
}

struct DirectoriesFile: Codable {
    let directories: [DirectoryEntry]
}

class DirectoryLoader {
    static func loadDirectories() -> [DirectoryEntry] {
        guard let url = Bundle.main.url(forResource: "directories", withExtension: "json") else {
            print("Could not find directories.json in bundle")
            return []
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("Could not read data from directories.json")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let directoriesFile = try decoder.decode(DirectoriesFile.self, from: data)
            print("Successfully parsed \(directoriesFile.directories.count) directories from JSON")
            return directoriesFile.directories
        } catch {
            print("Error parsing directories.json: \(error)")
            return []
        }
    }
} 