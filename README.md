# SlnQuickLook

A macOS Quick Look extension that provides syntax-highlighted previews for Visual Studio Solution files (`.sln` and `.slnx`).

![macOS](https://img.shields.io/badge/macOS-12.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Features

- 🎨 **Syntax Highlighting** - Color-coded XML and text-based solution files
- 🔢 **Line Numbers** - Easy reference with line numbers on the left
- 📋 **Smart Copy** - Copy text without line numbers automatically
- 🌙 **Dark Theme** - VS Code-inspired color scheme
- ⚡ **Fast & Lightweight** - Native Swift implementation, no dependencies
- 🔒 **Sandboxed** - Secure Quick Look extension

## Preview

<img src="https://raw.githubusercontent.com/lewiuberg/SlnQuickLook/refs/heads/main/examples/Example.slnx.png" width="720" alt="SLNX file preview with XML syntax highlighting">

<img src="https://raw.githubusercontent.com/lewiuberg/SlnQuickLook/refs/heads/main/examples/Example.sln.png" width="720" alt="SLN file preview with text-based highlighting">

## Supported Formats

- **`.sln`** - Visual Studio Solution files (text-based format)
- **`.slnx`** - Visual Studio XML Solution files (XML format)

Both traditional text-based `.sln` files and modern XML-based `.slnx` files are supported with appropriate syntax highlighting.

## Installation

### Via Homebrew (Recommended)

```bash
# Add the tap (once)
brew tap lewiuberg/tap

# Install SlnQuickLook
brew install --cask slnquicklook
```

After installation:

1. **Open the SlnQuickLook app** once to register the extension
   - If macOS blocks it (unsigned app warning):
     - Go to **System Settings** → **Privacy & Security**
     - Scroll down and click **"Open Anyway"**
     - Try opening the app again and confirm
2. Reset Quick Look: `qlmanage -r && qlmanage -r cache`
3. Restart Finder: `killall Finder`
4. Select a `.sln` or `.slnx` file and press **Space** to preview

### Manual Installation

1. Download the latest release from [Releases](https://github.com/lewiuberg/SlnQuickLook/releases)
2. Unzip and move `SlnQuickLook.app` to `/Applications/`
3. **Open the app** once to register the Quick Look extension
   - If macOS blocks it (unsigned app warning):
     - Go to **System Settings** → **Privacy & Security**
     - Scroll down and click **"Open Anyway"**
     - Try opening the app again and confirm
4. Reset Quick Look cache:
   ```bash
   qlmanage -r && qlmanage -r cache
   ```
5. Restart Finder: `killall Finder`

### Build from Source

Requirements:

- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later

```bash
# Clone the repository
git clone https://github.com/lewiuberg/SlnQuickLook.git
cd SlnQuickLook

# Open in Xcode
open SlnQuickLook.xcodeproj

# Build and run (⌘R)
# The extension will be registered automatically
```

## Usage

1. **Preview a file**: Select a `.sln` or `.slnx` file in Finder and press **Space**
2. **Copy content**: Select text in the preview and press **⌘C** - line numbers are automatically excluded
3. **Scroll**: Use mouse/trackpad to scroll through large files
4. **Close preview**: Press **Space** or **Esc**

## Troubleshooting

### Preview not showing

1. Make sure you've opened the SlnQuickLook app at least once
2. Reset Quick Look:
   ```bash
   qlmanage -r
   qlmanage -r cache
   killall Finder
   ```
3. Check if the extension is loaded:
   ```bash
   qlmanage -m
   ```
   Look for `SlnQuickLook` in the output

### Wrong file type association

If another app is opening `.sln`/`.slnx` files:

1. Right-click the file → Get Info
2. Under "Open with:", select SlnQuickLook
3. Click "Change All..."

### Extension not loading

Try re-registering the app:

```bash
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -R /Applications/SlnQuickLook.app
```

## Technical Details

### Architecture

- **Language**: Swift 5.0
- **Framework**: QuickLook, AppKit
- **Minimum macOS**: 12.0 (Monterey)
- **Code Signing**: Required for distribution

### Syntax Highlighting

The extension provides custom syntax highlighting:

**XML-based files (.slnx)**:

- Green: XML tags (`<Project>`, `</Solution>`)
- Blue: Attribute names (`Path=`, `Name=`)
- Orange: Attribute values (`"src/..."`)

**Text-based files (.sln)**:

- Green: Keywords (`Project`, `EndProject`, `Global`)
- Orange: String values (quoted text)
- Gray: Comments (lines starting with `#`)

### Performance

- Handles files up to several MB efficiently
- Lazy rendering for large files
- No external dependencies
- Minimal memory footprint

## Development

### Project Structure

```
SlnQuickLook/
├── SlnQuickLook/                    # Main app (hosts extension)
│   ├── Assets.xcassets/
│   ├── Info.plist
│   ├── SlnQuickLookApp.swift
│   └── ContentView.swift
└── SlnQuickLookPreviewExtension/    # Quick Look extension
    ├── Info.plist
    └── PreviewViewController.swift  # All logic
```

### Building

```bash
# Debug build
xcodebuild -scheme SlnQuickLook -configuration Debug

# Release build
xcodebuild -scheme SlnQuickLook -configuration Release

# Run tests (if any)
xcodebuild test -scheme SlnQuickLook
```

### Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:

- Code follows Swift style guidelines
- Changes are tested on macOS 12.0+
- Commit messages are clear and descriptive

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by Quick Look extensions like [QLMarkdown](https://github.com/toland/qlmarkdown)
- Color scheme inspired by Visual Studio Code's Dark+ theme
- Built with Apple's QuickLook framework

## Author

**Lewi Uberg**

- GitHub: [@lewiuberg](https://github.com/lewiuberg)

## Support

If you find this useful, please:

- ⭐ Star the repository
- 🐛 Report bugs via [Issues](https://github.com/lewiuberg/SlnQuickLook/issues)
- 💡 Suggest features via [Issues](https://github.com/lewiuberg/SlnQuickLook/issues)
- 🔀 Submit pull requests
