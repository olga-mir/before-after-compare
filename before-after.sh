#!/bin/sh
set -e

. config.sh

main() {

ORIG="orig" # dir to store original data
PROC="proc" # dir to store processed data

while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--setup)
      SETUP=1
      ;;
    -b|--branch)
      BRANCH1=$2; shift
      BRANCH2=$2; shift
      ;;
    -m|--master)
      BRANCH1=$2; shift
      ;;
    -l|--label)
      LABEL=$2; shift
      ;;
    -d|--directory)
      REQUESTED_TEST_DIR=$2; shift
      ;;
    -r|--report)
      REPORT=1
      ;;
    -c|--clean)
      clean_all_test_dirs
      ;;
    -h|--help)
      show_help
      ;;
    *)
      show_help
      ;;
  esac
  shift
done

CURR_TEST_DIR=""

if [[ $SETUP -eq 1 ]]; then
  setup
fi

if [ -n "$LABEL" ]; then
  set_test_root_dir
  run_step
  exit
fi

if [ -n "$BRANCH2" ]; then
  # brnach to branch comparision
  setup
  echo "\n"Running on branch $BRANCH1
  LABEL=$BRANCH1
  #git checkout $BRANCH1
  run_step
  eval $CLEANUP_CMD
  echo "\n"Running on branch $BRANCH2
  LABEL=$BRANCH2
  #git checkout $BRANCH2
  run_step
  report
  exit
fi

if [ -n "$REPORT" ]; then
  report
  exit
fi

} # end fictitious 'main', trick that allows to simulate effect of 'forward function definition'


report() {
  set_test_root_dir
  orig=$CURR_TEST_DIR/$ORIG
  proc=$CURR_TEST_DIR/$PROC
  mkdir -p $proc
  cp -r $orig/ $proc
  dirs=($(ls -d $proc/*))
  [[ ${#dirs[@]} -ne 2 ]] && echo Error && exit
  eval $PREPARE_FOR_COMPARE_CMD ${dirs[0]}
  eval $PREPARE_FOR_COMPARE_CMD ${dirs[1]}
  diff -r ${dirs[0]} ${dirs[1]} > $CURR_TEST_DIR/res.diff
  # TODO - echo not printing here, even though res.diff is created
}

setup() {
  R=`date +%s | shasum | base64 | head -c 10 | tr "[:upper:]" "[:lower:]"`
  CURR_TEST_DIR=$TEST_DIR_PREFIX$R
  mkdir $CURR_TEST_DIR
  echo -setup- Created test directory: $CURR_TEST_DIR
}

set_test_root_dir() {
  if [ -z "$REQUESTED_TEST_DIR" ]; then
    if [ -z "$CURR_TEST_DIR" ]; then
      if [[ "$(find . -name "$TEST_DIR_PREFIX*" -type d  -print -quit | wc -l)" -lt 1 ]]; then
        echo No test directories were found setting up new
        setup
      else
        CURR_TEST_DIR=`ls -td $TEST_DIR_PREFIX* | head -1`
        echo Test directory set to latest: $CURR_TEST_DIR
      fi
    fi
  else
    CURR_TEST_DIR=$REQUESTED_TEST_DIR
  fi
}

run_step() {
  # Assumes $CURR_TEST_DIR is set
  if [ -z "$CURR_TEST_DIR" ]; then
    echo run_step has no valid test directory
    exit
  fi

  echo Running the project
  eval $RUN_CMD
  mkdir -p $CURR_TEST_DIR/$ORIG
  mkdir -p $CURR_TEST_DIR/$ORIG/$LABEL
  orig_data_dir=$CURR_TEST_DIR/$ORIG/$LABEL
  cp -r $DATA_OUTPUT_LOCATION $orig_data_dir
  echo DONE: data copied to $orig_data_dir
}

clean_all_test_dirs() {
  find . -type d -name "$TEST_DIR_PREFIX*" -exec rm -rf {} +
  echo DONE: Removed all test directories
}

show_help() {
  echo "MANUAL MODE"
  echo
  echo "First, allocate a new test directory"
  echo "$ ./before-after.sh -s"
  echo
  echo "then run your project in your usual way. When output data is ready use following command"
  echo "to save results in the latest test dir or alternatevely provide another test directory"
  echo "$ ./before-after.sh -l label1 [-d <dir_name>]"
  echo
  echo "When you have two output samples in the test dir, run the following to trigger parse and report"
  echo "$ ./before-after.sh -r [-d <dir_name>]"
  echo
  echo "AUTOMATIC MODE"
  echo
  echo "Run automatically on two codebases and prepare diff on the results. The breakdown of the steps:"
  echo "1 setup"
  echo "2 cleanup"
  echo "3 run on branch1"
  echo "4 save output to test dir"
  echo "5 cleanup"
  echo "6 run on branch2"
  echo "7 save output to test dir"
  echo "8 cleanup"
  echo "9 parse and diff"
  echo
  echo "$ ./before-after.sh -b name1, name2   - compare output of the two branches"
  echo "$ ./before-after.sh -m name           - compare output of 'master' and branch 'name'"
  echo "$ ./before-after.sh                   - run on cuurent local copy, then 'git stash' and run again"
  echo
  echo "Options and equivalents"
  echo "-l --label"
  echo "-b --branch"
  echo "-m --master"
  echo
  echo "Following options do not have a value and cannot be combined with other options"
  echo "-s --setup"
  echo "-r --report"
}

main "$@"
