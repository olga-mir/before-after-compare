#!/bin/bash

# provide the output directory for your project
DATA_OUTPUT_LOCATION="./my_project_output"

# script or command how to run you project e.g. "npm run build 2>&1 | tee run.log"
RUN_CMD="./run.sh"

# how to cleanup your project between the runs
# if not required provide empty string ""
CLEANUP_CMD="./cleanup.sh"

# If your project output contains dynamic data that may change between the runs independently of the code
# like timestamps, provide a script to strip this data prior to compare
# if not required provide empty string ""
PREPARE_FOR_COMPARE_CMD="./parse.sh"

# test directories start with fixed prefix and randomly generated string
TEST_DIR_PREFIX="vvv_"
