## Function to show a segment
function prompt_segment -d "Function to show a segment"
  # Get colors
  set -l bg $argv[1]
  set -l fg $argv[2]

  # Set 'em
  set_color -b $bg
  set_color $fg

  # Print text
  if [ -n "$argv[3]" ]
    echo -n -s $argv[3]
  end
end

## Function to show current status
function show_status -d "Function to show the current status"
  if [ $RETVAL -ne 0 ]
    prompt_segment red white " ▲ "
    end
  if [ -n "$SSH_CLIENT" ]
      prompt_segment blue white " SSH: "
  end
end

## Show user if not in default users
function show_user -d "Show user"
  prompt_segment normal yellow ""
  # Narrow terminals (split panes) can't afford user@host: once the prompt is
  # as wide as the terminal, fish truncates it and repaints the whole prompt on
  # every keystroke instead of updating in place.
  if set -q COLUMNS; and test $COLUMNS -lt 80
    return
  end

  if not contains $USER $default_user; or test -n "$SSH_CLIENT"
    # Each half is only worth the space when it carries information: the name
    # when it isn't the default user, the host when we're remote. The @ always
    # stays, so `root@` and `@devserver` still read as user/host.
    set -l who (whoami)
    contains $USER $default_user; and set who ""

    set -l host ""
    test -n "$SSH_CLIENT"; and set host (hostname -s)

    prompt_segment normal yellow " $who"
    prompt_segment normal white "@"
    if [ -n "$host" ]
      prompt_segment normal green "$host "
    end
  end
end

function _set_venv_project --on-variable VIRTUAL_ENV
    if test -e $VIRTUAL_ENV/.project
        set -g VIRTUAL_ENV_PROJECT (cat $VIRTUAL_ENV/.project)
    end
end

# Show directory
function show_pwd -d "Show the current directory"
  set -l pwd
  if [ (string match -r '^'"$VIRTUAL_ENV_PROJECT" $PWD) ]
    set pwd (string replace -r '^'"$VIRTUAL_ENV_PROJECT"'($|/)' '≫ $1' $PWD)
  else
    set pwd (prompt_pwd)
  end
  prompt_segment normal blue " $pwd "
end

# Show prompt w/ privilege cue
function show_prompt -d "Shows prompt with cue for current priv"
  set -l uid (id -u $USER)
    if [ $uid -eq 0 ]
    prompt_segment red white " ! "
    set_color normal
    echo -n -s " "
  else
    prompt_segment normal white " \$ "
    end

  set_color normal
end

## SHOW PROMPT
function fish_prompt
  set -g RETVAL $status
  show_status
  show_user
  show_pwd
  show_prompt
end
