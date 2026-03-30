#!/bin/bash

# terminate script
die() {
	echo "$1" >&2
	exit 1
}

mkdir logs/ || die "Could not create directory"
aws s3 cp --no-sign-request --endpoint-url=https://s3.ap-southeast-2.wasabisys.com --recursive s3://cdn-bioinf-logs/ logs/ || die "Could not download from wasabi"

cat logs/* | grep "slorado" | grep "REST.GET.OBJECT" | grep " 200 " | wc -l > slorado.txt

git config --global user.email "action@github.com" || die "Failed to configure git email"
git config --global user.name "GitHub Action" || die "Failed to configure git name"
if ! git diff --cached --quiet slorado.txt; then
	git add slorado.txt || die "adding failed"
    git commit -m "Update download counts" || die "commit failed"
	git push || die "push failed"
fi
