#! /usr/bin/env bats

TEST_ARTIFACTS_DIR=

# Create a test artifacts directory in /tmp.
setup()
{
  TEST_ARTIFACTS_DIR="$(mktemp -d)"
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
  [[ "$output" =~  ^Usage: ]]
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
	local TEST_BASE
	TEST_BASE="$(mktemp -d)"
  run deja-dirs "foo" -b "${TEST_BASE}"
  rmdir "${TEST_BASE}"
  [ "$status" -eq 1 ]
  [ "$output" = "" ]
}

@test "Running with file input" {
	local FILE_MANIFEST
	FILE_MANIFEST="${TEST_ARTIFACTS_DIR}/example.txt"

	echo "/tmp" >> "${FILE_MANIFEST}"
	echo "/foobar" >> "${FILE_MANIFEST}"

	run deja-dirs -- -f "${FILE_MANIFEST}"
	[ "$status" -eq 0 ]
  [ "$output" = "'/tmp'" ]
}

@test "Running with file input and contains" {
	local FILE_MANIFEST
	FILE_MANIFEST="${TEST_ARTIFACTS_DIR}/example.txt"

	echo "${TEST_ARTIFACTS_DIR}/foo" >> "${FILE_MANIFEST}"
	echo "${TEST_ARTIFACTS_DIR}/bar" >> "${FILE_MANIFEST}"

	mkdir "${TEST_ARTIFACTS_DIR}/foo" "${TEST_ARTIFACTS_DIR}/bar"
	touch "${TEST_ARTIFACTS_DIR}/bar/file.txt"

	run deja-dirs -- -f "${FILE_MANIFEST}" -c "file.txt"
	[ "$status" -eq 0 ]
  [ "$output" = "'${TEST_ARTIFACTS_DIR}/bar'" ]
}
