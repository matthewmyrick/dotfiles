# 📋 Task Management Documentation

Intelligent TaskWarrior configuration with custom hooks that enforce project organization and due date management. This setup transforms TaskWarrior into a powerful productivity system with automated workflow enforcement.

## 🎯 Overview

The task management system provides:
- **🔒 Enforced project assignment** for all tasks
- **📅 Mandatory due dates** to prevent task drift  
- **⚡ Automated workflows** through intelligent hooks
- **🎯 Project-based organization** for better focus
- **🔄 Smart task lifecycle** management

## 📁 Structure

```
task/
└── hooks/                          # TaskWarrior hooks directory
    ├── on-add.require-project-due.sh    # Hook for new task validation
    └── on-modify.require-project-due.sh # Hook for task modification validation
```

## 🚀 Installation

The task management configuration is automatically installed via the main install script:

```bash
./install.sh
```

Or manually:

```bash
# Remove existing hooks
rm -rf ~/.task/hooks

# Create hooks directory
mkdir -p ~/.task/hooks

# Copy and make hooks executable
cp task/hooks/*.sh ~/.task/hooks/
for hook in ~/.task/hooks/*.sh; do
  hook_name=$(basename "$hook" .sh)
  mv "$hook" ~/.task/hooks/$hook_name"
  chmod +x ~/.task/hooks/$hook_name"
done
```

## ⚙️ Hook System

### Hook Types

TaskWarrior supports various hook types that execute at different lifecycle stages:
- **on-add**: Executes when a new task is created
- **on-modify**: Executes when a task is modified
- **on-exit**: Executes when TaskWarrior exits
- **on-launch**: Executes when TaskWarrior launches

### Active Hooks

#### 1. New Task Validation (`on-add.require-project-due.sh`)

**Purpose**: Ensures all new tasks have both a project assignment and due date

**Triggers**: Every time a new task is added with `task add`

**Validation Rules**:
- ✅ **Project Required**: Task must have a project assigned
- ✅ **Due Date Required**: Task must have a due date set
- ❌ **Blocks creation** if either requirement is missing

**Example Usage**:
```bash
# ❌ This will fail
task add "Fix the bug"
# Error: Task must have a project assigned

# ❌ This will also fail  
task add "Fix the bug" project:coding
# Error: Task must have a due date

# ✅ This will succeed
task add "Fix the bug" project:coding due:tomorrow
# Task added successfully
```

#### 2. Task Modification Validation (`on-modify.require-project-due.sh`)

**Purpose**: Maintains project and due date requirements when tasks are modified

**Triggers**: Every time a task is modified with `task modify`

**Validation Rules**:
- ✅ **Project Preservation**: Cannot remove project from existing tasks
- ✅ **Due Date Preservation**: Cannot remove due date from existing tasks
- ✅ **New Requirements**: Any modifications that would remove required fields are blocked

**Example Usage**:
```bash
# ✅ Allowed modifications
task 1 modify priority:H
task 1 modify project:urgent-coding due:today

# ❌ These will fail
task 1 modify project:
# Error: Cannot remove project from task

task 1 modify due:
# Error: Cannot remove due date from task
```

## 🔧 Hook Implementation Details

### Hook Architecture

Each hook is implemented as a shell script that:
1. **Reads task data** from stdin (JSON format)
2. **Validates requirements** against business rules
3. **Returns appropriate exit code**:
   - `0` = Success (allow operation)  
   - `1` = Failure (block operation)
4. **Outputs error messages** to stderr for user feedback

### JSON Processing

TaskWarrior passes task data as JSON to hooks:

```json
{
  "id": 1,
  "description": "Fix the bug",
  "project": "coding",
  "due": "20241225T120000Z",
  "status": "pending",
  "entry": "20241220T100000Z"
}
```

### Error Handling

Hooks provide clear, actionable error messages:

```bash
# When project is missing
echo "Error: Task must have a project assigned." >&2
echo "Usage: task add 'description' project:project_name due:date" >&2

# When due date is missing
echo "Error: Task must have a due date." >&2
echo "Usage: task add 'description' project:project_name due:tomorrow" >&2
```

## 📊 Workflow Integration

### Project-Based Organization

The hook system enforces a project-based workflow:

```bash
# Personal projects
task add "Review investment portfolio" project:personal due:weekend
task add "Plan vacation" project:personal due:next_month

# Work projects  
task add "Complete code review" project:development due:tomorrow
task add "Update documentation" project:documentation due:friday

# Learning projects
task add "Finish Rust tutorial" project:learning due:next_week
task add "Practice algorithms" project:learning due:daily
```

### Due Date Management

All tasks must have realistic, actionable due dates:

```bash
# Specific dates
task add "Submit report" project:work due:2024-12-25

# Relative dates  
task add "Review code" project:development due:tomorrow
task add "Plan sprint" project:management due:monday
task add "Backup files" project:maintenance due:weekly
```

### Common Project Categories

Suggested project organization:
- **work**: Professional tasks and responsibilities
- **personal**: Personal life and self-care
- **learning**: Education and skill development  
- **maintenance**: System and environment upkeep
- **health**: Health and fitness goals
- **finance**: Financial planning and management
- **creative**: Creative projects and hobbies

