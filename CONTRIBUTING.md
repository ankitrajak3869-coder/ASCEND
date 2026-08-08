# Contributing to Ascend

Thank you for your interest in contributing to Ascend! This document outlines the guidelines and processes for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Branch Naming Convention](#branch-naming-convention)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)
- [Code Review Rules](#code-review-rules)
- [Development Workflow](#development-workflow)
- [Testing Requirements](#testing-requirements)

---

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/ascend.git
   cd ascend
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_ORG/ascend.git
   ```
4. **Install dependencies**:
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```
5. **Create a feature branch** (see [Branch Naming Convention](#branch-naming-convention))

---

## Branch Naming Convention

We use a structured branch naming convention to keep the repository organized.

### Format

```
<type>/<short-description>
```

### Types

| Type | Description | Example |
|------|-------------|---------|
| `feature/` | New feature or enhancement | `feature/user-profile-screen` |
| `bugfix/` | Bug fix | `bugfix/login-crash-on-empty-email` |
| `hotfix/` | Critical production fix | `hotfix/security-token-leak` |
| `release/` | Release preparation | `release/v1.2.0` |
| `docs/` | Documentation only | `docs/update-readme-architecture` |
| `refactor/` | Code refactoring | `refactor/auth-repository-impl` |
| `test/` | Adding/updating tests | `test/add-auth-usecase-tests` |
| `chore/` | Maintenance tasks | `chore/update-dependencies` |
| `ci/` | CI/CD changes | `ci/add-android-build-workflow` |

### Rules

- Use **kebab-case** for descriptions
- Keep descriptions **short but descriptive** (max 50 chars)
- Reference **issue number** when applicable: `feature/123-add-dark-mode`
- **Never commit directly** to `main` or `develop`

---

## Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Code style (formatting, missing semicolons, etc.) |
| `refactor` | Code refactoring (no behavior change) |
| `perf` | Performance improvement |
| `test` | Adding/updating tests |
| `chore` | Maintenance (dependencies, build config, etc.) |
| `ci` | CI/CD changes |
| `build` | Build system changes |
| `revert` | Revert a previous commit |

### Examples

```bash
# Feature
git commit -m "feat(auth): add biometric authentication support"

# Bug fix with issue reference
git commit -m "fix(login): resolve crash on empty password field

Closes #123"

# Breaking change
git commit -m "feat(api): migrate to v2 endpoints

BREAKING CHANGE: Authentication now requires OAuth2 tokens"

# Documentation
git commit -m "docs: update architecture decision records"

# Refactor
git commit -m "refactor(core): extract network layer to separate package"
```

### Rules

- **First line**: Max 72 characters
- **Body**: Wrap at 72 characters, explain *what* and *why*, not *how*
- **Footer**: Reference issues, breaking changes
- **Scope**: Optional but recommended (feature/module name)
- **No period** at end of subject line

---

## Pull Request Process

### Before Opening a PR

1. **Sync with upstream**:
   ```bash
   git fetch upstream
   git rebase upstream/develop
   ```

2. **Run all checks locally**:
   ```bash
   flutter analyze
   dart format --set-exit-if-changed .
   flutter test
   dart run dart_code_metrics:metrics analyze lib
   ```

3. **Ensure tests pass** and coverage doesn't decrease significantly

4. **Update documentation** if needed (README, ARCHITECTURE.md, CHANGELOG.md)

### PR Requirements

| Requirement | Details |
|-------------|---------|
| **Title** | Follow commit convention: `feat(auth): add biometric login` |
| **Description** | Clear description of changes, motivation, and testing done |
| **Linked Issues** | Reference related issues: `Closes #123`, `Relates to #456` |
| **Labels** | Add appropriate labels (feature, bugfix, docs, etc.) |
| **Reviewers** | Request 2+ reviewers |
| **Checks** | All CI checks must pass |

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Refactor
- [ ] Test update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] All CI checks pass
```

### Review Process

1. **Automated checks** run (analyze, test, format, metrics)
2. **Code review** by 2+ team members
3. **Address feedback** - push new commits (don't force push after review starts)
4. **Approval** - Requires 2 approvals
5. **Merge** - Squash and merge to `develop`

---

## Code Review Rules

### For Authors

- **Keep PRs small** - Ideally < 400 lines changed
- **Self-review first** - Check your own code before requesting review
- **Write clear descriptions** - Explain the *why*, not just the *what*
- **Respond promptly** - Address feedback within 24 hours
- **Don't take it personally** - Reviews are about code quality

### For Reviewers

- **Be constructive** - Suggest improvements, don't just criticize
- **Focus on important issues**:
  - Correctness & bugs
  - Security vulnerabilities
  - Performance issues
  - Architecture violations
  - Test coverage
- **Nitpick sparingly** - Use "nit:" prefix for minor suggestions
- **Approve only when confident** - You share responsibility for merged code

### Review Checklist

- [ ] Code solves the stated problem
- [ ] Follows Clean Architecture principles
- [ ] Proper error handling (Failures, not exceptions)
- [ ] No hardcoded values (use constants/config)
- [ ] Tests cover new functionality
- [ ] No debug prints or commented code
- [ ] Proper naming conventions
- [ ] Documentation updated
- [ ] No security issues (secrets, PII logging)

---

## Development Workflow

### Feature Development

```bash
# 1. Start from develop
git checkout develop
git pull upstream develop

# 2. Create feature branch
git checkout -b feature/your-feature-name

# 3. Develop with frequent commits
git add .
git commit -m "feat(scope): descriptive message"

# 4. Push and create PR
git push origin feature/your-feature-name
# Open PR on GitHub targeting 'develop'
```

### Hotfix Process

```bash
# 1. Create from main
git checkout main
git pull upstream main
git checkout -b hotfix/critical-fix

# 2. Fix and test thoroughly
# 3. Create PR targeting 'main'
# 4. After merge, backport to develop
git checkout develop
git pull upstream develop
git merge main
```

---

## Testing Requirements

### Minimum Coverage

- **Unit tests**: 80%+ coverage for domain layer
- **Widget tests**: Key UI interactions
- **Integration tests**: Critical user flows

### Test Structure

```
test/
├── unit/
│   ├── domain/
│   │   └── usecases/
│   └── data/
│       └── repositories/
├── widget/
│   └── features/
└── integration/
    └── app_test.dart
```

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/unit/domain/usecases/auth_usecase_test.dart

# With coverage
flutter test --coverage
```

---

## Questions?

- Open a [GitHub Discussion](https://github.com/your-org/ascend/discussions)
- Check existing [Issues](https://github.com/your-org/ascend/issues)
- Review [Architecture Docs](ARCHITECTURE.md)

---

*Thank you for contributing to Ascend!* 🚀