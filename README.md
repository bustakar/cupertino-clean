# CupertinoClean

A macOS app that scans your MacBook and lists the top 50 largest cleanable files with detailed information.

## Features

- **File System Scanning**: Scans your home directory and system directories for cleanable files
- **Top 50 Files**: Displays the 50 largest cleanable files sorted by size
- **Detailed Information**: Shows file name, path, type, size, and modification date
- **File Icons**: Displays native macOS file icons
- **File Type Detection**: Automatically categorizes files by type
- **Finder Integration**: Click on any file to reveal it in Finder
- **Progress Tracking**: Real-time progress during scanning
- **Editable Directory List**: Add, remove, and reorder directories to scan
- **Drag & Drop Support**: Drag folders from Finder directly into the app
- **Background Scanning**: Non-blocking UI during file system scanning

## How to Use

1. **Launch the App**: Open CupertinoClean from your Applications folder
2. **Manage Directories**: Click the "Directories" tab to customize which folders to scan
3. **Start Scanning**: Click the "Scan Cleanable Files" button to begin analyzing your system
4. **View Results**: The app will display the top 50 largest cleanable files
5. **Clean Up**: Use the file information to identify large files that can be safely deleted

## What It Scans

CupertinoClean focuses on directories that can be safely cleaned for space:

- **Xcode Data**: Derived Data, Archives, iOS Device Support, Core Simulator
- **Browser Caches**: Chrome, Safari, Firefox caches
- **System Caches**: Library caches, temporary files
- **Downloads & Trash**: User download folders and trash
- **Development Tools**: Homebrew, npm, CocoaPods, and other dev tool caches
- **App Caches**: Discord, Slack, Zoom, and other app caches
- **Virtual Machines**: Docker, Steam, and VM files
- **IDE Caches**: JetBrains IDEs, VS Code, and other development tools

## Safety Features

- Only scans directories that are safe to clean
- Shows file information before deletion
- Integrates with Finder for easy file management
- Non-destructive scanning (doesn't delete files automatically)

## Requirements

- macOS 15.5 or later
- No additional dependencies required

## Building

```bash
# Build the project
xcodebuild -project CupertinoClean.xcodeproj -scheme CupertinoClean -configuration Debug build

# Run the app
open /path/to/CupertinoClean.app
```

## Contributing

### Adding New Directories

CupertinoClean uses a JSON configuration file to manage the list of directories to scan. This makes it easy for contributors to add new directories via pull requests.

#### How to Add a New Directory

1. **Edit the JSON file**: Open `CupertinoClean/Resources/directories.json`
2. **Add a new directory object**: Each directory should have:
   - `path`: The directory path (use `~` for home directory)
   - `name`: A human-readable display name
   - `tags`: Array of tags for filtering (e.g., `["xcode"]`, `["browser"]`, `["dev"]`)

#### Example Directory Entry

```json
{
  "path": "~/Library/Application Support/SomeApp/Cache",
  "name": "SomeApp Cache",
  "tags": ["app"]
}
```

#### Available Tags

- `xcode`: Xcode-related directories
- `system`: System caches and temporary files
- `browser`: Browser caches and data
- `dev`: Development tool caches
- `app`: Application caches
- `ide`: IDE and editor caches
- `gaming`: Game-related files
- `vm`: Virtual machine files
- `docker`: Docker-related files
- `user`: User files (Downloads, Desktop, etc.)

#### Guidelines for Adding Directories

1. **Safety First**: Only add directories that are safe to clean (caches, temporary files, etc.)
2. **Descriptive Names**: Use clear, descriptive names that users will understand
3. **Appropriate Tags**: Choose tags that accurately categorize the directory
4. **Test Your Changes**: Build and test the app to ensure your directory is properly loaded
5. **Documentation**: If adding a new tag, update this README

#### Submitting Changes

1. Fork the repository
2. Create a feature branch
3. Add your directory to `directories.json`
4. Test that the app builds and runs correctly
5. Submit a pull request with a clear description of what you added

## License

This project is open source and available under the MIT License.
