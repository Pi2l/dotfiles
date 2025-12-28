#!/bin/bash

has_swayosd() {
  command -v swayosd-client >/dev/null 2>&1
}

case "$1" in
has-swayosd)
  echo $(has_swayosd)
  ;;
*)
  echo default
  ;;
esac
