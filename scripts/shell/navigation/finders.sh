#!/usr/bin/env zsh
# Navigation and Finder Functions
# Interactive file and directory navigation tools

# Lazy load guard
[[ -n "${_NAVIGATION_LOADED}" ]] && return
_NAVIGATION_LOADED=1

# GIT_ROOT is a global variable, so 'local' is not used here.
GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"

# A powerful, context-aware project finder that displays clean, relative paths.
# If run inside a git repository, it searches only within that project.
# Otherwise, it searches from your home directory.
# Usage: Type 'ff' in your terminal and press Enter.
ff() {
    # Attempt to find the root of the current git repository. 
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    local search_path
    # Check if we are inside a git repository.
    if [[ -n "$git_root" ]]; then
        # If yes, set the search path to the project's root directory.
        search_path="$git_root"
    else
        # If no, fall back to searching from the home directory.
        search_path="$HOME"
    fi

    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FF_SEARCH_PATH="$search_path"

    # Find directories, strip the base path for a clean display, and pipe to fzf.
    local selected_relative_path
    selected_relative_path=$(fd --type d . "$search_path" --hidden --exclude .git --exclude node_modules \
        | sed "s|^$search_path/||" \
        | fzf \
            --preview "eza --tree --color=always --icons=always --level=2 \"$FZF_FF_SEARCH_PATH\"/{}" \
            --preview-window 'right:50%' \
            --height '80%' \
            --border 'rounded' \
            --header 'Project Finder | Press Enter to select')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        # Change the current directory of your terminal to that full path.
        cd "$full_path" || return
        # Optional: clear the screen and show a tree of the new location.
        clear
        eza --tree --icons=always --level=2 # Corrected eza flag
    fi
}

# ffc (Fuzzy Find Current) - Like ff but searches only in the current directory
# Usage: Type 'ffc' in your terminal and press Enter.
ffc() {
    # Use current directory as search path
    local search_path="$PWD"
    
    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FFC_SEARCH_PATH="$search_path"

    # Find directories, strip the base path for a clean display, and pipe to fzf.
    local selected_relative_path
    selected_relative_path=$(fd --type d . "$search_path" --hidden --exclude .git --exclude node_modules \
        | sed "s|^$search_path/||" \
        | fzf \
            --preview "eza --tree --color=always --icons=always --level=2 \"$FZF_FFC_SEARCH_PATH\"/{}" \
            --preview-window 'right:50%' \
            --height '80%' \
            --border 'rounded' \
            --header 'Current Directory Finder | Press Enter to select')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        # Change the current directory of your terminal to that full path.
        cd "$full_path" || return
        # Optional: clear the screen and show a tree of the new location.
        clear
        eza --tree --icons=always --level=2
    fi
}

ffn() {
    
    local search_path
    search_path="$HOME"
    
    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FF_SEARCH_PATH="$search_path"

    # Find directories, strip the base path for a clean display, and pipe to fzf.
    local selected_relative_path
    selected_relative_path=$(fd --type d . "$search_path" --hidden --exclude .git --exclude node_modules \
        | sed "s|^$search_path/||" \
        | fzf \
            --preview "eza --tree --color=always --icons=always --level=2 \"$FZF_FF_SEARCH_PATH\"/{}" \
            --preview-window 'right:50%' \
            --height '80%' \
            --border 'rounded' \
            --header 'Project Finder | Press Enter to select')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        cd "$full_path"
        # Get the name of the current directory to use as the session name.
        # We replace periods with underscores as they can be problematic in session names.
        local session_name=$(basename "$PWD" | tr '.' '_')
        nvim .
    fi
}

