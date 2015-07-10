
# Get current directory
CURDIR			?= $(.CURDIR)

# If current user is the same as owner, do more things
OWNER			= scibi

# Where dotfiles are kept
DOTFILES		= ~/.config/dotfiles

# Source of dotfiles
DOTFILES_GIT_URL	= https://github.com/${OWNER}/sample_dotfiles.git

# Commands
LINK			= ln -snv
COPY			= cp -fv


# ---- dotfiles ----

GIT = ~/.gitconfig
GIT_OWNER = ~/.gitconfig.$(OWNER)

VIM = ~/.vimrc

BASH = ~/.bash_logout ~/.bashrc


SYMLINKS = $(VIM) $(BASH) $(GIT)

OWNER_SYMLINKS = $(GIT_OWNER)


# ---- Main Makefile ----

all: install vim-vundle

install: git vim bash
#	mc gpg bin

owner: install vim-vundle gui smartcard newsbeuter

gui: xresources i3
	@ansible-playbook -i ansible/inventory ansible/playbooks/gui.yml

smartcard:
	@ansible-playbook -i ansible/inventory ansible/playbooks/gui.yml

vim: $(VIM)
	@echo "Setting up vim ftplugin"
	@mkdir -p ~/.vim/
	@test -e ~/.vim/ftplugin || $(LINK) $(CURDIR)/.vim/ftplugin ~/.vim/ftplugin


bash: $(BASH)

git: $(GIT) $(GIT_OWNER)

vim-vundle:
	@echo "Setting up vim bundles ... "
	@mkdir -p ~/.vim/bundle
	@test -d ~/.vim/bundle/vundle || \
		(git clone --quiet https://github.com/gmarik/vundle.git \
		~/.vim/bundle/vundle && \
		vim +BundleInstall +qall)

mc:
	@mkdir -p ~/.config/mc
	@test -e ~/.config/mc/ini || $(COPY) $(CURDIR)/.config/mc/ini ~/.config/mc/ini

gpg:
	@mkdir -m 700 -p ~/.gnupg
	@test -e ~/.gnupg/gpg.conf || $(LINK) $(CURDIR)/.gnupg/gpg.conf ~/.gnupg/gpg.conf

bin:
	@mkdir -p ~/.local
	@test -e ~/.local/bin || \
		${LINK} $(CURDIR)/.local/bin ~/.local/bin

i3:
	@mkdir -p ~/.config
	@test -e ~/.config/i3 || \
		${LINK} $(CURDIR)/.config/i3 ~/.config/i3

get:
	@test ! -d ${DOTFILES} && git clone ${DOTFILES_GIT_URL} ${DOTFILES} || true

check-dead:
	find ~ -maxdepth 1 -name '.*' -type l -exec test ! -e {} \; -print

clean-dead:
	find ~ -maxdepth 1 -name '.*' -type l -exec test ! -e {} \; -delete

update:
	@git pull --rebase

$(SYMLINKS):
	@$(LINK) $(CURDIR)/$(patsubst $(HOME)/%,%,$@) $@

$(OWNER_SYMLINKS):
	@test "$(USER)" = "$(OWNER)" && (test -h $@ || $(LINK) $(CURDIR)/$(patsubst $(HOME)/%,%,$@) $@) || true

