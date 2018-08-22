#!/bin/bash -ex

main() {
    rebase
    restore-commiters
    copy-resource
}

rebase() {
    pushd cc-ng-fork
        git checkout "$FORK_BRANCH"
        git remote add upstream "$UPSTREAM"

        git pull upstream $UPSTREAM_BRANCH --rebase
    popd
}

# This is necessary because git does not let you keep the committers after rebase
# This function restores them by parsing the 'Signed-off-by' message footer, if available
restore-commiters() {
    pushd cc-ng-fork
        diff=$(git rev-list --right-only --count upstream/$UPSTREAM_BRANCH..$FORK_BRANCH)
        start_commit=HEAD~"$diff"
        end_commit=HEAD

        git filter-branch --commit-filter '
            #!/bin/bash
            COMMIT_MESSAGE=$(git log --format=%B -n 1 $GIT_COMMIT);
            SIGNED_OFF=$(echo "$COMMIT_MESSAGE" | grep "Signed-off-by: " | sed "s/^.*: //" | head -n 1);
            if [ -z "$SIGNED_OFF" ]; then git commit-tree "$@" && return 0; fi
            FIRSTNAME=$(echo "$SIGNED_OFF" | cut -d " " -f 1);
            LASTNAME=$(echo "$SIGNED_OFF" | cut -d " " -f 2);
            export GIT_COMMITTER_NAME="${FIRSTNAME} ${LASTNAME}";
            export GIT_COMMITTER_EMAIL=$(echo "$SIGNED_OFF" | cut -d " " -f 3 | sed -e "s/^.//" -e "s/.$//")
            git commit-tree "$@";
            ' "$start_commit".."$end_commit"
    popd

}

copy-resource() {
    cp -r cc-ng-fork/. rebased-cc/
}

main