# Function: fch (Fuzzy Command History)
# Description:
#   Launches an interactive fzf session to search through your entire Zsh history.
#   Allows fuzzy matching, navigation with arrow keys, and immediate execution
#   of the selected command upon pressing Enter.
#   The display and matching behavior will be similar to your 'ff' command.
#
# Usage:
#   Type 'fch' in your terminal and press Enter.
#   Inside the fzf window:
#     - Type any part of a command to fuzzy-filter the history.
#     - Use Up/Down arrow keys to navigate the filtered list.
#     - Press Enter to execute the highlighted command.
#     - Press Ctrl+Y to paste the command to the prompt for editing.
#     - Press Esc or Ctrl+C to cancel and return to the prompt.
fch() {
    local selected_command

    # Get the entire history list (fc -l 1) and remove the leading history number
    # (e.g., "   123  ls -la" becomes "ls -la") for cleaner fzf display.
    selected_command=$( \
        fc -l 1 | \
        sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | \
        fzf \
            --no-sort \
            --height '80%' \
            --border 'rounded' \
            --header 'Fuzzy History Search | Enter to execute, Ctrl+Y to paste' \
            --ansi # Enable ANSI color codes in fzf if your history has them
    )

    # If a command was selected (user pressed Enter in fzf)
    if [[ -n "$selected_command" ]]; then
        # Print the command to the terminal before executing it, for clarity.
        # This makes it clear what command is about to run.
        echo "$selected_command"
        # Execute the selected command.
        # 'eval' is necessary to run the string as a shell command.
        eval "$selected_command"
    fi
}

# fft (Fuzzy Find Terraform) - Find directories containing .tf files and run terraform plan
# Usage: Type 'fft' in your terminal and press Enter.
fft() {
    # Attempt to find the root of the current git repository. 
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    local search_path
    # Check if we are inside a git repository.
    if [[ -n "$git_root" ]]; then
        # If yes, set the search path to the project's root directory.
        search_path="$git_root"
    else
        # If no, fall back to searching from the home directory.
        search_path="$HOME"
    fi

    # Find directories that contain .tf files (optimized with depth limit and exclusions)
    local tf_dirs
    # Use fd if available (much faster), otherwise fall back to find
    if command -v fd &>/dev/null; then
        tf_dirs=$(fd -e tf -t f --hidden --exclude node_modules --exclude .git --exclude .terraform "$search_path" 2>/dev/null | xargs -n1 dirname | sort -u)
    else
        tf_dirs=$(find "$search_path" -name "node_modules" -prune -o -name ".git" -prune -o -name ".terraform" -prune -o -name "*.tf" -type f -exec dirname {} \; 2>/dev/null | sort -u)
    fi
    
    # Check if any Terraform directories were found
    if [[ -z "$tf_dirs" ]]; then
        echo "No directories with .tf files found in $search_path"
        return 1
    fi
    
    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FFT_SEARCH_PATH="$search_path"

    # Strip the base path for a clean display and pipe to fzf
    local selected_relative_path
    selected_relative_path=$(echo "$tf_dirs" | sed "s|^$search_path/||" | fzf \
        --preview "echo 'Terraform files in this directory:' && find \"$FZF_FFT_SEARCH_PATH\"/{} -name '*.tf' -type f -exec basename {} \\; 2>/dev/null | sort" \
        --preview-window 'right:50%' \
        --height '80%' \
        --border 'rounded' \
        --header 'Terraform Finder | Press Enter to cd and run terraform plan')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        
        # Change to the selected directory
        echo "Changing to: $full_path"
        cd "$full_path" || return 1
        
        # Clear screen and show current location
        clear
        echo "📁 Current directory: $(pwd)"
        echo "🔍 Terraform files found:"
        find . -name "*.tf" -type f -exec basename {} \; | sort
        echo ""
        
        # Run terraform init and plan
        echo "🚀 Running terraform init && terraform plan..."
        echo "────────────────────────────────────────"
        terraform init && terraform plan
    fi
}

