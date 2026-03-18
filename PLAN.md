# SlnQuickLook - Deployment Plan

This document outlines the steps to publish SlnQuickLook to GitHub and make it available via Homebrew.

---

## Phase 1: Prepare the Repository

### 1.1 Create Essential Documentation

- [ ] Create `README.md` with project description, features, installation instructions
- [ ] Create `LICENSE` file (choose appropriate license, e.g., MIT)
- [ ] Create `.gitignore` for Xcode projects
- [ ] Add screenshots/demo GIF showing the Quick Look preview in action

### 1.2 Clean Up the Project

- [ ] Remove build artifacts: `rm -rf build/`
- [ ] Remove `.DS_Store` files: `find . -name ".DS_Store" -delete`
- [ ] Verify no sensitive information (API keys, personal data) in code
- [ ] Test that the app builds cleanly from scratch

### 1.3 Version the Project

- [ ] Decide on initial version number (recommend: `0.1.0`)
- [ ] Update version in Xcode project settings
- [ ] Update `CFBundleShortVersionString` and `CFBundleVersion` in Info.plist files

---

## Phase 2: Publish to GitHub

### 2.1 Initialize Git Repository (if not already done)

```bash
cd /Users/lewiuberg/Repositories/SlnQuickLook
git init
git add .
git commit -m "Initial commit: SlnQuickLook v0.1.0"
```

### 2.2 Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `SlnQuickLook`
3. Description: "macOS Quick Look extension for .sln and .slnx files with syntax highlighting"
4. Choose Public or Private
5. **Do NOT** initialize with README (we already have one)
6. Click "Create repository"

### 2.3 Push to GitHub

```bash
git remote add origin https://github.com/lewiuberg/SlnQuickLook.git
git branch -M main
git push -u origin main
```

### 2.4 Create Initial Release

1. Go to repository → Releases → "Create a new release"
2. Tag version: `v0.1.0`
3. Release title: `SlnQuickLook v0.1.0`
4. Description: List features and installation instructions
5. Attach pre-built `.app` file (see Phase 3)
6. Publish release

---

## Phase 3: Build Release Version

### 3.1 Archive the Application

```bash
cd /Users/lewiuberg/Repositories/SlnQuickLook

# Build Release version
xcodebuild -scheme SlnQuickLook \
  -configuration Release \
  -archivePath ./SlnQuickLook.xcarchive \
  archive

# Export the app
xcodebuild -exportArchive \
  -archiveePath ./SlnQuickLook.xcarchive \
  -exportPath ./Release \
  -exportOptionsPlist ExportOptions.plist
```

### 3.2 Create ExportOptions.plist

Create a file named `ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

### 3.3 Create Distributable Package

```bash
# Create a DMG or ZIP file
cd Release
zip -r SlnQuickLook-v1.0.0.zip SlnQuickLook.app
```

### 3.4 Calculate SHA256 (needed for Homebrew)

```bash
shasum -a 256 SlnQuickLook-v1.0.0.zip
# Save this hash - you'll need it for Homebrew formula
```

---

## Phase 4: Create Homebrew Formula

### 4.1 Understand Homebrew Cask

Homebrew Cask is used for GUI macOS applications. You have two options:

**Option A: Official Homebrew Cask (Recommended)**
- Submit to `homebrew/cask` repository
- More visibility, trusted by users
- Requires review process

**Option B: Personal Tap (Easier to start)**
- Create your own tap (custom repository)
- Full control, faster deployment
- Users install via: `brew install YOUR_USERNAME/tap/slnquicklook`

### 4.2 Create Personal Tap (Option B - Recommended for start)

#### Step 1: Create Tap Repository

1. Create new GitHub repository: `homebrew-tap`
2. Clone it locally:

```bash
git clone https://github.com/YOUR_USERNAME/homebrew-tap.git
cd homebrew-tap
mkdir Casks
```

#### Step 2: Create Cask Formula

Create file `Casks/slnquicklook.rb`:

```ruby
cask "slnquicklook" do
  version "1.0.0"
  sha256 "YOUR_SHA256_HASH_FROM_PHASE_3.4"

  url "https://github.com/YOUR_USERNAME/SlnQuickLook/releases/download/v#{version}/SlnQuickLook-v#{version}.zip"
  name "SlnQuickLook"
  desc "Quick Look extension for .sln and .slnx files"
  homepage "https://github.com/YOUR_USERNAME/SlnQuickLook"

  depends_on macos: ">= :monterey"

  app "SlnQuickLook.app"

  postflight do
    system_command "/usr/bin/qlmanage",
                   args: ["-r"],
                   sudo: false
    system_command "/usr/bin/qlmanage",
                   args: ["-r", "cache"],
                   sudo: false
  end

  uninstall quit: "com.example.SlnQuickLook"

  zap trash: [
    "~/Library/Preferences/com.example.SlnQuickLook.plist",
    "~/Library/Caches/com.apple.QuickLook.thumbnailcache",
  ]

  caveats <<~EOS
    SlnQuickLook has been installed!

    To activate the Quick Look extension:
    1. Open the SlnQuickLook app once
    2. Restart Finder: killall Finder
    3. Select a .sln or .slnx file and press Space

    To reset Quick Look cache if needed:
      qlmanage -r && qlmanage -r cache
  EOS
