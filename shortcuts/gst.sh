if [[ $1 == "load" ]]; then
  git stash apply stash^{/$2}
  exit 0
fi
git stash push -m "$2"
