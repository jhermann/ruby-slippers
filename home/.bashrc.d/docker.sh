# docker shortcuts / helpers / tool containers

# Docker tool containers
_docker_run_sock="docker run --rm -it --userns host -v /var/run/docker.sock:/var/run/docker.sock"
alias ctop="$_docker_run_sock --name=ctop quay.io/vektorlab/ctop"
alias dockviz="$_docker_run_sock --name=dockviz nate/dockviz"
unset _docker_run_sock

alias dvi="dockviz images --tree -l --show-created-by"


## https://www.calazan.com/docker-cleanup-commands/

# Kill all running containers
alias docker-kill-all='docker kill $(docker ps -q)'

# Delete all stopped containers
alias docker-cleanc='printf "\n>>> Deleting stopped containers\n\n" && docker rm $(docker ps -a -q)'

# Delete all untagged images
alias docker-cleani='printf "\n>>> Deleting untagged images\n\n" && docker rmi $(docker images -q -f dangling=true)'

# Delete all stopped containers and untagged images
alias docker-clean='( docker-cleanc ; docker-cleani )'
