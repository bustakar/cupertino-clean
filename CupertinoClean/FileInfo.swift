import Foundation

struct FileInfo: Identifiable, Comparable {
    let id = UUID()
    let path: String
    let name: String
    let size: Int64
    let creationDate: Date?
    let modificationDate: Date?
    let isDirectory: Bool
    
    init(path: String, name: String, size: Int64, creationDate: Date?, modificationDate: Date?, isDirectory: Bool) {
        self.path = path
        self.name = name
        self.size = size
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.isDirectory = isDirectory
    }
    
    // Comparable implementation for sorting by size (largest first)
    static func < (lhs: FileInfo, rhs: FileInfo) -> Bool {
        return lhs.size > rhs.size // Reverse order for descending
    }
    
    // Format file size for display
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    // Format date for display
    var formattedModificationDate: String {
        guard let date = modificationDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 