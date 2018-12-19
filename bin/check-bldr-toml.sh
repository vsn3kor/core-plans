#!/usr/bin/env bash
#
# pre-commit hook:
# Check for plans that don't have an entry in our .bldr.toml
#
# Authors:
# - Steven Danna <steve@chef.io>

set -eu
requested=("$@")

is_deprecated() {
  local deprecated
  plan_path=$1 

  if [[ "$(basename $1)" == "plan.sh" ]]; then 
    deprecated=$(source "$plan_path" && echo "$pkg_deprecated" 2>/dev/null)
  fi 

  if [[ "$deprecated" == "true" ]]; then
    return 0
  fi

  return 1
}
      


check_bldr_toml_for() {
  plan_path=$1
  plan_name=$(dirname "$plan_path")
  if ! grep -Eq "^\[$plan_name\]" .bldr.toml && 
    ! is_deprecated "$plan_path"
  then
    echo "No entry for ${plan_name} in .bldr.toml"
    exit 1
  fi
}

for plan in "${requested[@]}"; do
  check_bldr_toml_for "$plan"
done
