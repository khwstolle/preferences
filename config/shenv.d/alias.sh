# DNF and APT
if `command -v dnf &> /dev/null`; then
    alias dnf='sudo dnf'
fi

if `command -v apt &> /dev/null`; then
    alias apt='sudo apt'
    alias apt-get='sudo apt-get'
fi

# Python
alias py='python'
alias pym='python -module'
alias pdb='python -m pdb -c continue'
alias pip='python -m pip'

# Zellij
alias zj='zellij'

export ZELLIJ_AUTO_ATTACH='true'

function zellij-default() {
    if [[ -z "$ZELLIJ" ]]; then
        if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
            zellij attach -c
        else
            zellij
        fi

        if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
            exit
        fi
    fi
}
function zellij-persistent() {
    if [[ -z "$ZELLIJ" ]]; then
        zellij attach -c default
    fi
}

alias zjp='zellij-persistent'
alias zja='zellij-default'

# VIM to NeoVIM
alias vi='nvim'
alias vim='nvim'
alias nv='nvim'

# Git
alias git-each='git submodule foreach'

# RSync
alias rsync='rsync --rsh=ssh --progress --partial --recursive' 

# LS
alias la='ls -Alh' # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias lx='ls -lXBh' # sort by extension
alias lk='ls -lSrh' # sort by size
alias lc='ls -lcrh' # sort by change time
alias lu='ls -lurh' # sort by access time
alias lr='ls -lRh' # recursive ls
alias lt='ls -ltrh' # sort by date
alias lm='ls -alh |more' # pipe through 'more'
alias lw='ls -xAh' # wide listing format
alias ll='ls -Fls' # long listing formatalias la='ls -a'
alias ll='ls -a -l' # long listing format

# Files
#alias cp='cp -i'
#alias mv='mv -i'
# alias rm='rm -iv'
alias mkdirs='mkdir -p'

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# Processes
alias ps='ps auxf'
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Network
alias ping='ping -c 10'
alias ipview="netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"

# Text
alias less='less -R'
alias cls='clear'

# Archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Logs
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
