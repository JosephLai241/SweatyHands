#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='\[\033[01;34m\]\u@\h\[\033[01;37m\]:\[\033[01;32m\]\w\[\033[00;37m\]\$ '

# Add Go to PATH environment variable
export PATH=$PATH:/usr/local/go/bin

# Load VMWare Modules
alias vm-start='sudo /etc/init.d/vmware start'
