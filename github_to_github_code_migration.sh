#!/bin/bash

read -p "Org Repo URL: " ORG_REPO
read -p "Client Repo URL: " CLIENT_REPO
read -p "Org Branch: " ORG_BRANCH
read -p "Client Branch: " CLIENT_BRANCH

REPO_DIR=$(basename "$ORG_REPO" .git)

if [ ! -d "$REPO_DIR/.git" ]; then
    git clone "$ORG_REPO"
fi

cd "$REPO_DIR" || exit 1

if git remote get-url client >/dev/null 2>&1; then
    git remote set-url client "$CLIENT_REPO"
else
    git remote add client "$CLIENT_REPO"
fi

git fetch origin
git fetch client

git checkout "$ORG_BRANCH"

git reset --hard "client/$CLIENT_BRANCH"

# Preserve CI/CD
git restore --source="origin/$ORG_BRANCH" .github/workflows

git add .
git commit -m "Sync client $CLIENT_BRANCH while preserving CI/CD" || true

read -p "Push to origin/$ORG_BRANCH? (y/n): " CONFIRM

if [[ "$CONFIRM" == "y" ]]; then
    git push origin "$ORG_BRANCH" --force-with-lease
    echo "Done."
else
    echo "Push cancelled."
fi
