if [[ $1 == "load" ]]; then
  git stash apply stash^{/$2}
  exit 0
elif [[ $1 == "push" ]]; then
  git stash push -m "$2"
fi
