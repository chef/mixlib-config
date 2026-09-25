# Copilot Instructions for Mixlib::Config Repository

## Repository Overview

**Mixlib::Config** is a Ruby library that provides a class-based configuration object system used throughout the Chef ecosystem. This repository maintains the core configuration management functionality that allows applications to define and manage configuration options with support for default values, nested contexts, strict mode validation, and multiple file format inputs (Ruby, YAML, JSON, TOML).

### Repository Structure

```
mixlib-config/
├── .expeditor/                   # Expeditor CI/CD configuration
│   ├── config.yml               # Main Expeditor configuration
│   ├── run_linux_tests.sh       # Linux test execution script
│   ├── run_windows_tests.ps1    # Windows test execution script
│   ├── update_version.sh        # Version update automation
│   └── verify.pipeline.yml      # Verification pipeline
├── .github/                     # GitHub configuration and templates
│   ├── CODEOWNERS              # Code ownership definitions
│   ├── ISSUE_TEMPLATE/         # Issue templates
│   ├── dependabot.yml         # Dependency update configuration
│   └── workflows/              # GitHub Actions workflows
│       ├── allchecks.yml
│       ├── ci-main-pull-request-stub-1.0.7.yml
│       ├── dco.yml
│       └── lint.yml
├── features/                    # Cucumber feature tests
│   ├── mixlib_config.feature   # Main feature specifications
│   ├── step_definitions/       # Cucumber step definitions
│   ├── steps/                  # Additional test steps
│   └── support/                # Test support files
├── lib/                        # Main library source code
│   └── mixlib/
│       ├── config.rb           # Main configuration class
│       └── config/             # Configuration modules
│           ├── configurable.rb # Configurable mixin
│           ├── reopened_config_context_with_configurable_error.rb
│           ├── reopened_configurable_with_config_context_error.rb
│           ├── unknown_config_option_error.rb
│           └── version.rb      # Version information
├── spec/                       # RSpec unit tests
│   ├── spec_helper.rb         # RSpec configuration
│   └── mixlib/
│       └── config_spec.rb     # Main configuration tests
├── CHANGELOG.md               # Release notes and changes
├── CODE_OF_CONDUCT.md         # Community guidelines
├── CONTRIBUTING.md            # Contribution guidelines
├── Gemfile                    # Ruby dependencies
├── LICENSE                    # Apache 2.0 license
├── mixlib-config.gemspec      # Gem specification
├── NOTICE                     # Legal notices
├── Rakefile                   # Rake build tasks
├── README.md                  # Project documentation
└── VERSION                    # Current version number
```

## Jira Integration Workflow

When a Jira ID is provided in any task or request:

1. **Use the Atlassian MCP Server** to fetch Jira issue details:
   - Use the `mcp_atlassian-mcp_getJiraIssue` tool to retrieve issue information
   - Use the `mcp_atlassian-mcp_search` tool for Rovo Search when needed
   - Read and understand the story requirements, acceptance criteria, and linked issues

2. **Implementation Process**:
   - Analyze the Jira issue requirements thoroughly
   - Identify affected components and files
   - Plan implementation approach based on story requirements
   - Implement changes following the established patterns in the codebase

## Testing Requirements

### Unit Tests
- Run tests using: `bundle exec rspec` or `rake spec`
- All tests must pass before opening a PR
- All new functionality must include comprehensive unit tests

### Test Structure
- Unit tests are located in `spec/` directory
- Use RSpec testing framework with the existing `spec_helper.rb` configuration
- Follow existing test patterns and naming conventions
- Include both positive and negative test cases
- Test edge cases and error conditions

## Pull Request Creation Workflow

When prompted to create a PR for changes:

1. **Branch Management**:
   ```bash
   # Create branch using Jira ID as branch name
   git checkout -b [JIRA-ID]
   
   # Make your changes and commit with DCO compliance
   git add .
   git commit -s -m "feat: [JIRA-ID] Brief description of changes
   
   Detailed description of what was implemented.
   
   Signed-off-by: Your Name <your.email@example.com>"
   ```

2. **Push and Create PR**:
   ```bash
   # Push changes to the branch
   git push origin [JIRA-ID]
   
   # Create PR using GitHub CLI
   gh pr create --title "[JIRA-ID] Brief description" \
     --body "$(cat <<EOF
   <h2>Summary</h2>
   <p>Brief summary of changes made</p>
   
   <h2>Changes Made</h2>
   <ul>
   <li>Detailed list of changes</li>
   <li>Include all modified components</li>
   </ul>
   
   <h2>Testing</h2>
   <ul>
   <li>Unit tests added/updated</li>
   <li>All tests passing</li>
   </ul>
   
   <h2>Jira Issue</h2>
   <p>Resolves: [JIRA-ID]</p>
   EOF
   )" \
     --base main
   ```

