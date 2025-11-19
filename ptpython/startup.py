"""
ptpython startup script
Automatically loaded when ptpython starts
"""

import subprocess
from pathlib import Path


class DirNode:
    def __init__(self, path):
        self.path = path
        self.name = path.name
        self.children = []

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
        print(result.stdout)
        if result.stderr:
            print(result.stderr)
        return result


def build_tree(path):
    """Build a tree structure of directories from the given path."""
    node = DirNode(path)
    for child in sorted(path.iterdir()):
        if child.is_dir() and not child.name.startswith('.'):
            node.children.append(build_tree(child))
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

# Startup info
print("Available: DirNode, build_tree, find_node, print_tree, list_all, Path, subprocess, root")
print("  root.run_cmd('ls -la')                    # run in root dir")
print("  root.children[0].run_cmd('git status')    # run in child dir")
print("  find_node(root, 'src').run_cmd('ls')      # find and run cmd")
print("  print_tree(root)                          # show tree structure")
print("  list_all(root)                            # list all node names")
print("  node = build_tree(root.children[0].path)  # new tree from child")