# fftg (Fuzzy Find Terragrunt) - Find directories containing .hcl files and run terragrunt plan
# Usage: Type 'fftg' in your terminal and press Enter.
fftg() {
    # Attempt to find the root of the current git repository. 
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    local search_path
    # Check if we are inside a git repository.
    if [[ -n "$git_root" ]]; then
        # If yes, set the search path to the project's root directory.
        search_path="$git_root"
    else
        # If no, fall back to searching from the home directory.
        search_path="$HOME"
    fi

    # Find directories that contain terragrunt.hcl files (optimized with depth limit and exclusions)
    local hcl_dirs
    # Use fd if available (much faster), otherwise fall back to find
    if command -v fd &>/dev/null; then
        hcl_dirs=$(fd -t f -H "terragrunt.hcl" --max-depth 6 --exclude node_modules --exclude .git --exclude .terraform . "$search_path" 2>/dev/null | xargs -n1 dirname | sort -u)
    else
        hcl_dirs=$(find "$search_path" -maxdepth 6 -name "node_modules" -prune -o -name ".git" -prune -o -name ".terraform" -prune -o -name "terragrunt.hcl" -type f -exec dirname {} \; 2>/dev/null | sort -u)
    fi
    
    # Check if any Terragrunt directories were found
    if [[ -z "$hcl_dirs" ]]; then
        echo "No directories with terragrunt.hcl files found in $search_path"
        return 1
    fi
    
    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FFTG_SEARCH_PATH="$search_path"

    # Strip the base path for a clean display and pipe to fzf
    local selected_relative_path
    selected_relative_path=$(echo "$hcl_dirs" | sed "s|^$search_path/||" | fzf \
        --preview "echo 'Terragrunt files in this directory:' && find \"$FZF_FFTG_SEARCH_PATH\"/{} -name 'terragrunt.hcl' -type f -exec basename {} \\; 2>/dev/null | sort" \
        --preview-window 'right:50%' \
        --height '80%' \
        --border 'rounded' \
        --header 'Terragrunt Finder | Press Enter to cd and run terragrunt plan')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        
        # Change to the selected directory
        echo "Changing to: $full_path"
        cd "$full_path" || return 1
        
        # Clear screen and show current location
        clear
        echo "📁 Current directory: $(pwd)"
        echo "🔍 Terragrunt files found:"
        find . -name "terragrunt.hcl" -type f -exec basename {} \; | sort
        echo ""
        
        # Run terragrunt plan
        echo "🚀 Running terragrunt plan..."
        echo "────────────────────────────────────────"
        terragrunt plan
    fi
}

# ffa (Fuzzy Find Apollo) - Interactively find a directory within ~/Apollo and navigate to it.
# Usage: Type 'ffa' in your terminal and press Enter.
ffa() {
    # The search path is always the ~/Apollo directory.
    local search_path="$HOME/Apollo"

    # Check if the Apollo directory exists.
    if [[ ! -d "$search_path" ]]; then
        echo "Directory not found: $search_path"
        echo "Please ensure the Apollo directory exists."
        return 1
    fi

    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FFA_SEARCH_PATH="$search_path"

    # Find directories within ~/Apollo, limiting the depth to 2 levels (org/project),
    # strip the base path for a clean display, and pipe to fzf.
    local selected_relative_path
    selected_relative_path=$(fd --type d --max-depth 2 . "$search_path" --hidden --exclude .git --exclude node_modules \
        | sed "s|^$search_path/||" \
        | fzf \
            --preview "eza --tree --color=always --icons=always --level=2 \"$FZF_FFA_SEARCH_PATH\"/{}" \
            --preview-window 'right:50%' \
            --height '80%' \
            --border 'rounded' \
            --header 'Apollo Project Finder | Press Enter to navigate')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        # Change to the selected directory.
        cd "$full_path"
        # Clear and show the tree of the new location.
        clear
        eza --tree --icons=always --level=2
    fi
}