## DCO Compliance Requirements

**All commits must include Developer Certificate of Origin (DCO) compliance:**

1. **Sign all commits** using the `-s` flag:
   ```bash
   git commit -s -m "Your commit message"
   ```

2. **Commit message format**:
   ```
   type: brief description
   
   Detailed explanation of changes made.
   
   Signed-off-by: Your Name <your.email@example.com>
   ```

3. **Retroactive signing** (if needed):
   ```bash
   git rebase --signoff HEAD~N  # N = number of commits to sign
   ```

## Build System Integration

### Expeditor Configuration
This repository uses **Expeditor** as the primary CI/CD system:

- **Configuration**: `.expeditor/config.yml`
- **Automated Actions**:
  - Version bumping (major/minor via labels)
  - Changelog updates
  - Gem building and publishing
  - Branch cleanup after merge

### GitHub Workflows
- **Main CI Pipeline**: `.github/workflows/ci-main-pull-request-stub-1.0.7.yml`
- **Triggered on**: Pull requests and pushes to `main` and `release/**` branches
- **Includes**:
  - Complexity checks
  - TruffleHog secret scanning
  - Trivy vulnerability scanning
  - SonarQube analysis
  - SBOM generation and BlackDuck SCA (on pushes to `main`)
- **Lint** (`lint.yml`): Cookstyle, cspell spellcheck, and trailing newline checks
- **DCO** (`dco.yml`): Checks every commit is signed off

### Available Labels for PR Management

**Expeditor Labels**:
- `Expeditor: Bump Version Major` - Triggers major version bump
- `Expeditor: Bump Version Minor` - Triggers minor version bump
- `Expeditor: Skip All` - Skips all merge actions
- `Expeditor: Skip Changelog` - Skips changelog updates
- `Expeditor: Skip Version Bump` - Skips version bumping

**Aspect Labels**:
- `Aspect: Documentation` - Documentation changes
- `Aspect: Integration` - Integration-related changes
- `Aspect: Packaging` - Distribution and packaging
- `Aspect: Performance` - Performance improvements
- `Aspect: Portability` - Platform compatibility
- `Aspect: Security` - Security-related changes
- `Aspect: Stability` - Stability improvements
- `Aspect: Testing` - Test coverage and CI changes
- `Aspect: UI` - User interface changes
- `Aspect: UX` - User experience improvements

**Platform Labels**:
- `Platform: AWS`, `Platform: Azure`, `Platform: GCP` - Cloud platforms
- `Platform: Linux`, `Platform: macOS` - Operating systems
- `Platform: Docker` - Container-related changes
- `Platform: Debian-like`, `Platform: RHEL-like`, `Platform: SLES-like` - Distribution-specific

**Other Labels**:
- `dependencies` - Dependency updates
- `hacktoberfest-accepted` - Hacktoberfest contributions
- `oss-standards` - OSS standardization efforts

## Complete Implementation Workflow

### Phase 1: Analysis and Planning
1. **Receive Jira ID and task requirements**
2. **Fetch Jira issue using Atlassian MCP Server**:
   ```
   Use mcp_atlassian-mcp_getJiraIssue with the provided issue ID
   Read story description, acceptance criteria, and linked issues
   ```
3. **Analyze codebase impact**:
   - Identify files that need modification
   - Understand existing patterns and conventions
   - Plan implementation approach
4. **Create implementation plan and confirm next steps**

**Prompt**: "I have analyzed the Jira issue [JIRA-ID] and identified the following implementation requirements: [summary]. The plan includes: [detailed steps]. Shall I proceed with the implementation?"

### Phase 2: Implementation
1. **Create feature branch**:
   ```bash
   git checkout -b [JIRA-ID]
   ```
2. **Implement changes following established patterns**
3. **Write comprehensive unit tests** for the new behavior
4. **Update documentation** if needed
5. **Run local tests** to verify implementation

**Prompt**: "Implementation completed for [JIRA-ID]. Added/modified: [list of changes]. All tests passing. Ready to proceed with PR creation?"

### Phase 3: Testing and Validation
1. **Run full test suite**:
   ```bash
   bundle exec rake
   ```
   This runs both `style` (Cookstyle) and `spec` (RSpec).
2. **Validate DCO compliance on all commits**

**Prompt**: "Testing phase completed. All tests passing: [yes/no]. Any issues found: [list or none]. Ready to create PR?"

