#!/usr/bin/env -S bash -e

########################################################################################################################
# The purpose of this tool is to update the library versions in README.md
########################################################################################################################

PROJECT=$1
RELEASE_VERSION=$2
README=$3

if [ -z "$PROJECT" ]; then
	echo "ERROR: Project argument not supplied"
	exit 1
fi
if [ -z "$RELEASE_VERSION" ]; then
	echo "ERROR: Release version argument not supplied"
	exit 1
fi
if [ -z "$README" ]; then
	echo "ERROR: readme path not supplied"
	exit 1
fi
if ! [ -w "$README" ]; then
  echo "ERROR: '$README' is not a valid file"
  exit 1
fi

sed -E -i "s/^\*?Version: .*\*?$/*Version: ${RELEASE_VERSION} - $(date +%Y-%m-%d)*/" "$README"
sed -E -i -n "
/\s*<dependency>\s*/ {
  p;n;
  /<groupId>org\.hibernate[^\/]*<\/groupId>\s*/ {
    p;n;
    /<artifactId>hibernate[^\/]*<\/artifactId>\s*/ {
      p;n;
      s/(<version>)[^\/]+(<\/version>)/\1${RELEASE_VERSION}\2/
    }
  }
}
p;d;
" "$README"

if [ -n "$(git status --porcelain)" ]; then
  git add "$README"
  git commit -m "[Jenkins release job] README.md updated by release build ${RELEASE_VERSION}"
fi