# ffan (Fuzzy Find Apollo Neovim) - Interactively find a directory within ~/Apollo and open it in Neovim.
# Usage: Type 'ffan' in your terminal and press Enter.
ffan() {
    # The search path is always the ~/Apollo directory.
    local search_path="$HOME/Apollo"

    # Check if the Apollo directory exists.
    if [[ ! -d "$search_path" ]]; then
        echo "Directory not found: $search_path"
        echo "Please ensure the Apollo directory exists."
        return 1
    fi

    # We need to export the search_path so the fzf preview subshell can access it.
    export FZF_FFAN_SEARCH_PATH="$search_path"

    # Find directories within ~/Apollo, limiting the depth to 2 levels (org/project),
    # strip the base path for a clean display, and pipe to fzf.
    local selected_relative_path
    selected_relative_path=$(fd --type d --max-depth 2 . "$search_path" --hidden --exclude .git --exclude node_modules \
        | sed "s|^$search_path/||" \
        | fzf \
            --preview "eza --tree --color=always --icons=always --level=2 \"$FZF_FFAN_SEARCH_PATH\"/{}" \
            --preview-window 'right:50%' \
            --height '80%' \
            --border 'rounded' \
            --header 'Apollo Project Finder | Press Enter to open in Neovim')

    # If a directory was selected (i.e., you pressed Enter)...
    if [[ -n "$selected_relative_path" ]]; then
        # ...reconstruct the full path by prepending the search_path.
        local full_path="$search_path/$selected_relative_path"
        # Open the selected directory in Neovim.
        cd "$full_path"
        
        # Extract just the project name (last part of the path)
        local project_name=$(basename "$selected_relative_path")
        
        # Set the terminal tab name to the project name
        if command -v ttn &>/dev/null; then
            ttn "$project_name"
        fi
        
        # Configure Neovim to not override the terminal title
        export NVIM_TUI_ENABLE_TITLE=0
        
        # Open Neovim with title override disabled
        nvim --cmd "set notitle" .
    fi
}