### Phase 4: PR Creation and Submission
1. **Commit changes with proper DCO signing**
2. **Push branch to remote repository**
3. **Create PR using GitHub CLI with HTML-formatted description**
4. **Apply appropriate labels based on change type**
5. **Link to original Jira issue**

**Prompt**: "PR created successfully: [PR URL]. Applied labels: [list]. Linked to Jira issue: [JIRA-ID]. The PR is ready for review. Would you like me to make any additional changes or proceed with other tasks?"

## Prompt-Based Task Management

### After Each Step
Always provide a summary and next step prompt:

**Example Format**:
```
✅ **Step [X] Completed**: [Brief description of what was accomplished]

📋 **Summary**: [Detailed summary of progress and current state]

🔄 **Next Step**: [Clear description of the next planned action]

📝 **Remaining Steps**: 
- [ ] Step 1
- [ ] Step 2
- [x] Completed Step

❓ **Continue?**: Would you like me to proceed with [next step description]?
```

### Confirmation Points
Always ask for confirmation before:
- Starting implementation
- Creating branches
- Making commits
- Creating PRs
- Making significant changes to the codebase

## Code Quality Guidelines

### Ruby Style Guide
- Follow existing code style and patterns in the repository
- Use Ruby 3.1+ compatible syntax (minimum supported version)
- Maintain consistent indentation and formatting
- Follow Ruby naming conventions

### Configuration Library Patterns
- Extend existing configuration patterns when adding new features
- Maintain backward compatibility
- Support all existing configuration formats (Ruby, YAML, JSON, TOML)
- Preserve strict mode functionality
- Follow existing default value patterns

### Error Handling
- Use existing error classes in `lib/mixlib/config/`
- Provide clear, actionable error messages
- Handle edge cases gracefully
- Maintain existing error behavior for backward compatibility

### Documentation Requirements
- Update README.md for user-facing features
- Add inline code documentation for complex logic
- Update CHANGELOG.md following existing format
- Maintain API documentation consistency

## Security and Compliance

### Security Considerations
- No hardcoded secrets or credentials
- Validate user input appropriately
- Follow secure coding practices
- Consider injection and parsing vulnerabilities

### License Compliance
- All code must be Apache 2.0 compatible
- Include proper license headers where required
- Respect third-party dependencies' licenses
- Update NOTICE file if adding new dependencies

## AI-Assisted Development & Compliance

- ✅ Create PR with `ai-assisted` label (if label doesn't exist, create it with description "Work completed with AI assistance following Progress AI policies" and color "9A4DFF")
- ✅ Include "This work was completed with AI assistance following Progress AI policies" in PR description

### Jira Ticket Updates (MANDATORY)

- ✅ **IMMEDIATELY after PR creation**: Update Jira ticket custom field `customfield_11170` ("Does this Work Include AI Assisted Code?") to "Yes"
- ✅ Use atlassian-mcp tools to update the Jira field programmatically
- ✅ **CRITICAL**: Use correct field format: `{"customfield_11170": {"value": "Yes"}}`
- ✅ Verify the field update was successful

### Documentation Requirements

- ✅ Reference AI assistance in commit messages where appropriate
- ✅ Document any AI-generated code patterns or approaches in PR description
- ✅ Maintain transparency about which parts were AI-assisted vs manual implementation

### Workflow Integration

This AI compliance checklist should be integrated into the main development workflow Step 4 (Pull Request Creation):

```
Step 4: Pull Request Creation & AI Compliance
- Step 4.1: Create branch and commit changes WITH SIGNED-OFF COMMITS
- Step 4.2: Push changes to remote
- Step 4.3: Create PR with ai-assisted label
- Step 4.4: IMMEDIATELY update Jira customfield_11170 to "Yes"
- Step 4.5: Verify both PR labels and Jira field are properly set
- Step 4.6: Provide complete summary including AI compliance confirmation
```

- **Never skip Jira field updates** - This is required for Progress AI governance
- **Always verify updates succeeded** - Check response from atlassian-mcp tools
- **Treat as atomic operation** - PR creation and Jira updates should happen together
- **Double-check before final summary** - Confirm all AI compliance items are completed

### Audit Trail

All AI-assisted work must be traceable through:

1. GitHub PR labels (`ai-assisted`)
2. Jira custom field (`customfield_11170` = "Yes")
3. PR descriptions mentioning AI assistance
4. Commit messages where relevant

---

This comprehensive guide ensures consistent, high-quality contributions to the mixlib-config repository while maintaining all necessary compliance and quality standards.
