# 📦 Universal Downloader - Pub.dev Release Guide

## 🎯 Pre-Release Checklist

### ✅ Required Files & Configuration

#### 1. **pubspec.yaml** - Package Metadata
```yaml
name: universal_downloader
description: A Flutter package for downloading files on all platforms (Android, iOS, Web, Windows, macOS, Linux) with progress tracking and comprehensive error handling.
version: 1.0.1
homepage: https://github.com/himanshujjp/universal_downloader
repository: https://github.com/himanshujjp/universal_downloader
documentation: https://github.com/himanshujjp/universal_downloader#readme
issue_tracker: https://github.com/himanshujjp/universal_downloader/issues

topics:
  - download
  - file
  - http
  - network
  - flutter

screenshots:
  - description: Universal Downloader supports all platforms
    path: screenshots/platforms.png
  - description: Progress tracking with real-time updates
    path: screenshots/progress.png
  - description: Web download with enhanced file type support
    path: screenshots/web_download.png
```

#### 2. **README.md** - Comprehensive Documentation
- ✅ Package description and features
- ✅ Installation instructions
- ✅ Usage examples (basic and advanced)
- ✅ API documentation
- ✅ Platform-specific information
- ✅ Screenshots and badges
- ✅ License information

#### 3. **CHANGELOG.md** - Version History
```markdown
## 1.0.1
- Fixed: Web downloader now supports all file types without restrictions
- Fixed: Resolved CORS detection issues in web downloads
- Fixed: Corrected filename corruption in web downloads
- Improved: Enhanced error handling for web download failures
- Improved: Simplified download logic for better reliability

## 1.0.0
- Initial release of universal_downloader
- Support for all Flutter platforms
- Real-time download progress tracking
- Platform-optimized storage locations
- Comprehensive error handling
```

#### 4. **LICENSE** - MIT License
- ✅ Proper copyright notice
- ✅ MIT license text

#### 5. **analysis_options.yaml** - Code Quality
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    always_declare_return_types: true
    avoid_empty_else: true
    avoid_print: true
    avoid_unnecessary_containers: true
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    sort_child_properties_last: true
    use_key_in_widget_constructors: true
```

### ✅ Code Quality Checks

#### 1. **Run Analysis**
```bash
flutter analyze --fatal-infos
```

#### 2. **Run Tests**
```bash
flutter test
```

#### 3. **Format Code**
```bash
flutter format lib/ test/ example/
```

#### 4. **Check Platform Compatibility**
```bash
# Test on multiple platforms
flutter run -d linux    # Linux
flutter run -d chrome   # Web
```

### ✅ Package Structure
```
universal_downloader/
├── lib/
│   ├── src/
│   │   ├── universal_downloader.dart
│   │   ├── platform/
│   │   │   ├── web_downloader.dart
│   │   │   └── io_downloader.dart
│   │   ├── models/
│   │   ├── exceptions/
│   │   └── utils/
│   └── universal_downloader.dart
├── test/
├── example/
├── screenshots/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── analysis_options.yaml
└── pubspec.yaml
```

## 🚀 Publishing Steps

### Step 1: Prepare for Publishing

#### 1.1 Update Version Number
```bash
# Update version in pubspec.yaml
version: 1.0.1  # Increment for new release
```

#### 1.2 Update CHANGELOG.md
```markdown
## [1.0.1] - 2025-09-19
- Fixed: Web downloader now supports all file types without restrictions
- Fixed: Resolved CORS detection issues in web downloads
- Fixed: Corrected filename corruption in web downloads
- Improved: Enhanced error handling for web download failures
- Improved: Simplified download logic for better reliability
```

#### 1.3 Create Screenshots (Optional but Recommended)
```bash
# Create screenshots directory
mkdir screenshots

# Add these images:
# - platforms.png: Show platform support matrix
# - progress.png: Show progress tracking UI
# - web_download.png: Show web download interface
```

### Step 2: Test Package Locally

#### 2.1 Test as Local Dependency
```bash
# In a test project, add local dependency
dependencies:
  universal_downloader:
    path: ../universal_downloader

# Test all features
flutter pub get
flutter run
```

#### 2.2 Run Comprehensive Tests
```bash
# Run all tests
flutter test --coverage

# Test on different platforms
flutter run -d chrome     # Web
flutter run -d linux      # Linux
```

### Step 3: Validate Package

#### 3.1 Check with pana (Dart Package Analyzer)
```bash
# Install pana globally
flutter pub global activate pana

