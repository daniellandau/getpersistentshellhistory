# no hashbang as this is a polyglot script that needs to be passed explicitly to bash, zsh, or fish

if echo $0 | grep -qs bash
then
  if grep -qs -e "PROMPT_COMMAND=" ~/.bashrc
  then
    echo 'You already have a PROMPT_COMMAND installed, not overwriting' >&2
    exit 1
  fi
  echo '
# https://eli.thegreenplace.net/2013/06/11/keeping-persistent-history-in-bash
HISTTIMEFORMAT="%F %T "
log_bash_persistent_history()
{
  [[
    $(history 1) =~ ^\ *[0-9]+\ +([^\ ]+\ [^\ ]+)\ +(.*)$
  ]]
  local date_part="${BASH_REMATCH[1]}"
  local command_part="${BASH_REMATCH[2]}"
  if [ "$command_part" != "$PERSISTENT_HISTORY_LAST" ]
  then
    echo $date_part "|" "$command_part" >> ~/.persistent_history.$(hostname)
    export PERSISTENT_HISTORY_LAST="$command_part"
  fi
}

# Stuff to do on PROMPT_COMMAND
run_on_prompt_command()
{
  log_bash_persistent_history
}

PROMPT_COMMAND="run_on_prompt_command"
' >> ~/.bashrc
  echo "Installed persistent history settings to your .bashrc. Your persistent history will accumulate in ~/.persistent_history.`hostname`" >&2
  exit 0
fi

if echo $0 | grep -qs zsh
then
  if grep -qs -e "precmd()" ~/.zshrc
  then
    echo 'You already have a precmd installed, not overwriting' >&2
    exit 1
  fi
  echo '
# http://stackoverflow.com/questions/30249853/save-zsh-history-to-persistent-history
precmd() { # This is a function that will be executed before every prompt
  if [[ -e "$HISTFILE" ]]
  then
    local line_num_last=$(grep -ane "^:" "$HISTFILE" | tail -1 | cut -d':' -f1 | tr -d '\n')
    local date_part="$(gawk "NR == $line_num_last {print;}" "$HISTFILE" | cut -c 3-12)"
    local fmt_date="$(date -d @${date_part} +'%Y-%m-%d %H:%M:%S')"
    local command_part="$(gawk "NR >= $line_num_last {print;}" "$HISTFILE" | sed -re '1s/.{15}//')"
    if [ "$command_part" != "$PERSISTENT_HISTORY_LAST" ]
    then
      echo "${fmt_date} | ${command_part}"  >> ~/.persistent_history.$(hostname)
      export PERSISTENT_HISTORY_LAST="$command_part"
    fi
  fi
}
' >>~/.zshrc
  echo "Installed persistent history settings to your .zshrc. Your persistent history will accumulate in ~/.persistent_history.`hostname`" >&2
  exit 0
fi

if test -z "$FISH_VERSION"
then
  echo "This script works only with bash, zsh, and fish for now, please add support for your favorite shell!" >&2
  exit 2
fi


# at this point we are incompatible with bash/zsh/POSIX sh, but they don't get this far
end
end
end 
end
end

# fish
if type -q fish_right_prompt
  echo "You already have fish_right_prompt defined, not overwriting" >&2
else
  echo "\
function fish_right_prompt                                                   
  if set -q fish_private_mode
  else
    date '+%Y-%m-%d %H:%M:%S' | tr -d '\n' >> ~/.persistent_history.(hostname) 
    printf ' | ' >> ~/.persistent_history.(hostname)                           
    echo \$history[1] >> ~/.persistent_history.(hostname)                       
  end
end                                                                          
" >> ~/.config/fish/config.fish
  echo "Installed persistent history settings to your .config/fish/config.fish. Your persistent history will accumulate in ~/.persistent_history.(hostname)" >&2
end
