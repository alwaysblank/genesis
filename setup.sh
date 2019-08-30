#!/bin/bash


echo "📦 Update package manager..."
sudo apt-get update

echo ''

echo "📓 Install git:"
if [ ! $(which git) ]; then
	sudo apt -y install git
else
	echo "✔ Git already installed!"
fi

echo ''

echo "🐠 Install fish shell:"
if [ ! $(which fish) ]; then	
	sudo apt-add-repository -y ppa:fish-shell/release-3
	sudo apt-get -y update
	sudo apt-get -y install fish
	echo "✔ Fish has been installed!"
else
	echo "✔ Fish already intstalled!"
fi

echo ''

echo "🐚 Make fish shell user default:"
if [ ! $SHELL == $(which fish) ]; then
	sudo usermod --shell $(which fish) $(whoami)
	echo "✔  Fish is now your default shell!"
else
	echo "✔ Fish is already your default shell!"
fi

echo ''

echo "💎 Set up rbenv:"
if [ ! -d ~/.rbenv ]; then
	# Install dependencies
	sudo apt -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev

	# Pull down rbenv itself
	git clone https://github.com/rbenv/rbenv.git ~/.rbenv

	# Install ruby-build
	git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

	# Add rbenv to bash so we can use it right now
	echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
	echo 'eval "$(rbenv init -)"' >> ~/.bashrc
	source ~/.bashrc

	# Add rbenv to fish path
	# printf 'if status --is-interactive\n\tset PATH $HOME/.rbenv/bin $PATH\n\t. (rbenv init - | psub)\nend' >> ~/.config/fish/config.fish

	# Install ruby (currently hardcoded to 2.6.4 because that was the latest when I wrote this script
	rbenv install 2.6.4
	rbenv global 2.6.4

	echo '✔ rbenv should be installed now!'
else
	echo '✔ rbenv already installed!'
fi
	
echo ''

echo "🐘 Install php:"
if [ ! $(which php) ]; then
	sudo apt -y install php
	echo "✔ PHP should be installed now!"
else
	echo "✔ PHP is already installed!"
fi

echo ''

echo "👩‍🎤 Install Composer:"
if [ ! $(which composer) ]; then
	EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
	if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
		>&2 echo 'ERROR: Invalid installer signature'
		rm composer-setup.php
		exit 1
	fi

	php composer-setup.php --quiet
	rm composer-setup.php

	if [ -f "composer.phar" ]; then
		sudo mv composer.phar /usr/local/bin/composer
		echo "✔ Composer installed!"
	else
		echo "😬 Something went wrong!"
	fi
else
	echo "✔ Composer is already installed!"
fi

echo ''

echo "🏰 Setting up dotfiles:"
if [ ! $(which homesick) ]; then
	gem install homesick
	homesick clone https://github.com/alwaysblank/sculpin.git
	homesick link sculpin
fi
echo '✔ Done with dotfiles!'

echo ''

echo "🦀 Installing rust:"
if [ ! $(which rustup) ]; then
	# Install some dependencies
	sudo apt -y install pkg-config

	# Run the installer w/o prompts
	curl https://sh.rustup.rs -sSf | sh -y
fi
echo '✔  Done with rust!'

echo "🚀 Installing starship:"
if [ ! $(which starship) ]; then
	cargo install starship
fi
echo '✔  Done with starship!'

echo "🛠 Installing tools:"
# lsd; nicer ls
if [ ! $(which lsd) ]; then
	cargo install lsd
fi
# ripgrep; nicer grep
if [ ! $(which rg) ]; then
	cargo install ripgrep
fi
# fd; nicer find
if [ ! $(which fd) ]; then
	cargo install fd-find
fi

echo ''

echo "A few more checks..."
if [ ! -d ~/.ssh ]; then
	mkdir ~/.ssh
fi
