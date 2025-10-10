upstream=$(git rev-parse --abbrev-ref $1@{upstream} 2>/dev/null)
if [[ $? == 0 ]]; then
echo $1 tracks $upstream
git push $1
else
echo $1 has no upstream configured
git push -u origin $1
fi
