if status is-interactive
    # Commands to run in interactive sessions can go here
end


# ghq + fzf
function ghq_fzf_repo -d 'Repository search'
  ghq list --full-path | fzf --reverse --height=100% | read select
  [ -n "$select" ]; and cd "$select"
  echo " $select "
  commandline -f repaint
end

# fish key bindings
function fish_user_key_bindings
  bind \cg ghq_fzf_repo
end

fish_add_path $HOME/bin
fish_add_path $HOME/.cargo/bin

set -U FZF_LEGACY_KEYBINDINGS 0
set -U FZF_REVERSE_ISEARCH_OPTS "--reverse --height=100%"

set -g theme_display_date yes
set -g theme_date_format "+%F %H:%M"
set -g theme_display_git_default_branch yes
set -g theme_color_scheme solarized-dark

set -x GITHUB_USERNAME shinter61
set -x GITHUB_TOKEN ""

set -x LC_ALL ja_JP.UTF-8
set -x LANG ja_JP.UTF-8
set -x TERM xterm-256color
set -x COLORTERM truecolor
set -x SHELL /usr/local/bin/fish
set -x EDITOR nvim

alias gcc='gcc-12'
alias vi='nvim'

function ec2_up
  aws ec2 --profile saml start-instances --instance-ids $EC2_INSTANCE_ID
  aws ec2 --profile saml wait instance-running --instance-ids $EC2_INSTANCE_ID
  aws ec2 --profile saml wait instance-status-ok --instance-ids $EC2_INSTANCE_ID
end

function ec2_stop
  aws ec2 --profile saml stop-instances --instance-ids $EC2_INSTANCE_ID
  aws ec2 --profile saml wait instance-stopped --instance-ids $EC2_INSTANCE_ID
  aws ec2 --profile saml describe-instances --instance-ids $EC2_INSTANCE_ID
end

source /usr/local/opt/asdf/libexec/asdf.fish

