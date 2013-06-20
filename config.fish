set fish_config_path $HOME/.config/fish
cd .

if which brew >/dev/null
	# adding an appropriate PATH variable for use with Homebrew
	set PATH (brew --prefix)/bin (brew --prefix)/sbin /usr/local/share/python $PATH
	# Finished adapting your PATH environment variable for use with Homebrew 

	set PYTHONPATH (brew --prefix)/lib/python2.7/site-packages
end

# {{{ Function to reload configuration files
function rc
        echo "Reloading FISH configuration"
        . $fish_config_path/config.fish
end
# }}}

# Disable the greeting and exit messages
set fish_greeting ""

# git and svn detection
function parse_git_branch
        if has-git-changes
                set_color red
        else
                set_color blue
        end

        set -l branch (env git symbolic-ref -q HEAD)
        if test ! -z "$branch"
                echo -n $branch | sed -e 's/refs\/heads\///'
        else
                git name-rev --name-only HEAD ^/dev/null
        end
end

function has-git-changes
        not git diff --quiet; or not git diff --quiet --cached ^/dev/null
end

function is-git
        env git rev-parse --git-dir ^/dev/null >/dev/null
end

function parse_svn_tag_or_branch
        sh -c 'svn info | grep "^URL :" | egrep -o "(tags|branches)/[^/]+|trunk" | egrep -o "[^/]+$"'
end

function parse_svn_revision
        sh -c 'svn info 2> /dev/null' | grep 'Revision' | sed -e 's/^Revision: \(.*\)/\1/'
end

# Prompt
function fish_prompt -d "Write out the prompt"
        printf '%s%s@%s%s' (set_color brown) (whoami) (hostname|cut -d . -f 1) (set_color normal)

        # Color writeable dirs green, read-only dirs red
        if test -w "."
                printf ' %s%s' (set_color green) (prompt_pwd)
        else
                printf ' %s%s' (set_color red) (prompt_pwd)
        end

        # Print subversion tag or branch
        if test -d ".svn"
                printf ' %s%s%s' (set_color normal) (set_color blue) (parse_svn_tag_or_branch)
        end

        # Print subversion revision
        if test -d ".svn"
                printf '%s%s@%s' (set_color normal) (set_color blue) (parse_svn_revision)
        end

        # Print git branch
        #if test -d ".git"
        if is-git
                printf ' %s%s/%s' (set_color normal) (set_color blue) (parse_git_branch)
        end

        printf '%s> ' (set_color normal)
end
