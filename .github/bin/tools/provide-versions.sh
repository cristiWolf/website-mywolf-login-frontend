source "$(dirname "$0")/tools/convco.sh"

VERSION_CURRENT=$($CONVCO_CMD version)
export VERSION_CURRENT

VERSION_NEXT_PRE_RELEASE=$($CONVCO_CMD version --bump --prerelease beta)
export VERSION_NEXT_PRE_RELEASE

VERSION_NEXT_MINOR=$($CONVCO_CMD version --bump --minor)
export VERSION_NEXT_MINOR

VERSION_NEXT=$($CONVCO_CMD version --bump)
export VERSION_NEXT

BRANCH_CURRENT=$(git rev-parse --abbrev-ref HEAD)
export BRANCH_CURRENT