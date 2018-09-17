# docker shortcuts / helpers / tool containers

# Docker tool containers
_docker_run_sock="docker run --rm -it --userns host -v /var/run/docker.sock:/var/run/docker.sock"
alias ctop="$_docker_run_sock --name=ctop quay.io/vektorlab/ctop"
alias dockviz="$_docker_run_sock --name=dockviz nate/dockviz"
unset _docker_run_sock
