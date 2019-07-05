#!/bin/bash
shopt -s nullglob

ENVIRONMENTS=( hosts/* )
ENVIRONMENTS=( "${ENVIRONMENTS[@]##*/}" )

show_usage() {
  echo "Usage: uploads <environment> <site name> <mode>

<environment> is the environment to compare upload directories with ("staging", "production", etc)
<site name> is the WordPress site to transfer uploads between (name defined in "wordpress_sites")
<mode> is is either "push" or "pull" to send or receive uploads from the environment to the local development envronment.

Available environments:
`( IFS=$'\n'; echo "${ENVIRONMENTS[*]}" )`

Examples:
  uploads staging example.com push
  uploads production example.com pull
"
}

[[ $# -lt 2 ]] && { show_usage; exit 127; }

for arg
do
  [[ $arg = -h ]] && { show_usage; exit 0; }
done

ENV="$1"; shift
SITE="$1"; shift
MODE="$1"; shift
DEPLOY_CMD="ansible-playbook uploads.yml -i hosts/$ENV -e site=$SITE -e mode=$MODE"
HOSTS_FILE="hosts/$ENV"

if [[ ! -e $HOSTS_FILE ]]; then
  echo "Error: $ENV is not a valid environment ($HOSTS_FILE does not exist)."
  echo
  echo "Available environments:"
  ( IFS=$'\n'; echo "${ENVIRONMENTS[*]}" )
  exit 1
fi

$DEPLOY_CMD
