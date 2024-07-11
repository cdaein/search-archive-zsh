#!/bin/zsh

# TODO: try regex pattern for search pattern
# REVIEW: can i just use `fzf` to do all searching and matching? this way it will be non-blocking, and I can feed the result to creating symlink.

print_color() {
  local color_code=$1
  local message=$2
  echo -e "\e[${color_code}m${message}\e[0m"
}

get_absolute_path() {
  local input_path="$1"
  if [[ "$input_path" = /* ]]; then
    echo "$input_path"
  else
    # echo "$(pwd)/$input_path"
    echo "$(cd "$(dirname "$input_path")" && pwd)/$(basename "$input_path")"
  fi
}

create_symlink() {
  local src=$(get_absolute_path "$1")
  local tgt=$(get_absolute_path "$2")
  ln -sf "$src" "$tgt"
}

match_filename() {
  local search_path="$1"
  local search_pattern="$2"

  # REVIEW: ex. if i search with "js", it matches ".json" file. I want to use regex to avoid it.

  fd --type f --type d --absolute-path --search-path "$search_path" --exclude "package-lock.json" "${search_pattern}" | 
    sed 's|/$||' |                        # Remove the trailing slash
    grep -Eo ".*/[0-9]{6}[^/]*" |         # only select the sketch-level directories (starts with "yymmdd")
    sort -u
}

match_content() {
  local search_path="$1"
  local search_pattern="$2"

  fd --type f --absolute-path --search-path "$search_path" -0 --exclude "package-lock.json" |
    xargs -0 grep -ialr "$search_pattern" |
    xargs -I {} dirname "{}" |            # Get the directory name for each file (quote "{}" to handle spaces)
    grep -Eo ".*/[0-9]{6}[^/]*" |         # only select the sketch-level directories (starts with "yymmdd")
    sort -u                                # Sort and uniquify again to get unique top-level directories
}

search() {
  local search_dir="$1"
  local search_pattern="$2"

  local filename_matches=$(match_filename "${search_dir}" "${search_pattern}")
  local content_matches=$(match_content "${search_dir}" "${search_pattern}")
  local matches=("${filename_matches}" "${content_matches}")

  local current_datetime=$(date +"%y%m%d-%H.%M.%S")
  local target_dir="xlinks-$current_datetime"

  # If target dir is not empty, warn and exit. (safety first)
  if [[ -d "$target_dir" ]]; then
    if [ "$(ls -A "$target_dir")" ]; then
      echo "$(print_color "33" "Warning:") Target directory is not empty."
      exit 1
    fi
  else
    # if target_dir non-existent (most likely), create one
    mkdir "$target_dir"
  fi

  # REVIEW: finding matches happen first so it is blocking when it is time for `fzf`.
  # maybe give option to only serach filename (faster), or also search file content (slow but more thorough)
  local selection=$(printf '%s\n' $matches | sort | uniq | fzf -m --height ~100% --layout reverse --border)

  if [ ${#selection} -eq 0 ]; then
    echo "No selection found"
    exit 1
  fi

  for item in ${(@f)selection}; do
    echo "Creating a symlink for '$(basename "$item")'"
    create_symlink $item "$target_dir"
  done
}

# Check if 2 arguments are passed
if [ "$#" -ne 2 ]; then
  echo "Usage: $(print_color "32" "$0") <search_dir> <search_pattern>"
  exit 1
fi

search $1 $2

