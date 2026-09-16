#!/bin/sh
# version.sh — the lane, version, build number and full version of the build
# being made from this checkout.
#
# Vendored from laugga/ops, share/version/. Edit it there, never in a copy: a
# copy has to stay byte-identical to ops's for a stale one to be detectable.
#
# The rules are CONVENTIONS.md → Versioning, in laugga/ops. This is their one
# implementation; nothing else in a repository should work out a version.
# POSIX sh and git only, so every ecosystem can run it.
#
#   version.sh [-C <dir>]                    all of it, as KEY=value lines
#   version.sh [-C <dir>] <field>            one value: lane, version,
#                                            build-number, full-version, commit
#   version.sh [-C <dir>] check-deployable   exit 1, saying why, if the tree
#                                            has uncommitted changes or HEAD
#                                            isn't pushed — make deploy's guard
#
# The KEY=value lines are safe to eval; no value holds anything but
# [0-9A-Za-z.+-]:
#
#   out=$(path/to/version.sh) || exit 1
#   eval "$out"
#   echo "$LANE $VERSION $BUILD_NUMBER $FULL_VERSION $COMMIT"
#
# What is being built — a tag or a branch — comes from CI when CI says, and
# from git otherwise. First match wins, tag before branch:
#
#   tag      VERSION_TAG; CI_TAG (Xcode Cloud); GITHUB_REF_NAME when
#            GITHUB_REF_TYPE=tag (GitHub Actions)
#   branch   VERSION_BRANCH; CI_PULL_REQUEST_SOURCE_BRANCH, CI_BRANCH (Xcode
#            Cloud); GITHUB_HEAD_REF, or GITHUB_REF_NAME when
#            GITHUB_REF_TYPE=branch (GitHub Actions); the checked-out branch
#   neither  HEAD is detached: a release tag on HEAD if there is one, else a
#            working build labelled `detached`
#
# Also read:
#
#   CI_BUILD_NUMBER             Xcode Cloud's counter, used for beta and rc
#                               only — the builds App Store Connect receives,
#                               which carry Xcode Cloud's number regardless
#   VERSION_BUILD_NUMBER        the build number, outright
#   VERSION_TASK_PREFIXES       task id prefixes looked for in a branch name;
#                               default "LM OPS"
#   VERSION_INTEGRATION_BRANCH  the integration line, when it is neither
#                               `dev` nor the default branch
#   VERSION_DIRTY_EXCLUDE       colon-separated paths, inside the repository,
#                               whose changes don't count as uncommitted — the
#                               files a build writes the version into
set -eu
set -f # tag and branch names are never globs

die() { echo "version.sh: $*" >&2; exit 1; }
matches() { printf '%s\n' "$1" | grep -Eq "$2"; }

# The tags a build can be made from. `alpha` is retired, but the alpha tags
# already cut are still history a version can be derived from.
RELEASE_TAG='^[0-9]+\.[0-9]+\.[0-9]+(-(beta|rc)\.[0-9]+)?$'
HISTORICAL_TAG='^[0-9]+\.[0-9]+\.[0-9]+(-(alpha|beta|rc)\.[0-9]+)?$'
FINAL='^[0-9]+\.[0-9]+\.[0-9]+$'

if [ "${1:-}" = -C ]; then
  [ -n "${2:-}" ] || die "-C needs a directory"
  cd "$2" || die "cannot cd to $2"
  shift 2
fi
case ${1:-} in
  ''|lane|version|build-number|full-version|commit|check-deployable) ;;
  *) die "unknown argument '$1' — lane, version, build-number, full-version, commit or check-deployable" ;;
esac
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "$(pwd) is not a git checkout"
cd "$(git rev-parse --show-toplevel)"

# Uncommitted changes to tracked files — what `git describe --dirty` means.
# Untracked files don't count, or build output nobody ignored would mark every
# build dirty. The one definition of dirty, for the full version and for
# make deploy's guard alike.
is_dirty() {
  set --
  old_ifs=$IFS
  IFS=:
  for p in ${VERSION_DIRTY_EXCLUDE:-}; do
    [ -z "$p" ] || set -- "$@" ":(exclude)$p"
  done
  IFS=$old_ifs
  [ -n "$(git status --porcelain --untracked-files=no -- . "$@")" ]
}

if [ "${1:-}" = check-deployable ]; then
  ! is_dirty || die "not deploying: uncommitted changes — commit and push them first"
  b=$(git symbolic-ref -q --short HEAD) || die "not deploying: HEAD is detached — build from a pushed branch"
  git rev-parse -q --verify '@{upstream}' >/dev/null 2>&1 \
    || die "not deploying: $b has no upstream — git push -u origin $b"
  n=$(git rev-list --count '@{upstream}..HEAD')
  [ "$n" = 0 ] || die "not deploying: $n commit(s) on $b not pushed — git push"
  exit 0
fi

COMMIT=$(git rev-parse HEAD)
sha=$(git rev-parse --short=7 HEAD)

tag=${VERSION_TAG:-${CI_TAG:-}}
if [ -z "$tag" ] && [ "${GITHUB_REF_TYPE:-}" = tag ]; then tag=${GITHUB_REF_NAME:-}; fi
branch=
if [ -z "$tag" ]; then
  branch=${VERSION_BRANCH:-${CI_PULL_REQUEST_SOURCE_BRANCH:-${CI_BRANCH:-${GITHUB_HEAD_REF:-}}}}
  if [ -z "$branch" ] && [ "${GITHUB_REF_TYPE:-}" = branch ]; then branch=${GITHUB_REF_NAME:-}; fi
  [ -n "$branch" ] || branch=$(git symbolic-ref -q --short HEAD || true)
