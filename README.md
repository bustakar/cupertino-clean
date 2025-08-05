# CupertinoClean

A macOS app to help you clean up disk space by scanning and removing unnecessary files from common directories like Xcode DerivedData, browser caches, system caches, and more.

## Features

- **Smart Directory Scanning**: Automatically scans common directories that accumulate large files
- **Tag-based Filtering**: Filter directories by categories (xcode, system, browser, dev, gaming, etc.)
- **Size Display**: Shows the size of each directory after scanning
- **Safe Cleaning**: Deletes contents of directories while preserving the directory structure
- **JSON Configuration**: Easy to add new directories via pull requests

## Quick Start

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later

### Installation & Running

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/cupertino-clean.git
   cd cupertino-clean
   ```

2. **Open in Xcode**

   ```bash
   open CupertinoClean.xcodeproj
   ```

3. **Build and Run**
   - Press `Cmd + R` in Xcode, or
   - Click the "Play" button in Xcode toolbar
   - The app will launch and you can start scanning directories

### Using the App

1. **Scan Directories**: Click "Scan Cleanable Files" to analyze all directories
2. **Filter by Tags**: Use the tag buttons to filter directories by category
3. **Select Directories**: Check the directories you want to clean
4. **Clear Selected**: Click "Clear all" to delete contents of selected directories

## Supported Directories

The app scans these common directories that accumulate large files:

### Development

- **Xcode DerivedData**: Build artifacts and intermediate files
- **Xcode iOS Device Support**: Device-specific build files
- **Xcode Archives**: App archives and distribution files
- **Xcode Core Simulator**: iOS Simulator data

### System & Browser

- **User Library Caches**: Application cache files
- **System Library Caches**: System-level cache files
- **Chrome Cache**: Browser cache files
- **Safari LocalStorage**: Browser storage files

### Development Tools

- **Homebrew Cache**: Package manager cache
- **npm Cache**: Node.js package cache
- **CocoaPods Cache**: iOS dependency cache

### User Files

- **Downloads**: User download folder
- **Trash**: Deleted files

## Contributing

### Adding New Directories

CupertinoClean uses a JSON configuration file to manage the list of directories to scan. This makes it easy for contributors to add new directories via pull requests.

#### How to Add a New Directory

1. **Edit the JSON file**: Open `CupertinoClean/Resources/directories.json`
2. **Add a new directory object**: Each directory should have:
   - `path`: The directory path (use `~` for home directory)
   - `name`: A human-readable name for the directory
   - `tags`: Array of tags for filtering (e.g., `["xcode"]`, `["system"]`, `["browser"]`)

#### Example Directory Entry

```json
{
  "path": "~/Library/Developer/Xcode/DerivedData",
  "name": "Xcode Derived Data",
  "tags": ["xcode"]
}
```

#### Available Tags

- `xcode`: Xcode-related directories
- `system`: System cache and temporary files
- `browser`: Browser cache and storage
- `dev`: Development tool caches
- `gaming`: Game-related files
- `vm`: Virtual machine files
- `user`: User-specific files

### Submitting Changes

1. **Fork the repository** on GitHub
2. **Create a feature branch**:
   ```bash
   git checkout -b add-new-directory
   ```
3. **Make your changes** to `directories.json`
4. **Test your changes** by building and running the app
5. **Commit and push**:
   ```bash
   git add CupertinoClean/Resources/directories.json
   git commit -m "Add new directory: [Directory Name]"
   git push origin add-new-directory
   ```
6. **Create a Pull Request** on GitHub

### Guidelines for New Directories

- **Safety First**: Only include directories that are safe to clean
- **Common Use Cases**: Focus on directories that commonly accumulate large files
- **Clear Naming**: Use descriptive names that users will understand
- **Proper Tagging**: Use appropriate tags for easy filtering
- **Test Thoroughly**: Verify the directory exists and is safe to clean

## Building from Source

### Command Line Build

```bash
# Build the project
xcodebuild -project CupertinoClean.xcodeproj -scheme CupertinoClean -configuration Debug build

# Run the app
open build/Debug/CupertinoClean.app
```

### Build Script

Use the provided build script:

```bash
./build.sh
```

## Safety Notes

- The app only deletes **contents** of directories, not the directories themselves
- This preserves system functionality while freeing up space
- Always review what will be deleted before clicking "Clear all"
- The app includes safety checks to prevent accidental deletion of important files

## Troubleshooting

### Common Issues

1. **"Could not find directories.json"**

   - Ensure the JSON file is properly included in the Xcode project
   - Check that the file path in DirectoryLoader.swift is correct

2. **Permission Denied**

   - Some system directories require administrator privileges
   - The app will log errors for directories it cannot access

3. **Build Errors**
   - Ensure you're using Xcode 15.0 or later
   - Clean build folder: `Cmd + Shift + K` in Xcode
   - Reset package caches if using Swift Package Manager

## License

This project is open source and available under the MIT License.

## Support

- **Issues**: Report bugs or request features on GitHub Issues
- **Contributions**: Submit pull requests for new directories or improvements
- **Discussions**: Use GitHub Discussions for questions and ideas
