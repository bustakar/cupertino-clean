import Foundation
import SwiftUI

struct ScanDirectory: Identifiable, Hashable {
    let id = UUID()
    var path: String
    var name: String
    var isSelected: Bool
    var tags: [String]
}

@Observable
class DirectoryManager {
    var directories: [ScanDirectory] = []
    var tags: Set<String> { Set(directories.flatMap { $0.tags }) }
    var selectedDirectories: [ScanDirectory] { directories.filter { $0.isSelected } }
    var filteredDirectories: [ScanDirectory] {
        guard !selectedTags.isEmpty else { return directories }
        return directories.filter { directory in
            directory.tags.contains(where: { selectedTags.contains($0) })
        }
    }
    var selectedTags: Set<String> = Set()

    init() {
        loadDirectoriesFromFile()
    }
    
    private func loadDirectoriesFromFile() {
        let entries = DirectoryLoader.loadDirectories()
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        
        print("Loaded \(entries.count) directories from JSON")
        
        directories = entries.map { entry in
            let expandedPath = entry.path.replacingOccurrences(of: "~", with: homeDirectory)
            return ScanDirectory(
                path: expandedPath,
                name: entry.name,
                isSelected: false,
                tags: entry.tags
            )
        }
        
        print("Created \(directories.count) ScanDirectory objects")
    }

    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    func selectAll() {
        if selectedDirectories.isEmpty {
            directories.forEach { selectDirectory($0, isSelected: true) }
        } else {
            directories.forEach { selectDirectory($0, isSelected: false) }
        }
    }

    func clearSelectedDirectories() {
        // Delete all contents of selected directories from disk
        let selectedPaths = directories.filter { $0.isSelected }.map { $0.path }
        
        for path in selectedPaths {
            do {
                let fileManager = FileManager.default
                let url = URL(fileURLWithPath: path)
                
                // Check if directory exists
                guard fileManager.fileExists(atPath: path) else {
                    print("Directory does not exist: \(path)")
                    continue
                }
                
                // Get all contents of the directory
                let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                
                // Delete each item in the directory
                for item in contents {
                    try fileManager.removeItem(at: item)
                    print("Successfully deleted: \(item.path)")
                }
                
                print("Successfully cleared contents of: \(path)")
            } catch {
                print("Failed to clear contents of \(path): \(error)")
            }
        }
    }

    func toggleDirectory(_ directory: ScanDirectory) {
        if let index = directories.firstIndex(where: { $0.path == directory.path }) {
            directories[index].isSelected.toggle()
        }
    }

    func selectDirectory(_ directory: ScanDirectory, isSelected: Bool) {
        if let index = directories.firstIndex(where: { $0.path == directory.path }) {
            directories[index].isSelected = isSelected
        }
    }
}
