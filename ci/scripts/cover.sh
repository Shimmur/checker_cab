#!/bin/sh

if [ -z "${COVERALLS_REPO_TOKEN}" ]; then
	echo "Missing COVERALLS_REPO_TOKEN env var, please set in the CI system"
	exit 1
fi

if [ -f  /otp/app/.git/resource/head_sha ]; then
  # By now we have used git-pr to build a repo with one branch (master)
  # and all of the commits in it. To get to the meta-data for the PR we
  # need to do this ... (https://trits.ch/2UQz74j)
  export GIT_COMMIT="$(cat /otp/app/.git/resource/head_sha)"
  export GIT_COMMITTER="$(cat /otp/app/.git/resource/author)"
  export GIT_BRANCH="$(cat /otp/app/.git/resource/head_name)"
  export GIT_MESSAGE="$(cat /otp/app/.git/resource/message)"
else
  export GIT_COMMIT="$(git rev-parse HEAD)"
  export GIT_COMMITTER="$(git log -1 $GIT_COMMIT --pretty=format:'%cN')"
  export GIT_BRANCH="$(git name-rev --name-only HEAD)"
  export GIT_MESSAGE="$(git log -1 $GIT_COMMIT --pretty=format:'%s')"
fi

echo "Uploading coverage report to coveralls.io ..."
echo "- Commit: $GIT_COMMIT"
echo "- Committer: $GIT_COMMITTER"
echo "- Branch: $GIT_BRANCH"
echo "- Message: $GIT_MESSAGE"

export MIX_ENV=test
mix coveralls.post \
  --token "$COVERALLS_REPO_TOKEN" \
  --sha "$GIT_COMMIT" \
  --committer "$GIT_COMMITTER" \
  --branch "$GIT_BRANCH" \
  --message "$GIT_MESSAGE"
