"""
ptpython startup script
Automatically loaded when ptpython starts
"""

import subprocess
import os
from pathlib import Path


def sh(command):
    """Run a shell command in current directory."""
    result = subprocess.run(
        command,
        shell=True,
        capture_output=True,
        text=True
    )
    if result.stdout:
        print(result.stdout, end='')
    if result.stderr:
        print(result.stderr, end='')
    return result.returncode


class DirNode:
    def __init__(self, path):
        self.path = path.resolve()  # Use absolute path
        self.name = path.name
        self.children = []
        self.files = []

    def __repr__(self):
        return f"DirNode({self.name})"

    def run_cmd(self, command):
        """Run a command in this directory"""
        result = subprocess.run(
            command,
            shell=True,
            cwd=self.path,
            capture_output=True,
            text=True
        )
        if result.stdout:
            print(result.stdout, end='')
        if result.stderr:
            print(result.stderr, end='')
        return result.returncode


def build_tree(path):
    """Build a tree structure of directories from the given path."""
    node = DirNode(path)
    for child in sorted(path.iterdir()):
        if child.name.startswith('.'):
            continue
        if child.is_dir():
            node.children.append(build_tree(child))
        elif child.is_file():
            node.files.append(child.name)
    return node


def find_node(node, name):
    """Find a node by name in the tree. Errors if multiple matches found."""
    matches = []

    def _search(n):
        if n.name == name:
            matches.append(n)
        for child in n.children:
            _search(child)

    _search(node)

    if len(matches) > 1:
        paths = [str(m.path) for m in matches]
        raise ValueError(f"Multiple nodes named '{name}' found:\n  " + "\n  ".join(paths))

    return matches[0] if matches else None


def print_tree(node, indent=0):
    """Print the tree structure."""
    print("  " * indent + node.name)
    for child in node.children:
        print_tree(child, indent + 1)


def list_all(node):
    """List all node names in the tree."""
    names = [node.name]
    for child in node.children:
        names.extend(list_all(child))
    return names


# Create default root from current directory
root = build_tree(Path('.'))


def refresh(path=None):
    """Rebuild the root tree from current or specified directory."""
    global root
    if path:
        root = build_tree(Path(path))
    else:
        root = build_tree(root.path)  # Use existing root path
    print(f"Refreshed: {len(list_all(root))} directories")
    return root


def cd(path):
    """Change root to a different directory."""
    global root
    new_path = Path(path).resolve()
    if not new_path.exists():
        print(f"Error: {path} does not exist")
        return None
    if not new_path.is_dir():
        print(f"Error: {path} is not a directory")
        return None
    root = build_tree(new_path)
    print(f"Changed to: {root.path}")
    print(f"Loaded: {len(list_all(root))} directories, {len(root.files)} files")
    return root


def find_file(node, filename):
    """Find a file by name in the tree."""
    matches = []

    def _search(n):
        if filename in n.files:
            matches.append(n)
        for child in n.children:
            _search(child)

    _search(node)

    if len(matches) > 1:
        paths = [str(m.path / filename) for m in matches]
        raise ValueError(f"Multiple files named '{filename}' found:\n  " + "\n  ".join(paths))

    return (matches[0], filename) if matches else None


def run_in_all(node, command):
    """Run a command in all directories in the tree."""
    results = []

    def _run(n):
        print(f"\n=== {n.path} ===")
        result = n.run_cmd(command)
        results.append((n.path, result))
        for child in n.children:
            _run(child)

    _run(node)
    return results


def get_node(path_str):
    """Get or create a node from a path string."""
    p = Path(path_str).resolve()
    if not p.exists() or not p.is_dir():
        return None
    return build_tree(p)


def help():
    """Show available functions and usage examples."""
    print("""
=== PTPYTHON STARTUP HELPERS ===

VARIABLES:
  root              - DirNode for current directory tree

CORE FUNCTIONS:
  help()            - Show this help message
  sh(cmd)           - Run shell command: sh('git status')
  cd(path)          - Change root directory: cd('/path/to/dir')
  refresh()         - Reload current tree structure
  refresh(path)     - Reload from different path

TREE BUILDING:
  build_tree(path)  - Build tree from Path: build_tree(Path('/tmp'))
  get_node(path)    - Get node from string: get_node('/tmp')

SEARCHING:
  find_node(node, name)     - Find dir by name: find_node(root, 'src')
  find_file(node, filename) - Find file: find_file(root, 'setup.py')
  list_all(node)            - List all dir names: list_all(root)

DISPLAY:
  print_tree(node)  - Show tree structure: print_tree(root)

EXECUTION:
  node.run_cmd(cmd)         - Run in node's dir: root.run_cmd('ls')
  run_in_all(node, cmd)     - Run in all dirs: run_in_all(root, 'git status')

NODE PROPERTIES:
  node.path         - Absolute path (PosixPath)
  node.name         - Directory name
  node.children     - List of child DirNodes
  node.files        - List of file names

EXAMPLES:
  # Find and navigate
  users = find_node(root, 'users')
  print(users.files)
  users.run_cmd('ls -la')

  # Find file and run it
  script_node, filename = find_file(root, 'deploy.sh')
  script_node.run_cmd(f'./{filename}')

  # Run command in all subdirectories
  run_in_all(root, 'git status')

  # Change to different directory
  cd('/Users/you/projects')
    """.strip())



# Startup info
print("Available: help, sh, cd, refresh, build_tree, find_node, find_file, print_tree, list_all, run_in_all, root")
print("Type help() for detailed usage examples")
