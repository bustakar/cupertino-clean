import Foundation
import SwiftUI

@Observable
class FileScanner {
    private var files: [FileInfo] = []
    private var isScanning = false
    private var scanProgress: Double = 0.0
    private var scannedDirectories = 0
    private var totalDirectories = 0
    private var shouldStopScanning = false
    private var scanTask: Task<Void, Never>?
    private var directorySizes: [String: Int64] = [:]
    
    // Directory manager
    var directoryManager = DirectoryManager()
    
    // Computed properties for the view
    var topFiles: [FileInfo] {
        Array(files.sorted().prefix(50))
    }
    
    var scanning: Bool {
        get { isScanning }
        set { isScanning = newValue }
    }
    
    var progress: Double {
        get { scanProgress }
        set { scanProgress = newValue }
    }
    
    var directoriesScanned: Int {
        get { scannedDirectories }
        set { scannedDirectories = newValue }
    }
    
    var totalDirectoriesToScan: Int {
        get { totalDirectories }
        set { totalDirectories = newValue }
    }
    
    // Stop scanning
    func stopScan() {
        shouldStopScanning = true
        scanTask?.cancel()
    }
    
    // Start scanning the file system
    func startScan() {
        // Cancel any existing scan
        scanTask?.cancel()
        
        // Create new background task
        scanTask = Task { @MainActor in
            await performScan()
        }
    }
    
    // Perform the actual scan in background
    private func performScan() async {
        await MainActor.run {
            isScanning = true
            progress = 0.0
            directoriesScanned = 0
            shouldStopScanning = false
            files.removeAll()
        }
        
        // Get directories from directory manager
        let directoriesToScan = directoryManager.directories

        await MainActor.run {
            totalDirectoriesToScan = directoriesToScan.count
        }
        
        var allFiles: [FileInfo] = []
        
        for (index, directory) in directoriesToScan.enumerated() {
            // Check if scanning should be stopped
            if shouldStopScanning {
                break
            }
            
            // Scan directory in background
            let (directoryFiles, directorySize) = await Task.detached(priority: .background) {
                await self.scanDirectory(directory.path)
            }.value
            
            allFiles.append(contentsOf: directoryFiles)
            
            // Store directory size
            await MainActor.run {
                directorySizes[directory.path] = directorySize
            }
            
            await MainActor.run {
                directoriesScanned = index + 1
                progress = Double(index + 1) / Double(directoriesToScan.count)
            }
        }
        
        // Update files on main actor to avoid concurrency issues
        await MainActor.run {
            files = allFiles
            isScanning = false
            shouldStopScanning = false
        }
    }
    
