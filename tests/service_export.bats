#!/usr/bin/env bats
load test_helper

setup() {
  export ECHO_DOCKER_COMMAND="false"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  export ECHO_DOCKER_COMMAND="false"
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:export) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:export"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:export) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:export" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:export) success" {
  export ECHO_DOCKER_COMMAND="true"
  run dokku "$PLUGIN_COMMAND_PREFIX:export" l
  password="$(cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  assert_contains "${lines[-1]}" "docker exec dokku.couchdb.l bash -c DIR=\$(mktemp -d) && couchdb-backup -b -H localhost -d \"l\" -f \"\$DIR/l.json\" -u \"l\" -p \"$password\" > /dev/null && cat \"\$DIR/l.json\" && rm -rf \"\$DIR\""
}

