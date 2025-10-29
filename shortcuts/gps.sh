branch=$(git branch --show-current)
upstream=$(git rev-parse --abbrev-ref $branch@{upstream} 2>/dev/null)
if [[ $? == 0 ]]; then
echo $branch tracks $upstream
git push
else
echo $branch has no upstream configured
git push -u origin $branch
fi