# ffb (Fuzzy Find Back) - Navigate back to parent directories in current path
# Usage: Type 'ffb' in your terminal and press Enter to select a parent directory
ffb() {
    # Get the current directory and build parent path list
    local current_dir="$PWD"
    local temp_dir="$current_dir"
    local paths_list=""
    local level=0
    
    # Build the list of parent directories with metadata
    while true; do
        local dir_name=$(basename "$temp_dir")
        local dir_count=$(find "$temp_dir" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
        local file_count=$(find "$temp_dir" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
        
        # Format the display based on level
        if [[ $level -eq 0 ]]; then
            paths_list="${paths_list}[Current] 📍 ${dir_name} (${file_count} files, ${dir_count} dirs)|${temp_dir}\n"
        elif [[ $level -eq 1 ]]; then
            paths_list="${paths_list}[↑ 1 up] 📂 ${dir_name} (${file_count} files, ${dir_count} dirs)|${temp_dir}\n"
        else
            paths_list="${paths_list}[↑ ${level} up] 📂 ${dir_name} (${file_count} files, ${dir_count} dirs)|${temp_dir}\n"
        fi
        
        # Check if we've reached root
        if [[ "$temp_dir" == "/" ]]; then
            break
        fi
        
        # Move up one directory
        temp_dir="$(dirname "$temp_dir")"
        level=$((level + 1))
    done
    
    # Use fzf to select a directory
    local selected
    selected=$(echo -e "$paths_list" | fzf \
        --height '80%' \
        --border 'rounded' \
        --header 'Navigate Back to Parent Directory | Arrow keys to browse, Enter to select' \
        --preview 'dir=$(echo {} | cut -d"|" -f2); echo "📁 Directory: $dir"; echo ""; echo "Contents:"; echo "────────────────────"; eza --icons=always --color=always -la "$dir" 2>/dev/null | head -25' \
        --preview-window 'right:60%' \
        --with-nth 1 \
        --delimiter '|' \
        --ansi)
    
    # Extract the path and navigate
    if [[ -n "$selected" ]]; then
        local target_dir=$(echo "$selected" | cut -d'|' -f2)

        if [[ -n "$target_dir" ]] && [[ -d "$target_dir" ]]; then
            cd "$target_dir" || return 1

            # Show where we navigated to
            clear
            echo "📁 Navigated to: $PWD"
            echo ""
            eza --icons=always -la --tree --level=1
        fi
    fi
}

# gd (Google Drive) - Send files to, or create folders inside, the locally
# synced Google Drive using fzf to pick the destination.
# Usage:
#   gd <file_path>       Copy a file/dir into a fuzzy-selected Drive folder.
#   gd create [name]     Create a new folder inside a fuzzy-selected parent.
gd() {
    # Root at "My Drive" so fzf only surfaces user-owned folders, not
    # "Other computers" or "Shared drives".
    local gdrive_root="$HOME/Library/CloudStorage/GoogleDrive-matt@hadrius.com/My Drive"
    if [[ ! -d "$gdrive_root" ]]; then
        echo "Google Drive folder not found: $gdrive_root"
        return 1
    fi

    if [[ $# -eq 0 || -z "$1" ]]; then
        echo "Usage:"
        echo "  gd <file_path>     Send a file/dir to Google Drive"
        echo "  gd create [name]   Create a new folder in Google Drive"
        return 1
    fi

    # Helper: fuzzy-pick a folder relative to $gdrive_root. Prints the
    # selected relative path ("." for the root) on stdout; empty on cancel.
    _gd_pick_folder() {
        local header="$1"
        export FZF_GD_SEARCH_PATH="$gdrive_root"
        { echo "."; fd --type d . "$gdrive_root" --hidden --exclude .git \
            | sed "s|^$gdrive_root/||"; } \
        | fzf \
            --preview "eza --tree --color=always --icons=always --level=2 \"$FZF_GD_SEARCH_PATH\"/{}" \
            --preview-window 'right:50%' \
            --height '80%' \
            --border 'rounded' \
            --header "$header"
    }

    # Subcommand: fzf-pick a parent, then create a (possibly nested) folder path inside it.
    if [[ "$1" == "create" ]]; then
        local parent_rel
        parent_rel=$(_gd_pick_folder "Google Drive | Pick parent folder, then enter new folder path")
        if [[ -z "$parent_rel" ]]; then
            echo "No parent selected."
            return 1
        fi

        local parent_abs
        if [[ "$parent_rel" == "." ]]; then
            parent_abs="$gdrive_root"
        else
            parent_abs="$gdrive_root/$parent_rel"
        fi

        # Accept the folder path as a second arg or prompt for it. Supports
        # nested paths like "foo/bar/baz" with optional leading/trailing "/".
        local raw_path="$2"
        if [[ -z "$raw_path" ]]; then
            printf "New folder path (e.g. foo/bar/baz): "
            read -r raw_path
        fi

        # Strip leading and trailing slashes; collapse any accidental doubles.
        local new_path="${raw_path#/}"
        new_path="${new_path%/}"
        while [[ "$new_path" == *"//"* ]]; do
            new_path="${new_path//\/\//\/}"
        done

        if [[ -z "$new_path" ]]; then
            echo "No folder path provided."
            return 1
        fi

        local target="$parent_abs/$new_path"
        if [[ -d "$target" ]]; then
            echo "ℹ Folder already exists: ${parent_rel%/}/${new_path}"
            return 0
        fi
        if [[ -e "$target" ]]; then
            echo "✗ Path exists and is not a directory: ${parent_rel%/}/${new_path}"
            return 1
        fi

        if mkdir -p "$target"; then
            echo "✓ Created folder in Google Drive: ${parent_rel%/}/${new_path}"
        else
            echo "✗ Failed to create folder."
            return 1
        fi
        return 0
    fi

    # Default behavior: copy the given file/dir into a selected folder.
    local src="$1"
    if [[ ! -e "$src" ]]; then
        echo "File not found: $src"
        return 1
    fi

    local base_name
    base_name=$(basename "$src")

    local selected_relative_path
    selected_relative_path=$(_gd_pick_folder "Google Drive | Copy '$base_name' to selected folder")

    if [[ -z "$selected_relative_path" ]]; then
        echo "No directory selected."
        return 1
    fi

    local dest
    if [[ "$selected_relative_path" == "." ]]; then
        dest="$gdrive_root"
    else
        dest="$gdrive_root/$selected_relative_path"
    fi

    echo "📤 Copying '$src' → '$dest/'"
    if cp -R "$src" "$dest/"; then
        echo "✓ Sent to Google Drive: ${selected_relative_path%/}/${base_name}"
    else
        echo "✗ Copy failed."
        return 1
    fi
}

