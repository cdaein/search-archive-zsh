# Search Archive

#cli #tool

I often find myself a need to search through my earlier code sketches and find relevant code bits when I start a new project. Instead of going through them manually, this shell script works as a preliminary search/filter tool. The script will search a code sketchbook folder and filter them by search keyword. It looks at both folder/filename and file content.

The code sketchbook folder is simply a collection of individual sketch folders that take the format `"YYMMDD-sketch-title-etc/.."`. Once the script finds matches, I then have a chance to interactively filter them further in CLI before creating symlinks. The symlinks are created in the current directory and can be used as a reference without creating unnecessary duplicates and taking up space. Once they are used and no longer needed, simply delete the links.

> This is a very early prototype for my own use. There's no guarantee things will work as expected. Use at your own risk. Contributions are welcome.

## Requirements

```sh
brew install fd fzf grep xargs
```

## How to use

- Run `./search-archive.sh <search dir> <search pattern>`
  - For example, to search for p5 keyword in the `./sketches` directory, `./search-archive.sh ./sketches p5`
  - If it says no permission, update the execute permission: `chmod +x search-archive.sh`
- If there are any matches, you are presented with interactive screen provided by `fzf`.
  - Navigate with arrow keys.
  - Hit `TAB` for sketches that you want to select. `TAB` again to deselect.
  - Hit `RETURN` once the selections are made.
- The symlinks are created in new timestamped folder for your reference.

## Customization

The script assumes many things. If your sketchbook has a different structure, update the way it should find matching folders. In my case, all my sketches are in a timestamped (YYMMDD) folder so this filter works - `grep -Eo ".*/[0-9]{6}[^/]*"`. Generated folder name is hardcoded into `xlinks-YYMMDD-HH.MM.SS`. This is to avoid overwriting existing folder.

## To dos

- [ ] Improve matching process. Currently, it is blocking due to file content search.
- [ ] Search by file type. ex. `--filetype md`
- [ ] Search by included package. ex. `--pkg ssam`
- [ ] Search by tag. ex. `--tag cli`
- [ ] Search by only filename or including content. ex. `--content`

## License

MIT
