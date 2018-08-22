#!/usr/bin/env bash

add_to_bundles ()
{
  local root
  if [ "$1" ]; then
    root="$1"
  else
    root="$PWD"
  fi

  # update the list of bundles to remove any stale ones
  local new_bundle
  new_bundle=true
  new_bundles=${NENV_ROOT}/bundles.new.$$
  : > $new_bundles
  if [ -s ${NENV_ROOT}/bundles ]; then
    OLDIFS="${IFS:-$' \t\n'}"
    IFS=$'\n' bundles=(`cat ${NENV_ROOT}/bundles`)
    IFS="$OLDIFS"
    for bundle in "${bundles[@]}"; do
      if [ "X$bundle" = "X$root" ]; then
        new_bundle=false
      fi
      if [ -f "$bundle/package.json" ] || [ -f "$bundle/package-lock.json" ]; then
        echo "$bundle" >> $new_bundles
      fi
    done
  fi
  if [ "$new_bundle" = "true" ]; then
    # add the given path to the list of bundles
    if [ -f "$root/package.json" ] || [ -f "$root/package-lock.json" ] ; then
      echo "$root" >> $new_bundles
    fi
  fi
  mv -f $new_bundles ${NENV_ROOT}/bundles
}

if [ -z "$DISABLE_BINSTUBS" -a "X$1" = "Xbundle" ]; then
  add_to_bundles
fi