end
```

#### Step 3: Push Tap to GitHub

```bash
git add Casks/slnquicklook.rb
git commit -m "Add SlnQuickLook cask"
git push origin main
```

### 4.3 Test Installation

```bash
# Add your tap
brew tap YOUR_USERNAME/tap

# Install the app
brew install --cask slnquicklook

# Verify installation
ls /Applications/SlnQuickLook.app
```

### 4.4 Submit to Official Homebrew Cask (Optional - Later)

Once your personal tap is working well:

1. Fork `homebrew/homebrew-cask` repository
2. Create branch: `git checkout -b slnquicklook`
3. Add cask to `Casks/s/slnquicklook.rb`
4. Test: `brew install --cask slnquicklook`
5. Run audit: `brew audit --cask --online slnquicklook`
6. Submit PR to `homebrew/homebrew-cask`
7. Wait for review and approval

---

## Phase 5: Documentation and Promotion

### 5.1 Update README.md

Include:
- [ ] Clear description of what the extension does
- [ ] Screenshots/GIF demo
- [ ] Installation instructions (Homebrew + manual)
- [ ] Usage instructions
- [ ] Supported file formats
- [ ] Requirements (macOS version)
- [ ] How to build from source
- [ ] Contributing guidelines
- [ ] License information

### 5.2 Create Visual Assets

- [ ] Take screenshots of Quick Look preview
- [ ] Create animated GIF showing usage
- [ ] Design app icon (if not already done)
- [ ] Add images to repository in `assets/` or `docs/` folder

### 5.3 Promote the Project

- [ ] Share on Reddit (r/macapps, r/programming)
- [ ] Post on Hacker News
- [ ] Tweet about it
- [ ] Write blog post explaining the project
- [ ] Add topics/tags to GitHub repo (quicklook, macos, swift, syntax-highlighting)

---

## Phase 6: Maintenance

### 6.1 Set Up Issue Templates

Create `.github/ISSUE_TEMPLATE/`:
- Bug report template
- Feature request template

### 6.2 Set Up CI/CD (Optional)

Create `.github/workflows/build.yml` for GitHub Actions:
- Automatic builds on push
- Run tests
- Create release artifacts

### 6.3 Version Updates

When releasing new versions:

1. Update version in Xcode
2. Update Info.plist files
3. Commit changes
4. Create git tag: `git tag v1.1.0`
5. Push tag: `git push origin v1.1.0`
6. Create GitHub release with new binary
7. Update Homebrew cask with new version and SHA256
8. Test installation

---

## Checklist Summary

### Before Publishing
- [ ] Code is clean and well-documented
- [ ] All unused files removed
- [ ] App builds successfully in Release mode
- [ ] Extension works correctly
- [ ] README.md written
- [ ] LICENSE file added
- [ ] .gitignore configured

### GitHub Setup
- [ ] Repository created on GitHub
- [ ] Code pushed to GitHub
- [ ] Release v1.0.0 created
- [ ] Binary attached to release

### Homebrew Setup
- [ ] Personal tap repository created
- [ ] Cask formula written
- [ ] SHA256 calculated and added
- [ ] Formula tested locally
- [ ] Tap pushed to GitHub

### Documentation
- [ ] README with installation instructions
- [ ] Screenshots/demo added
- [ ] Usage instructions clear
- [ ] Contributing guidelines added

### Optional
- [ ] Submit to official Homebrew Cask
- [ ] Set up CI/CD
- [ ] Promote on social media
- [ ] Write blog post

---

## Estimated Timeline

- **Phase 1-2** (Prepare & Publish): 2-3 hours
- **Phase 3** (Build Release): 1 hour
- **Phase 4** (Homebrew): 2-3 hours
- **Phase 5** (Documentation): 2-4 hours
- **Phase 6** (Optional CI/CD): 2-4 hours

**Total**: 1-2 days for complete setup

---

## Resources

- [Homebrew Cask Documentation](https://docs.brew.sh/Cask-Cookbook)
- [GitHub Releases Guide](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Xcode Archiving Guide](https://developer.apple.com/documentation/xcode/distributing-your-app-to-registered-devices)
- [Choose a License](https://choosealicense.com/)

---

## Notes

- Consider code signing for better user trust (requires Apple Developer account)
- Notarization recommended for distribution outside App Store
- Keep version numbers consistent across all files
- Test installation on clean macOS system before public release
