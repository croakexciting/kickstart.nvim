#!/bin/bash

function show_usage() {
    cat <<EOF
Usage: $0 [options] ...
OPTIONS:
    -h, --help             Display this help and exit.
    -f, --font             Install a nerd font.
EOF
}

function parse_cmdline_arguments() {
  while [[ $# -gt 0 ]]; do
    local opt="$1"
    shift
    case "${opt}" in
        --font)
	install_font
        exit
        ;;
       -h | --help)
        show_usage
        exit
        ;;
        -*|--*)
        echo "Unknown option $1"
        exit 1
        ;;
        *)
        shift # past argument
        ;;
    esac
  done
}

function install_font() {
	echo "install a nerd font"
	if [ ! -d /usr/share/fonts/0xProto/ ]; then 
		wget  https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/0xProto.zip -O nerd.zip
		sudo mkdir -p /usr/share/fonts/0xProto
		sudo unzip nerd.zip -d /usr/share/fonts/0xProto
		rm -f nerd.zip
		fc-cache -f -v
	fi
	echo "Done, run gnome-tweaks to select the 0xProto fonts"
}

function main() {
	parse_cmdline_arguments "$@"

	echo "===== Ubuntu install ==="
	sudo apt update
	sudo apt install -y tmux wget gcc g++ clang curl

	echo "===== Install Lazy Git ="
	if [ ! -f /usr/local/bin/lazygit ]; then
		local LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
		curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
		tar xf lazygit.tar.gz lazygit
		sudo install lazygit /usr/local/bin
		rm -f lazygit*
	fi
	
	echo "===== Install nvim ====="
	if [ ! -f /usr/bin/nvim ]; then
		wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz -O nvim.tar.gz
		sudo tar xzf nvim.tar.gz --strip-components=1 -C /usr
		rm nvim.tar.gz
	fi

	echo "===== Nvim setup ======="
	rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
	git clone --depth=1 https://github.com/croakexciting/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

	echo "===== Tmux setup ======="
	rm -rf "${XDG_CONFIG_HOME:-$HOME}"/.tmux/plugins/tpm
	git clone --depth=1 https://github.com/tmux-plugins/tpm "${XDG_CONFIG_HOME:-$HOME}"/.tmux/plugins/tpm
	rm -f "${XDG_CONFIG_HOME:-$HOME}/.tmux.conf"
	cat <<EOF >> "${XDG_CONFIG_HOME:-$HOME}/.tmux.conf"
unbind r
bind r source-file ~/.tmux.conf

set -g prefix C-s

# act like vim
setw -g mode-keys vi
bind-key h select-pane -L
bind-key j select-pane -D
bind-key k select-pane -U
bind-key l select-pane -R

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'dracula/tmux'

set -g @dracula-plugins "cpu-usage ram-usage"
set -g @dracula-show-powerline true
set -g @dracula-show-left-icon session
set -g @dracula-show-flags true

# bash promt
set -g default-terminal "screen-256color"

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF

	echo "Done! Don't forget select nerd font before use it"
}

main "$@"

