# Contributing to Fedora Engineering Setup

Thank you for your interest in contributing! This document provides guidelines for contributing to this repository.

## 🎯 Philosophy

This repository documents a personal engineering workstation setup, but contributions that improve clarity, fix errors, or add valuable insights are welcome.

## 🤝 How to Contribute

### Reporting Issues

If you find errors, broken links, or outdated information:

1. Check if the issue already exists
2. Open a new issue with:
   - Clear title
   - Detailed description
   - Steps to reproduce (if applicable)
   - Your Fedora version and relevant system info

### Suggesting Improvements

For feature suggestions or enhancements:

1. Open a discussion in the Discussions tab
2. Explain the problem and proposed solution
3. Provide examples if possible

### Submitting Pull Requests

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following the style guide
4. **Test** your changes thoroughly
5. **Commit** with clear messages:
   ```bash
   git commit -m "docs: improve Python setup instructions"
   ```
6. **Push** to your fork
7. **Open a Pull Request** with:
   - Clear title
   - Description of changes
   - Related issue number (if applicable)

## ✍️ Style Guide

### Markdown

- Use ATX-style headers (`#` not `===`)
- Include blank lines around headers
- Use backticks for inline code
- Use fenced code blocks with language identifiers
- Keep lines under 120 characters when possible

### Code Examples

- Always include language identifier in code blocks
- Add comments explaining non-obvious commands
- Test all commands before submitting
- Use consistent indentation (2 spaces)

### File Organization

- Keep docs focused on single topics
- Use numbered prefixes for sequential docs (01-, 02-, etc.)
- Include table of contents in longer docs
- Add "Next Steps" section at the end

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature or capability
- `fix:` Bug fix
- `docs:` Documentation changes
- `refactor:` Code restructuring
- `chore:` Maintenance tasks

Examples:
```
docs: add Kafka installation guide
feat: add bootstrap script for automated setup
fix: correct Java path in spark setup
```

## 🔍 Review Process

1. All PRs require review before merging
2. Reviewers will check for:
   - Accuracy of technical information
   - Clarity of documentation
   - Adherence to style guide
   - Working code examples
3. Address feedback in new commits
4. Once approved, PRs will be squashed and merged

## 📜 Code of Conduct

- Be respectful and constructive
- Focus on ideas, not individuals
- Welcome newcomers and beginners
- Assume good intentions

## 🙏 Recognition

Contributors will be acknowledged in the README and release notes.

## ❓ Questions?

Open a discussion or reach out via issues.

---

**Happy Contributing!** 🚀
