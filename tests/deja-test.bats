#! /usr/bin/env bats

TEST_ARTIFACTS_DIR="/tmp/deja-test-artifacts"

# Create a test artifacts directory in /tmp.
setup()
{
  if [[ -e "${TEST_ARTIFACTS_DIR}" ]]
  then
    echo "The test artifacts directory '${TEST_ARTIFACTS_DIR}' already exists" 1>&2
    return 1
  fi

  mkdir "${TEST_ARTIFACTS_DIR}"
}

# Remove any test files and directories.
teardown()
{
  if [[ -e "${TEST_ARTIFACTS_DIR}" ]]
  then
    rm -rf "${TEST_ARTIFACTS_DIR}"
  fi
}

@test "Running without arguments gives usage" {
  run deja-dirs
  [ "$status" -eq 1 ]
  [ "$output" =  "Usage: deja-dirs name [-c contains] [-b basedir]" ]
}

@test "Running with a basic directory" {
  mkdir "${TEST_ARTIFACTS_DIR}/foo"
  run deja-dirs "foo" -b "${TEST_ARTIFACTS_DIR}"
  [ "$status" -eq 0 ]
  [ "$output" = "'${TEST_ARTIFACTS_DIR}/foo'" ]
}

@test "Running with a complex directory" {
  mkdir "${TEST_ARTIFACTS_DIR}/foo bar"
  run deja-dirs "foo bar" -b "${TEST_ARTIFACTS_DIR}"
  [ "$status" -eq 0 ]
  [ "$output" = "'${TEST_ARTIFACTS_DIR}/foo bar'" ]
}

@test "Running with a nested directory" {
  mkdir "${TEST_ARTIFACTS_DIR}/foo"
  mkdir -p "${TEST_ARTIFACTS_DIR}/baz/foo"
  run deja-dirs "foo" -b "${TEST_ARTIFACTS_DIR}"
  [ "$status" -eq 0 ]
  [ "$output" = "'${TEST_ARTIFACTS_DIR}/baz/foo', '${TEST_ARTIFACTS_DIR}/foo'" ]
}

@test "Running with a directory containing single quotes" {
  mkdir "${TEST_ARTIFACTS_DIR}/foo'bar"
  run deja-dirs "foo'bar" -b "${TEST_ARTIFACTS_DIR}"
  [ "$status" -eq 0 ]
  [ "$output" = "'${TEST_ARTIFACTS_DIR}/foo\'bar'" ]
}

@test "Running with a directory containing double quotes" {
  mkdir "${TEST_ARTIFACTS_DIR}/foo\"bar"
  run deja-dirs "foo\"bar" -b "${TEST_ARTIFACTS_DIR}"
  [ "$status" -eq 0 ]
  [ "$output" = "'${TEST_ARTIFACTS_DIR}/foo\\\"bar'" ]
}

@test "Running with a directory containing a file (failure)" {
  mkdir "${TEST_ARTIFACTS_DIR}/bar"
  run deja-dirs "bar" -b "${TEST_ARTIFACTS_DIR}" -c "foo.txt"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "Running with a directory containing a file (success)" {
  mkdir "${TEST_ARTIFACTS_DIR}/bar"
  touch "${TEST_ARTIFACTS_DIR}/bar/foo.txt"
  run deja-dirs "bar" -b "${TEST_ARTIFACTS_DIR}" -c "foo.txt"
  [ "$status" -eq 0 ]
  [ "$output" = "'${TEST_ARTIFACTS_DIR}/bar'" ]
}

@test "Running with a different base" {
  mkdir "${TEST_ARTIFACTS_DIR}-1"
  run deja-dirs "foo" -b "${TEST_ARTIFACTS_DIR}-1"
  rmdir "${TEST_ARTIFACTS_DIR}-1"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}
