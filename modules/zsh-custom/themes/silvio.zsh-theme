if [ $USER = "root" ];
then
  local user='%{$fg[red]%}%n@%{$fg[red]%}%m%{$reset_color%}'
  local pwd='%{$fg[red]%}%~%{$reset_color%}'
else
  local user='%{$fg[blue]%}%n@%{$fg[blue]%}%m%{$reset_color%}'
  local pwd='%{$fg[blue]%}%~%{$reset_color%}'
fi

PROMPT="${user} ${pwd}$ "
