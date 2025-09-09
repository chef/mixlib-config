# Copilot Instructions for mixlib-config

## Repository Overview

**Repository**: mixlib-config  
**Owner**: chef  
**Current Branch**: main  
**Project Type**: Ruby Gem - Configuration Management Library  

This is a Ruby gem that provides a class-based configuration object system, used extensively in Chef and other Ruby applications. It supports various configuration formats (Ruby DSL, YAML, JSON, TOML) and advanced features like nested contexts, strict mode, and default value blocks.

## Repository Structure

```
mixlib-config/
├── .expeditor/                    # Chef Expeditor configuration
├── .github/                       # GitHub workflows and templates
│   ├── CODEOWNERS                 # Code ownership definitions
│   ├── ISSUE_TEMPLATE/            # Issue templates
│   ├── dependabot.yml            # Dependabot configuration
│   ├── workflows/                 # GitHub Actions workflows
│   └── copilot-instructions.md    # This file
├── features/                      # Cucumber feature tests
│   ├── mixlib_config.feature      # Main feature file
│   ├── step_definitions/          # Cucumber step definitions
│   │   └── mixlib_config_steps.rb
│   ├── steps/                     # Additional step files
│   │   └── config_steps.rb
│   └── support/                   # Test support files
│       ├── bobo.config            # Test configuration file
│       ├── config_it.rb           # Test configuration class
│       └── env.rb                 # Test environment setup
├── lib/                           # Main library code
│   └── mixlib/
│       ├── config.rb              # Main configuration module
│       └── config/                # Configuration submodules
│           ├── configurable.rb    # Configurable option handling
│           ├── reopened_config_context_with_configurable_error.rb
│           ├── reopened_configurable_with_config_context_error.rb
│           ├── unknown_config_option_error.rb
│           └── version.rb         # Version information
├── spec/                          # RSpec test files
│   ├── spec_helper.rb             # RSpec configuration
│   └── mixlib/
│       └── config_spec.rb         # Main configuration tests
├── CHANGELOG.md                   # Version history
├── CODE_OF_CONDUCT.md            # Community guidelines
├── CONTRIBUTING.md               # Contribution guidelines
├── Gemfile                       # Bundler dependencies
├── LICENSE                       # Apache 2.0 license
├── mixlib-config.gemspec         # Gem specification
├── NOTICE                        # Legal notices
├── Rakefile                      # Rake tasks (test, style, docs)
├── README.md                     # Project documentation
└── VERSION                       # Version file
```

## Critical File Modification Rules

- **DO NOT MODIFY**: Any `*.codegen.go` files (if present in future)
- **PRESERVE**: Existing test structure and format
- **MAINTAIN**: Ruby coding standards and Chef style guidelines
- **RESPECT**: Semantic versioning in VERSION file

## Core Development Workflow

### 1. Jira Integration Workflow

When a Jira ID is provided:

1. **Fetch Jira Details**: Use the `atlassian-mcp-server` MCP server to fetch the Jira issue details
2. **Read Story**: Carefully analyze the Jira story, acceptance criteria, and requirements
3. **Plan Implementation**: Break down the task into implementable components
4. **Implement**: Follow the standard development workflow below

### 2. Standard Development Workflow

#### Phase 1: Analysis and Planning
- **Analyze Requirements**: Understand the task thoroughly
- **Review Codebase**: Examine existing code patterns and architecture
- **Plan Changes**: Identify files to modify and approach to take
- **Summary**: Provide clear summary of planned changes
- **Prompt**: "Next step: Implementation phase. Ready to proceed? (y/n)"

#### Phase 2: Implementation
- **Core Changes**: Implement the main functionality
- **Follow Patterns**: Use existing code patterns and conventions
- **Ruby Standards**: Follow Ruby best practices and Chef style guidelines
- **Summary**: Describe implementation completed
- **Prompt**: "Next step: Test creation phase. Ready to proceed? (y/n)"

#### Phase 3: Test Creation
- **Unit Tests**: Create comprehensive unit tests using RSpec
- **Coverage Target**: Ensure test coverage remains > 80%
- **Test Patterns**: Follow existing test structure in `spec/` directory
- **Feature Tests**: Add Cucumber feature tests if needed in `features/` directory
- **Summary**: Describe tests created and coverage achieved
- **Prompt**: "Next step: Code quality verification. Ready to proceed? (y/n)"

#### Phase 4: Code Quality Verification
- **Run Tests**: Execute `bundle exec rake spec` to run all tests
- **Style Check**: Execute `bundle exec rake style` for code style verification
- **Fix Issues**: Address any failing tests or style violations
- **Summary**: Report on test results and code quality status
- **Prompt**: "Next step: Documentation update (if needed). Ready to proceed? (y/n)"

#### Phase 5: Documentation (if needed)
- **Update README**: Modify README.md if new features are added
- **Update CHANGELOG**: Add entry to CHANGELOG.md following existing format
- **Code Comments**: Add/update inline documentation as needed
- **Summary**: Describe documentation updates made
- **Prompt**: "Next step: Git operations and PR creation. Ready to proceed? (y/n)"