    // Scan a specific directory recursively
    private func scanDirectory(_ path: String) async -> ([FileInfo], Int64) {
        var files: [FileInfo] = []
        var totalSize: Int64 = 0
        
        // Check if directory exists
        guard FileManager.default.fileExists(atPath: path) else {
            return (files, totalSize)
        }
        
        guard let enumerator = FileManager.default.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.fileSizeKey, .creationDateKey, .contentModificationDateKey, .isDirectoryKey],
            options: [.skipsHiddenFiles],
            errorHandler: { _, _ in return true }
        ) else {
            return (files, totalSize)
        }
        
        for case let fileURL as URL in enumerator {
            // Check if scanning should be stopped
            if shouldStopScanning {
                break
            }
            
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .creationDateKey, .contentModificationDateKey, .isDirectoryKey])
                
                let size = resourceValues.fileSize ?? 0
                let isDirectory = resourceValues.isDirectory ?? false
                
                // Only include files (not directories) and files with size > 0
                if !isDirectory && size > 0 {
                    let fileInfo = FileInfo(
                        path: fileURL.path,
                        name: fileURL.lastPathComponent,
                        size: Int64(size),
                        creationDate: resourceValues.creationDate,
                        modificationDate: resourceValues.contentModificationDate,
                        isDirectory: false
                    )
                    files.append(fileInfo)
                    totalSize += Int64(size)
                }
            } catch {
                // Skip files that can't be accessed
                continue
            }
        }
        
        return (files, totalSize)
    }
    
    // Get file icon for display
    func getFileIcon(for fileInfo: FileInfo) -> NSImage {
        let url = URL(fileURLWithPath: fileInfo.path)
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        return icon
    }
    
    // Get directory size
    func getDirectorySize(for path: String) -> Int64? {
        return directorySizes[path]
    }
    
    // Get file type description
    func getFileTypeDescription(for fileInfo: FileInfo) -> String {
        let url = URL(fileURLWithPath: fileInfo.path)
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "app":
            return "Application"
        case "dmg":
            return "Disk Image"
        case "pkg":
            return "Package"
        case "zip", "tar", "gz", "rar", "7z":
            return "Archive"
        case "mp4", "mov", "avi", "mkv", "wmv":
            return "Video"
        case "mp3", "wav", "aac", "flac":
            return "Audio"
        case "jpg", "jpeg", "png", "gif", "bmp", "tiff":
            return "Image"
        case "pdf":
            return "PDF"
        case "doc", "docx":
            return "Word Document"
        case "xls", "xlsx":
            return "Excel Spreadsheet"
        case "ppt", "pptx":
            return "PowerPoint"
        case "txt", "rtf":
            return "Text Document"
        case "html", "htm":
            return "Web Page"
        case "css":
            return "Stylesheet"
        case "js":
            return "JavaScript"
        case "py":
            return "Python Script"
        case "swift":
            return "Swift Source"
        case "java":
            return "Java Source"
        case "c", "cpp", "h", "hpp":
            return "C/C++ Source"
        case "json":
            return "JSON Data"
        case "xml":
            return "XML Data"
        case "sql":
            return "SQL Script"
        case "db", "sqlite":
            return "Database"
        case "log":
            return "Log File"
        case "plist":
            return "Property List"
        case "sh", "bash", "zsh":
            return "Shell Script"
        case "git":
            return "Git Repository"
        case "xcworkspace", "xcodeproj":
            return "Xcode Project"
        case "xcuserdata":
            return "Xcode User Data"
        case "xcscmblueprint":
            return "Xcode SCM Blueprint"
        case "xcuserstate":
            return "Xcode User State"
        case "xcuserdatad":
            return "Xcode User Data Directory"
        case "xcuserdata1":
            return "Xcode User Data"
        case "xcuserdata2":
            return "Xcode User Data"
        case "xcuserdata3":
            return "Xcode User Data"
        case "xcuserdata4":
            return "Xcode User Data"
        case "xcuserdata5":
            return "Xcode User Data"
        case "xcuserdata6":
            return "Xcode User Data"
        case "xcuserdata7":
            return "Xcode User Data"
        case "xcuserdata8":
            return "Xcode User Data"
        case "xcuserdata9":
            return "Xcode User Data"
        case "xcuserdata10":
            return "Xcode User Data"
        case "xcuserdata11":
            return "Xcode User Data"
        case "xcuserdata12":
            return "Xcode User Data"
        case "xcuserdata13":
            return "Xcode User Data"
        case "xcuserdata14":
            return "Xcode User Data"
        case "xcuserdata15":
            return "Xcode User Data"
        case "xcuserdata16":
            return "Xcode User Data"
        case "xcuserdata17":
            return "Xcode User Data"
        case "xcuserdata18":
            return "Xcode User Data"
        case "xcuserdata19":
            return "Xcode User Data"
        case "xcuserdata20":
            return "Xcode User Data"
        case "xcuserdata21":
            return "Xcode User Data"
        case "xcuserdata22":
            return "Xcode User Data"
        case "xcuserdata23":
            return "Xcode User Data"
        case "xcuserdata24":
            return "Xcode User Data"
        case "xcuserdata25":
            return "Xcode User Data"
        case "xcuserdata26":
            return "Xcode User Data"
        case "xcuserdata27":
            return "Xcode User Data"
        case "xcuserdata28":
            return "Xcode User Data"
        case "xcuserdata29":
            return "Xcode User Data"
        case "xcuserdata30":
            return "Xcode User Data"
        case "xcuserdata31":
            return "Xcode User Data"
        case "xcuserdata32":
            return "Xcode User Data"
        case "xcuserdata33":
            return "Xcode User Data"
        case "xcuserdata34":
            return "Xcode User Data"
        case "xcuserdata35":
            return "Xcode User Data"
        case "xcuserdata36":
            return "Xcode User Data"
        case "xcuserdata37":
            return "Xcode User Data"
        case "xcuserdata38":
            return "Xcode User Data"
        case "xcuserdata39":
            return "Xcode User Data"
        case "xcuserdata40":
            return "Xcode User Data"
        case "xcuserdata41":
            return "Xcode User Data"
        case "xcuserdata42":
            return "Xcode User Data"
        case "xcuserdata43":
            return "Xcode User Data"
        case "xcuserdata44":
            return "Xcode User Data"
        case "xcuserdata45":
            return "Xcode User Data"
        case "xcuserdata46":
            return "Xcode User Data"
        case "xcuserdata47":
            return "Xcode User Data"
        case "xcuserdata48":
            return "Xcode User Data"
        case "xcuserdata49":
            return "Xcode User Data"
        case "xcuserdata50":
            return "Xcode User Data"
        case "xcuserdata51":
            return "Xcode User Data"
        case "xcuserdata52":
            return "Xcode User Data"
        case "xcuserdata53":
            return "Xcode User Data"
        case "xcuserdata54":
            return "Xcode User Data"
        case "xcuserdata55":
            return "Xcode User Data"
        case "xcuserdata56":
            return "Xcode User Data"
        case "xcuserdata57":
            return "Xcode User Data"
        case "xcuserdata58":
            return "Xcode User Data"
        case "xcuserdata59":
            return "Xcode User Data"
        case "xcuserdata60":
            return "Xcode User Data"
        case "xcuserdata61":
            return "Xcode User Data"
        case "xcuserdata62":
            return "Xcode User Data"
        case "xcuserdata63":
            return "Xcode User Data"
        case "xcuserdata64":
            return "Xcode User Data"
        case "xcuserdata65":
            return "Xcode User Data"
        case "xcuserdata66":
            return "Xcode User Data"
        case "xcuserdata67":
            return "Xcode User Data"
        case "xcuserdata68":
            return "Xcode User Data"
        case "xcuserdata69":
            return "Xcode User Data"
        case "xcuserdata70":
            return "Xcode User Data"
        case "xcuserdata71":
            return "Xcode User Data"
        case "xcuserdata72":
            return "Xcode User Data"
        case "xcuserdata73":
            return "Xcode User Data"
        case "xcuserdata74":
            return "Xcode User Data"
        case "xcuserdata75":
            return "Xcode User Data"
        case "xcuserdata76":
            return "Xcode User Data"
        case "xcuserdata77":
            return "Xcode User Data"
        case "xcuserdata78":
            return "Xcode User Data"
        case "xcuserdata79":
            return "Xcode User Data"
        case "xcuserdata80":
            return "Xcode User Data"
        case "xcuserdata81":
            return "Xcode User Data"
        case "xcuserdata82":
            return "Xcode User Data"
        case "xcuserdata83":
            return "Xcode User Data"
        case "xcuserdata84":
            return "Xcode User Data"
        case "xcuserdata85":
            return "Xcode User Data"
        case "xcuserdata86":
            return "Xcode User Data"
        case "xcuserdata87":
            return "Xcode User Data"
        case "xcuserdata88":
            return "Xcode User Data"
        case "xcuserdata89":
            return "Xcode User Data"
        case "xcuserdata90":
            return "Xcode User Data"
        case "xcuserdata91":
            return "Xcode User Data"
        case "xcuserdata92":
            return "Xcode User Data"
        case "xcuserdata93":
            return "Xcode User Data"
        case "xcuserdata94":
            return "Xcode User Data"
        case "xcuserdata95":
            return "Xcode User Data"
        case "xcuserdata96":
            return "Xcode User Data"
        case "xcuserdata97":
            return "Xcode User Data"
        case "xcuserdata98":
            return "Xcode User Data"
        case "xcuserdata99":
            return "Xcode User Data"
        case "xcuserdata100":
            return "Xcode User Data"
        case "":
            return "File"
        default:
            return pathExtension.uppercased() + " File"
        }
    }
} 