## 🎯 Usage Examples

### Daily Workflow

```bash
# Morning planning
task add "Review email" project:work due:9am
task add "Team standup" project:work due:10am  
task add "Code feature X" project:development due:eod

# Personal tasks
task add "Grocery shopping" project:personal due:evening
task add "Exercise" project:health due:6pm

# Learning goals
task add "Read tech article" project:learning due:tonight
```

### Project Management

```bash
# View tasks by project
task project:work list
task project:personal list

# Project-specific reports
task project:development burndown
task project:learning summary

# Cross-project prioritization
task +ACTIVE list
task due:today list
```

### Advanced Task Creation

```bash
# Complex task with multiple attributes
task add "Implement user authentication" \
  project:development \
  due:friday \
  priority:H \
  tags:backend,security \
  estimate:4h

# Recurring tasks
task add "Weekly team sync" \
  project:work \
  due:monday \
  recur:weekly

# Task with dependencies
task add "Deploy to production" \
  project:development \
  due:next_friday \
  depends:1,2,3
```

## 🔍 Troubleshooting

### Hook Execution Issues

**Problem**: Hooks not executing
```bash
# Check hook permissions
ls -la ~/.task/hooks/

# Make hooks executable
chmod +x ~/.task/hooks/*

# Test hook manually
echo '{"description":"test"}' | ~/.task/hooks/on-add
```

**Problem**: Hook errors are unclear
```bash
# Enable TaskWarrior debugging
export TASKRC=~/.taskrc
export TASKDATA=~/.task
task rc.debug=on add "test task"
```

### Validation Bypassing

**Problem**: Need to create task without project/due date temporarily
```bash
# Use environment variable to bypass validation
BYPASS_VALIDATION=true task add "Emergency task"

# Or disable hooks temporarily
task rc.hooks=off add "Temporary task"
```

### Hook Conflicts

**Problem**: Multiple hooks interfering
```bash
# Test hooks individually
mv ~/.task/hooks/on-modify ~/.task/hooks/on-modify.disabled
task modify 1 description:"test"

# Check hook execution order
ls -la ~/.task/hooks/ | grep on-
```

## 🔧 Customization

### Modifying Validation Rules

Edit hook scripts to adjust requirements:

```bash
# Allow tasks without due dates for certain projects
if [[ "$project" == "someday" ]]; then
  # Skip due date requirement
  exit 0
fi
```

### Adding New Validations

Create additional hooks:

```bash
# ~/.task/hooks/on-add.require-tags
#!/bin/bash
# Require tags for work projects

task_json=$(cat)
project=$(echo "$task_json" | jq -r '.project // empty')
tags=$(echo "$task_json" | jq -r '.tags // empty')

if [[ "$project" == "work" ]] && [[ -z "$tags" ]]; then
  echo "Error: Work tasks must have tags." >&2
  exit 1
fi

exit 0
```

### Environment-Specific Rules

```bash
# Different rules for different environments
if [[ $(hostname) == "work-laptop" ]]; then
  # Stricter validation for work environment
  require_estimate=true
else  
  # Relaxed rules for personal use
  require_estimate=false
fi
```

### Integration with External Tools

```bash
# Notify external systems when tasks are added
if [[ "$project" == "urgent" ]]; then
  # Send notification to Slack, email, etc.
  curl -X POST "$SLACK_WEBHOOK" -d '{"text":"Urgent task added"}'
fi
```

## 📈 Advanced Features

### Hook Chaining

Multiple hooks can work together:

```bash
# Hook execution order (alphabetical)
on-add.10-validate-project-due
on-add.20-send-notifications  
on-add.30-update-external-systems
```

### Conditional Logic

Hooks can have sophisticated logic:

```bash
# Different rules based on task attributes
case "$project" in
  "urgent"|"critical")
    # Require immediate due dates
    ;;
  "someday"|"maybe")  
    # Allow distant due dates
    ;;
  *)
    # Default validation
    ;;
esac
```

### Data Enrichment

Hooks can add data to tasks:

```bash
# Auto-assign based on project
if [[ "$project" == "development" ]]; then
  # Add development-specific tags
  task modify "$id" +coding +technical
fi
```

## 📊 Performance Considerations

### Hook Efficiency

- **Keep hooks lightweight** - they run on every task operation
- **Cache external calls** when possible
- **Use efficient JSON processing** (jq is recommended)
- **Minimize external dependencies**

### Debugging Performance

```bash
# Time hook execution
time task add "test" project:test due:tomorrow

# Profile hook execution
TASKRC_DEBUG=on task add "test" project:test due:tomorrow
```

## 🎯 Benefits & Results

### Productivity Improvements
- **100% project assignment** ensures no orphaned tasks
- **Deadline awareness** prevents task drift and procrastination
- **Structured workflow** improves focus and prioritization
- **Automated enforcement** reduces cognitive load

### Data Quality
- **Consistent categorization** enables better reporting
- **Complete metadata** allows for advanced filtering and analysis
- **Enforced standards** improve team collaboration
- **Historical tracking** provides insights into productivity patterns

This task management system transforms TaskWarrior from a simple to-do list into a powerful productivity framework that enforces best practices and maintains high data quality through intelligent automation.