fi
if [ -z "$tag$branch" ]; then
  # Detached, and nothing says what is being built. A checked-out release tag
  # is the one case with a clear answer. The final tag wins, then rc, then
  # beta: an approved rc's commit carries its final X.Y.Z as well.
  for t in $(git tag --points-at HEAD); do
    matches "$t" "$RELEASE_TAG" || continue
    if matches "$t" "$FINAL"; then tag=$t; break; fi
    case $t in
      *-rc.*) tag=$t ;;
      *) [ -n "$tag" ] || tag=$t ;;
    esac
  done
fi

# The nearest release-format tag reachable from HEAD, suffix stripped. Nearest
# rather than highest, so a line only ever sees its own tags — which is why no
# tag may sit on a commit two lines share.
latest_version() {
  excl=
  while :; do
    t=$(git describe --tags --abbrev=0 --match '[0-9]*' $excl HEAD 2>/dev/null) || { echo 0.0.0; return; }
    if matches "$t" "$HISTORICAL_TAG"; then echo "${t%%-*}"; return; fi
    excl="$excl --exclude=$t"
  done
}

# `dev` when the repository has one; its default branch when it doesn't.
integration_branch() {
  if [ -n "${VERSION_INTEGRATION_BRANCH:-}" ]; then echo "$VERSION_INTEGRATION_BRANCH"; return; fi
  if [ "$branch" = dev ] \
    || git show-ref -q --verify refs/heads/dev \
    || git show-ref -q --verify refs/remotes/origin/dev; then
    echo dev
    return
  fi
  d=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || true)
  d=${d#origin/}
  echo "${d:-main}"
}

# A working branch's label: the task id in its name — `feature/LM-611-slug` →
# LM-611 — or, without one, the branch name made safe for a version string.
label() {
  lower=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  prefixes=$(printf '%s' "${VERSION_TASK_PREFIXES:-LM OPS}" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/[[:space:]]+/|/g')
  id=$(printf '%s\n' "$lower" | sed -nE "s#^(.*/)?(($prefixes)-[0-9]+)([-/].*)?\$#\2#p")
  if [ -n "$id" ]; then
    printf '%s' "$id" | tr '[:lower:]' '[:upper:]'
  else
    printf '%s' "$1" | sed -E 's/[^0-9A-Za-z.]+/-/g; s/^-+//; s/-+$//'
  fi
}

if [ -n "$tag" ]; then
  matches "$tag" "$RELEASE_TAG" \
    || die "tag '$tag' is not X.Y.Z, X.Y.Z-beta.N or X.Y.Z-rc.N (CONVENTIONS.md → Versioning)"
  if t_commit=$(git rev-parse -q --verify "refs/tags/$tag^{commit}"); then
    [ "$t_commit" = "$COMMIT" ] || die "building tag $tag, but HEAD is not the commit it points at"
  fi
  VERSION=${tag%%-*}
  case $tag in
    *-beta.*) LANE=beta;   FULL_VERSION=$tag ;;
    *-rc.*)   LANE=rc;     FULL_VERSION=$VERSION ;;
    *)        LANE=public; FULL_VERSION=$VERSION ;;
  esac
elif [ -n "$branch" ]; then
  case $branch in
    release/*)
      VERSION=${branch#release/}
      matches "$VERSION" "$FINAL" || die "release branch '$branch' is not named release/X.Y.Z"
      LANE=integration
      FULL_VERSION=release-$VERSION+$sha
      ;;
    *)
      VERSION=$(latest_version)
      if [ "$branch" = "$(integration_branch)" ]; then
        LANE=integration
        FULL_VERSION=dev+$sha
      else
        LANE=working
        FULL_VERSION=$(label "$branch")+$sha
      fi
      ;;
  esac
else
  VERSION=$(latest_version)
  LANE=working
  FULL_VERSION=detached+$sha
fi

if [ -n "${VERSION_BUILD_NUMBER:-}" ]; then
  BUILD_NUMBER=$VERSION_BUILD_NUMBER
elif [ -n "${CI_BUILD_NUMBER:-}" ] && { [ "$LANE" = beta ] || [ "$LANE" = rc ]; }; then
  BUILD_NUMBER=$CI_BUILD_NUMBER
else
  [ "$(git rev-parse --is-shallow-repository)" != true ] \
    || die "shallow clone: the commit count would be wrong — git fetch --unshallow, or set VERSION_BUILD_NUMBER"
  BUILD_NUMBER=$(git rev-list --count HEAD)
fi
matches "$BUILD_NUMBER" '^[0-9]+$' || die "build number '$BUILD_NUMBER' is not a whole number"

if is_dirty; then FULL_VERSION=$FULL_VERSION-dirty; fi
matches "$FULL_VERSION" '^[0-9A-Za-z.+-]+$' || die "full version '$FULL_VERSION' has characters it shouldn't"

case ${1:-} in
  '')
    printf 'LANE=%s\nVERSION=%s\nBUILD_NUMBER=%s\nFULL_VERSION=%s\nCOMMIT=%s\n' \
      "$LANE" "$VERSION" "$BUILD_NUMBER" "$FULL_VERSION" "$COMMIT"
    ;;
  lane)         echo "$LANE" ;;
  version)      echo "$VERSION" ;;
  build-number) echo "$BUILD_NUMBER" ;;
  full-version) echo "$FULL_VERSION" ;;
  commit)       echo "$COMMIT" ;;
esac
