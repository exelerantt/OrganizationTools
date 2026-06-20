alias gitpresent='[ -d ".git" ] && echo "Git is present." || echo "Git is not present."'
alias gitremove='[ -d ".git" ] && rm -rf ".git" && echo "Removed Git." || echo "Git is not present".'
alias gitsync='git add ./* && git restore --staged ./* && git add ./*'
alias gitsyncundo='git restore --staged ./*'
export repository_directory="$HOME/Documents/github/Profile"

openrepository() {
    # $1 = repository type (Filesystem, Forked, Public)
    # $2 = open repository
    # $3 = open in vs code
    # $4 = open in finder/file explorer

    cd "$repository_directory"

    if [ -d "$1" ]; then
        cd "$1Repositories"

        if [ -d "$2" ]; then
            cd "$2"
        fi

        if [ -n "$3" ]; then
            # opens visual studio code on a new window
            if [ "$TERMINAL" == "code" ]; then
                code -r .
            else
                code -n .
            fi
        fi

        if [ -n "$4" ]; then
            # opens finder/file explorer
            open .
        fi
    fi
}

createrepository() {
    # $1 = repository name
    # $2 = create README

    cd "$repository_directory/FilesystemRepositories"

    mkdir "$1"
    git init "$1"

    if [ -d "$2" ]; then
cat << EOF > README.md
# $1

Add documentation **here**.

EOF
    fi
}