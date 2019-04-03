if [ $USER = "root" ];
then
  local user="%{$fg[red]%}%n@%{$fg[red]%}%m%{$reset_color%}"
else
  local user="%{$fg_bold[blue]%}%n@%m%{$reset_color%}"
fi

PROMPT='${user} \$ '
