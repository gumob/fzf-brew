# fzf-brew

## Table of Contents

- [fzf-brew](#fzf-brew)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Installation](#installation)
    - [Download fzf-brew to your home directory](#download-fzf-brew-to-your-home-directory)
    - [Using key bindings](#using-key-bindings)
  - [Usage](#usage)
  - [License](#license)

## Overview

This is a shell plugin that allows you to execute [`homebrew`](https://github.com/Homebrew/brew) commands using keyboard shortcuts utilizing [`junegunn/fzf`](https://github.com/junegunn/fzf) and [`Homebrew/brew`](https://github.com/Homebrew/brew).

## Installation

### Download [fzf-brew](https://github.com/gumob/fzf-brew) to your home directory

```shell
wget -O ~/.fzfbrew https://raw.githubusercontent.com/gumob/fzf-brew/main/fzf-brew.sh
```

### Using key bindings

Source `fzf` and `fzf-brew` in your run command shell.
By default, no key bindings are set. If you want to set the key binding to `Ctrl+B`, please configure it as follows:

```shell
cat <<EOL >> ~/.zshrc
export FZF_BREW_KEY_BINDING="^B"
source ~/.fzfbrew
EOL
```

`~/.zshrc` should be like this.

```shell
source <(fzf --zsh)
export FZF_BREW_KEY_BINDING='^B'
source ~/.fzfbrew
```

Source run command

```shell
source ~/.zshrc
```

## Usage

Using the shortcut key set in `FZF_BREW_KEY_BINDING`, you can execute `fzf-brew`, which will display a list of `brew` commands.

To run `fzf-brew` without using the keyboard shortcut, enter the following command in the shell:

```shell
fzf-brew
```

## License

This project is licensed under the MIT License. The MIT License is a permissive free software license that allows for the reuse, modification, distribution, and sale of the software. It requires that the original copyright notice and license text be included in all copies or substantial portions of the software. The software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement.