# Analyze package
flutter pub global run pana --no-warning
```

#### 3.2 Dry Run Publishing
```bash
# Test publishing without actually publishing
flutter pub publish --dry-run
```

### Step 4: Publish to pub.dev

#### 4.1 Authenticate with pub.dev
```bash
# Login to pub.dev (opens browser)
flutter pub login
```

#### 4.2 Publish Package
```bash
# Publish to pub.dev
flutter pub publish
```

#### 4.3 Confirm Publishing
- Check your email for confirmation
- Package will appear on pub.dev within minutes
- Update will be visible to users after `flutter pub get`

## 📋 Post-Publish Checklist

### ✅ After Publishing

#### 1. **Verify Package on pub.dev**
- Check package page: https://pub.dev/packages/universal_downloader
- Verify all information is correct
- Check that screenshots appear
- Test installation from pub.dev

#### 2. **Update Repository**
```bash
# Create git tag for the release
git tag v1.0.1
git push origin v1.0.1

# Create GitHub release
# Go to GitHub -> Releases -> Create new release
# Tag: v1.0.1
# Title: Universal Downloader v1.0.1
# Description: Copy from CHANGELOG.md
```

#### 3. **Update Documentation**
- Update any external documentation
- Update example apps that use this package
- Check for any broken links

#### 4. **Monitor Issues**
- Watch for GitHub issues
- Monitor pub.dev score
- Respond to user feedback

## 🔧 Troubleshooting Common Issues

### Issue: "Package name already exists"
**Solution:** Choose a different, unique package name

### Issue: "README.md contains invalid markdown"
**Solution:**
```bash
# Check markdown syntax
flutter pub publish --dry-run
# Fix any markdown issues
```

### Issue: "Package score is low"
**Solutions:**
- Add more documentation
- Add tests (aim for >80% coverage)
- Add examples
- Fix linter issues

### Issue: "Platform compatibility issues"
**Solution:**
```bash
# Test on all target platforms
flutter create test_app
cd test_app
flutter pub add universal_downloader
flutter run -d chrome    # Web
flutter run -d linux     # Linux
flutter run -d windows   # Windows (if available)
```

### Issue: "Dependencies not allowed"
**Solution:** Check that all dependencies are published on pub.dev

## 📊 Package Health Score

Aim for these scores on pub.dev:

- **Overall Score**: >80
- **Maintenance**: >80
- **Documentation**: >80
- **Platform Support**: >80

### Improving Scores:

#### Documentation (80+)
- ✅ Comprehensive README
- ✅ API documentation
- ✅ Usage examples
- ✅ Installation guide

#### Maintenance (80+)
- ✅ Recent commit activity
- ✅ Issue response time
- ✅ Version releases

#### Platform Support (80+)
- ✅ Test on multiple platforms
- ✅ Handle platform differences
- ✅ Clear platform requirements

## 🎯 Best Practices

### ✅ Version Management
```yaml
# Use semantic versioning
version: 1.0.1  # major.minor.patch

# Version increments:
# major: Breaking changes
# minor: New features
# patch: Bug fixes
```

### ✅ Changelog Format
```markdown
## [1.0.1] - 2025-09-19
### Added
- New feature description

### Changed
- Modified feature description

### Fixed
- Bug fix description

### Removed
- Removed feature description
```

### ✅ README Best Practices
- Clear, concise description
- Installation instructions
- Basic usage example
- Advanced usage examples
- API documentation
- Platform-specific notes
- Contributing guidelines
- License information

### ✅ Code Quality
- Follow Dart style guide
- Add comprehensive tests
- Use proper error handling
- Document public APIs
- Keep dependencies minimal

## 🚨 Important Notes

### ⚠️ First Time Publishing
- Package name must be unique on pub.dev
- You need a Google account for authentication
- Publishing is permanent (can unpublish but not republish same name)

### ⚠️ Version Conflicts
- Never publish same version twice
- Use `flutter pub publish --force` only for emergencies
- Test thoroughly before publishing

### ⚠️ Breaking Changes
- Use major version bump for breaking changes
- Document breaking changes clearly
- Provide migration guide

## 📞 Support & Community

- **GitHub Issues**: https://github.com/himanshujjp/universal_downloader/issues
- **Pub.dev Page**: https://pub.dev/packages/universal_downloader
- **Documentation**: https://github.com/himanshujjp/universal_downloader#readme

---

## 🎉 Ready to Publish?

Once you've completed all the steps above:

```bash
# Final check
flutter pub publish --dry-run

# If everything looks good
flutter pub publish
```

**Congratulations! Your package is now live on pub.dev! 🎊**

Remember to:
- Monitor the package for issues
- Respond to user feedback
- Plan regular updates and maintenance
- Keep documentation up-to-date
