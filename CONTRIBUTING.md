# Contributing to Prost

Thanks for your interest in contributing! 🍻

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/prost.git`
3. Create a feature branch: `git checkout -b feature/your-feature`

## Development Workflow

### Prerequisites

- PowerShell 7.4+
- Syncthing (for testing)
- PSScriptAnalyzer module (auto-installed by test script)

### Before Committing

Always run the test suite locally:

```bash
pwsh .github/test.ps1
```

This ensures:
- ✅ Code quality (PSScriptAnalyzer)
- ✅ Syntax validity
- ✅ CSV format correctness
- ✅ No obvious security issues

### Code Style

- Follow PowerShell best practices
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and small
- Use `$ErrorActionPreference = "Stop"` for scripts

### Testing Your Changes

If you're modifying:
- **run.ps1** - Test with a local Syncthing setup
- **install.ps1** - Verify systemd service creation
- **Payloads** - Ensure they write to `$global:OutputFolder` correctly

## Pull Request Process

1. Ensure all tests pass (`pwsh .github/test.ps1`)
2. Update README.MD if adding features
3. Commit with descriptive messages (we use [Conventional Commits](https://www.conventionalcommits.org/))
4. Push to your fork
5. Open a Pull Request

### Commit Message Format

We use release-please for automated releases. Follow these formats:

```
feat: Add support for Python payloads
fix: Correct systemd service logging
docs: Update installation instructions
chore: Update dependencies
```

## Questions?

Open an issue! We're happy to help.

---

**Remember:** Prost is for small-scale deployments, not enterprises. Keep it simple!
