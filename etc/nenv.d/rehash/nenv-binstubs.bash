#!/usr/bin/env bash

register_binstubs()
{
  local root
  local binpath
  local modules_binpath
  if [ "$1" ]; then
    root="$1"
  else
    root="$PWD"
  fi
  binpath='bin'
  modules_binpath='node_modules/.bin'
  while [ -n "$root" ]; do
    if [ -f "$root/package.json" ]; then
      for shim in $root/$binpath/* $root/$modules_binpath/*; do
        if [ -x "$shim" ]; then
          register_shim "${shim##*/}"
        fi
      done
      IFS="$OLD_IFS"
      break
    fi
    root="${root%/*}"
  done
}

register_bundles ()
{
  # go through the list of bundles and run make_shims
  if [ -f "${NENV_ROOT}/bundles" ]; then
    OLDIFS="${IFS-$' \t\n'}"
    IFS=$'\n' bundles=(`cat ${NENV_ROOT}/bundles`)
    IFS="$OLDIFS"
    for bundle in "${bundles[@]}"; do
      register_binstubs "$bundle"
    done
  fi
}

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
    OLDIFS="${IFS-$' \t\n'}"
    IFS=$'\n' bundles=(`cat ${NENV_ROOT}/bundles`)
    IFS="$OLDIFS"
    for bundle in "${bundles[@]}"; do
      if [ "X$bundle" = "X$root" ]; then
        new_bundle=false
      fi
      if [ -f "$bundle/package.json" ]; then
        echo "$bundle" >> $new_bundles
      fi
    done
  fi
  if [ "$new_bundle" = "true" ]; then
    # add the given path to the list of bundles
    if [ -f "$root/package.json" ]; then
      echo "$root" >> $new_bundles
    fi
  fi
  mv -f $new_bundles ${NENV_ROOT}/bundles
}

if [ -z "$DISABLE_BINSTUBS" ]; then
  add_to_bundles
  register_bundles
fi

