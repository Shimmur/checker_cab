#!/bin/bash -e

function replace_in_file {
  local _to_replace="$1"
  local _replacement="$2"
  local _file="$3"
  local _sed_path=$(which sed)

  if [[ $OSTYPE == "darwin"* && $_sed_path =~ "gnu-sed" ]]; then
    sed -i "s/$_to_replace/$_replacement/g" "$_file"
  else
    sed -i '' "s/$_to_replace/$_replacement/g" "$_file"
  fi
}

function replace_everywhere {
  local _to_replace="$1"
  local _replacement="$2"

  local _current_script_filename=$(basename "$0")
  for file in `grep --exclude "$_current_script_filename" --exclude-dir={_build,deps} -rli "$_to_replace" *`; do

    replace_in_file "$_to_replace" "$_replacement" $file
  done

  echo "Replaced '$_to_replace' with '$_replacement' in all files"
}

APP_NAME="${1}"
MODULE_NAME="${2}"
UPPERCASE_APP_NAME=$(echo ${APP_NAME} | awk '{print toupper($0)}')

if [ -z "$APP_NAME" ]; then
  echo "Missing first argument, which is the app name (such as abc_handler)" && exit 1
fi

if [ -z "$MODULE_NAME" ]; then
  echo "Missing second argument, which is the module name (such as ABCHandler)" && exit 1
fi

replace_everywhere cookie_cutter "$APP_NAME"
replace_everywhere COOKIE_CUTTER "$UPPERCASE_APP_NAME"
replace_everywhere CookieCutter "$MODULE_NAME"
replace_everywhere 'elixir-lib-cookie-cutter' "${APP_NAME}"

# Grep ignores .gitignore
replace_in_file cookie_cutter "${APP_NAME}" .gitignore

git mv lib/cookie_cutter.ex "lib/${APP_NAME}.ex"

rm "$0"
