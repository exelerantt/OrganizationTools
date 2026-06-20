export organization_directory="$HOME/Documents/github/Organizations"
export organization_defaultgitclone="Example-Organization"

createorganization() {
    # $1 = organization name
    # $2 = use .github and .github-private
    # $3 = organization TO fork .github and .github-private to

    # ew hard coded stuff
    # wahtever this is easy to change
    githubdefault_organization="${3:-$organization_defaultgitclone}"

    cd $organization_directory
    mkdir -p "$1"
    cp -r Example-Organization/* "$1"

    if [ -n "$2" ] && [ -n "$3" ]; then
        cp -r "$githubdefault_organization/.github" "$githubdefault_organization/.github-private" "$1"
    elif ! [ -n "$2" ] then
        rm -rf ".github" && rm -rf ".github-private"
    fi
}

addorganization() {
    # $1 = fetched organization name

    cd $organization_directory
    mkdir -p "$1"
    cp -r Example-Organization/* "$1" && cd "$1"

    if gh repo view "$1"/.github >/dev/null 2>&1 && ! [ -d ".github" ]; then
        gh repo clone "$1"/.github
    fi

    if gh repo view "$1"/.github-private >/dev/null 2>&1 && ! [ -d ".github-private" ]; then
        gh repo clone "$1"/.github-private
    fi

    cd PublicRepositories
    gh repo list "$1" --limit 1000 --visibility public --source --json url --jq '.[] | select(.url | test("\\.(github|github-private)$") | not) | .url' | xargs -L 1 git clone
    cd ..

    cd PrivateRepositories
    gh repo list "$1" --limit 1000 --visibility private --json url --jq '.[] | select(.url | test("\\.(github|github-private)$") | not) | .url' | xargs -L 1 git clone
    cd ..

    cd ForkedRepositories
    gh repo list "$1" --limit 1000 --fork --json url --jq '.[] | select(.url | test("\\.(github|github-private)$") | not) | .url' | xargs -L 1 git clone
    cd ..
}

removeorganization() {
    # $1 = organization name

    cd "$HOME/Documents/github/Organizations"
    rm -rf "$1"
}

updateorganization() {
    # $1 = fetched organization name
    # $2 = whether to update .github and .github-private or not

    cd "$organization_directory/$1"

    if [ -n "$2" ]; then
        if gh repo view "$1"/.github >/dev/null 2>&1 && ! [ -d ".github" ]; then
            gh repo clone "$1"/.github
        fi

        if gh repo view "$1"/.github-private >/dev/null 2>&1 && ! [ -d ".github-private" ]; then
            gh repo clone "$1"/.github-private
        fi
    fi 

    # --- Public Repositories ---
    cd PublicRepositories
    gh repo list "$1" --limit 1000 --visibility public --source --json url,name --jq '.[] | select(.url | test("\\.(github|github-private)$") | not) | "\(.url) \(.name)"' | \
    while read -r url name; do
        if [ ! -d "$name" ]; then
            git clone "$url"
        fi
    done
    cd ..

    # --- Private Repositories ---
    cd PrivateRepositories
    gh repo list "$1" --limit 1000 --visibility private --json url,name --jq '.[] | select(.url | test("\\.(github|github-private)$") | not) | "\(.url) \(.name)"' | \
    while read -r url name; do
        if [ ! -d "$name" ]; then
            git clone "$url"
        fi
    done
    cd ..

    # --- Forked Repositories ---
    cd ForkedRepositories
    gh repo list "$1" --limit 1000 --fork --json url,name --jq '.[] | select(.url | test("\\.(github|github-private)$") | not) | "\(.url) \(.name)"' | \
    while read -r url name; do
        if [ ! -d "$name" ]; then
            git clone "$url"
        fi
    done
    cd ..

}

openorganization() {
    # $1 = organization (could be nil)
    # $2 = open in vs code
    # $3 = open in finder/file explorer

    cd "$organization_directory"

    if [ -d "$1" ]; then
        cd "$organization_directory/$1"

        if [ -n "$2" ]; then
            # opens visual studio code on a new window
            if [ "$TERMINAL" == "code" ]; then
                code -r .
            else
                code -n .
            fi
        fi

        if [ -n "$3" ]; then
            # opens finder/file explorer
            open .
        fi
    fi
}

syncorganizations() {
    # $1 = whether to update .github and .github-private or not
    openorganization

    gh api user/orgs --jq '.[].login' | while read -r name; do
        if [ ! -d "$name" ]; then
            addorganization $name
        else
            if [ -z "$1" ]; then
                updateorganization "$name" "$1"
            else
                updateorganization "$name"
            fi
        fi
    done

    openorganization
}