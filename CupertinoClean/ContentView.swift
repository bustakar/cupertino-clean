import SwiftUI

struct ContentView: View {
    @State private var directoryManager = DirectoryManager()
    @State private var fileScanner = FileScanner()

    var body: some View {
        VStack(spacing: 20) {
            header
            tags
            list
        }
        .padding()
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("CupertinoClean")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Scan and clean your Mac")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if fileScanner.scanning {
                Button(action: {
                    fileScanner.stopScan()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                        Text("Stop Scan")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            } else {
                Button(action: {
                    fileScanner.startScan()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                        Text("Scan Cleanable Files")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private var tags: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(directoryManager.tags.sorted(by: <), id: \.self) { tag in
                    Tag(title: tag, isSelected: directoryManager.selectedTags.contains(tag)) {
                        directoryManager.toggleTag(tag)
                    }
                }
            }
        }
    }

    private var list: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Directories to Scan")
                    .font(.headline)
                    .fontWeight(.semibold)

                Button(action: directoryManager.selectAll) {
                    Text(directoryManager.selectedDirectories.isEmpty ? "Select all" : "Deselect all")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .disabled(fileScanner.scanning)

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 12) {
                        Text("\(directoryManager.selectedDirectories.count) repositories - \(formatTotalSize())")
                            .font(.caption)
                            .foregroundColor(.secondary)

                         Button(action: {
                             // Clear all selected directories
                             directoryManager.clearSelectedDirectories()
                             fileScanner.startScan()
                         }) {
                            Text("Clear all")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled(fileScanner.scanning)
                    }
                }
            }

            List {
                ForEach(directoryManager.filteredDirectories, id: \.self) { directory in
                    DirectoryRow(
                        directory: directory,
                        fileScanner: fileScanner
                    ) {
                        directoryManager.toggleDirectory(directory)
                    }
                }
            }
            .listStyle(.plain)
            .cornerRadius(8)
        }
    }
    
    private func formatTotalSize() -> String {
        let totalSize = directoryManager.selectedDirectories.compactMap { directory in
            fileScanner.getDirectorySize(for: directory.path)
        }.reduce(0, +)
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }
}

private struct Tag: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(title)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(isSelected ? .white : Color(NSColor.textColor))
            .background(
                isSelected ? Color.accentColor : Color(NSColor.controlBackgroundColor),
                in: .rect(cornerRadius: 16)
            )
            .onTapGesture(perform: action)
    }
}

private struct DirectoryRow: View {
    let directory: ScanDirectory
    let fileScanner: FileScanner
    let toggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Toggle("Selected", isOn: Binding(get: { directory.isSelected }, set: { _ in toggle() }))
                .labelsHidden()
                .padding(.top, 4)

            VStack(alignment: .leading) {
                Text(directory.name)
                    .font(.headline)
                
                Text(directory.path)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            
            Spacer()

            if let size = fileScanner.getDirectorySize(for: directory.path) {
                Text(formatFileSize(size))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(minWidth: 60, alignment: .trailing)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .onTapGesture(perform: toggle)
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 1000, minHeight: 700)
}

