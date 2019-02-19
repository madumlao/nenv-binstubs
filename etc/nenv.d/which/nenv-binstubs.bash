#!/usr/bin/env bash

check_for_binstubs()
{
  local root
  local binpath
  local modules_binpath
  root="$PWD"
  binpath='bin'
  modules_binpath='node_modules/.bin'
  while [ -n "$root" ]; do
    if [ -f "$root/package.json" ] || [ -f "$root/package-lock.json" ]; then
      potential_path="$root/$modules_binpath/$NENV_COMMAND"
      if [ -x "$potential_path" ]; then
        NENV_COMMAND_PATH="$potential_path"
        return
      fi
      potential_path="$root/$binpath/$NENV_COMMAND"
      if [ -x "$potential_path" ]; then
        NENV_COMMAND_PATH="$potential_path"
        return
      fi
    fi
    root="${root%/*}"
  done

  # if shim / local version doesnt exist, default to system path
  if ! [ -x "$NENV_COMMAND_PATH" ]; then
    PATH="$(remove_from_path "${NENV_ROOT}/shims")"
    NENV_COMMAND_PATH="$(command -v "$NENV_COMMAND" || true)"
  fi
}

if [ -z "$DISABLE_BINSTUBS" ]; then
  check_for_binstubs
fi

