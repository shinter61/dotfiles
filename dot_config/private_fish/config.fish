if status is-interactive
    # Commands to run in interactive sessions can go here
end

# colorscheme
# ref: https://github.com/folke/tokyonight.nvim/blob/main/extras/fish/tokyonight_night.fish

# TokyoNight Color Palette
set -l foreground c0caf5
set -l selection 283457
set -l comment 565f89
set -l red f7768e
set -l orange ff9e64
set -l yellow e0af68
set -l green 9ece6a
set -l purple 9d7cd8
set -l cyan 7dcfff
set -l pink bb9af7

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment
set -g fish_pager_color_selected_background --background=$selection

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

if test (uname) = "Darwin"
  source /usr/local/opt/asdf/libexec/asdf.fish
else if test (uname) = "Linux"
  source $HOME/.asdf/asdf.fish
end

# go packages用
if test -d (go env GOPATH)/bin
  fish_add_path (go env GOPATH)/bin
end

