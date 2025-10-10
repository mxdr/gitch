branch_exists=$(git rev-parse --abbrev-ref $1 2>/dev/null)
if [[ $? == 0 ]]; then
echo $1 exists ($branch_exists), checking it out
git checkout $1
else
echo branch $1 does not exist, creating it
git checkout -b $1
fi