#### Phase 6: Git Operations and PR Creation
- **Branch Creation**: Create feature branch using Jira ID as branch name (if provided)
- **Commit Changes**: Make logical, well-described commits
- **Push Branch**: Push the feature branch to remote repository
- **Create PR**: Use GitHub CLI to create pull request with proper description
- **Add Label**: Add "runtest:all:stable" label to the PR
- **Summary**: Provide PR details and next steps

### 3. Git and GitHub Operations

#### Branch Management
```bash
# Create and switch to feature branch (use Jira ID if provided)
git checkout -b [JIRA-ID or feature-name]

# Make commits with descriptive messages
git add .
git commit -m "feat: implement [feature description]"

# Push branch to remote
git push origin [branch-name]
```

#### PR Creation with GitHub CLI
```bash
# Authenticate (no profile needed)
gh auth login

# Create PR with HTML-formatted description
gh pr create \
  --title "[JIRA-ID] Brief description of changes" \
  --body "<h2>Summary</h2>
<p>Brief description of what was implemented.</p>

<h2>Changes Made</h2>
<ul>
<li>List of key changes</li>
<li>Files modified</li>
</ul>

<h2>Testing</h2>
<ul>
<li>Test coverage maintained > 80%</li>
<li>All existing tests pass</li>
<li>New tests added for new functionality</li>
</ul>

<h2>Jira</h2>
<p>Related to: [JIRA-ID]</p>" \
  --assignee @me

# Add required label
gh pr edit --add-label "runtest:all:stable"
```

## Testing Requirements

### Test Coverage Standards
- **Minimum Coverage**: 80% test coverage required
- **Test Types**: Unit tests (RSpec) and integration tests (Cucumber)
- **Test Files**: Place RSpec tests in `spec/` directory matching file structure
- **Feature Tests**: Place Cucumber tests in `features/` directory when needed

### Test Execution
```bash
# Run all tests
bundle exec rake spec

# Run style checks
bundle exec rake style

# Run all quality checks
bundle exec rake
```

### Test Structure Guidelines
- Follow existing test patterns in `spec/mixlib/config_spec.rb`
- Use descriptive test names and contexts
- Test both positive and negative cases
- Mock external dependencies appropriately
- Verify error conditions and edge cases

## Code Quality Standards

### Ruby Style Guidelines
- Follow Chef's cookstyle/chefstyle guidelines
- Use RuboCop configuration in `.rubocop.yml`
- Maintain existing code formatting and patterns
- Follow semantic versioning for VERSION changes

### Code Organization
- **Main Module**: `Mixlib::Config` in `lib/mixlib/config.rb`
- **Submodules**: Place related classes in `lib/mixlib/config/` directory
- **Error Classes**: Custom errors go in `lib/mixlib/config/` directory
- **Tests**: Mirror library structure in `spec/` directory

## Key Configuration Features

### Core Functionality
- **Configuration DSL**: Method-based and hash-based configuration setting
- **File Loading**: Support for Ruby, YAML, JSON, and TOML configuration files
- **Default Values**: Support for static defaults and dynamic default blocks
- **Strict Mode**: Optional strict mode for catching configuration errors

### Advanced Features
- **Nested Contexts**: `config_context` for grouped configuration options
- **Context Lists**: `config_context_list` for arrays of configuration contexts
- **Context Hashes**: `config_context_hash` for keyed configuration contexts
- **Value Validation**: Custom validation and transformation support

## Prompt-Based Development

### Interactive Development Approach
- All tasks must be performed in a prompt-based manner
- After each phase, provide a clear summary of what was completed
- Always prompt for permission before proceeding to the next step
- Allow user to review and approve each phase before continuing
- Be transparent about what will happen in the next step

### Summary Format
Each phase summary should include:
- What was accomplished in the current phase
- Any issues encountered and how they were resolved
- Current status of the implementation
- Clear description of the next step

### Continuation Prompts
- Always ask "Ready to proceed with [next step]? (y/n)" before continuing
- Wait for user confirmation before proceeding
- Allow users to skip steps or modify the workflow as needed
- Provide clear options for what can be done next

## Error Handling and Edge Cases

### Common Issues
- **Configuration Conflicts**: Handle conflicts between different configuration methods
- **Type Validation**: Ensure proper type checking for configuration values
- **Backward Compatibility**: Maintain compatibility with existing configuration usage
- **Error Messages**: Provide clear, actionable error messages

### Testing Edge Cases
- Invalid configuration formats
- Missing required configuration values
- Conflicting configuration sources
- Large configuration files and performance
- Thread safety considerations

## Documentation Standards

### Code Documentation
- Use YARD-style documentation comments
- Document public API methods clearly
- Include usage examples in documentation
- Maintain existing documentation style

### README Updates
- Update feature descriptions for new functionality
- Add usage examples for new features
- Maintain existing formatting and structure
- Update version compatibility information

This comprehensive guide ensures consistent, high-quality development practices for the mixlib-config repository while maintaining the existing codebase standards and patterns.
