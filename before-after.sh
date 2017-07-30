#!/bin/sh
set -e

. config.sh

main() {

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

if [[ $SETUP -eq 1 ]]; then
  setup
fi

} # end fictious 'main', trick that allows to simulate effect of 'forward function definition'

setup() {
  R=`date +%s | shasum | base64 | head -c 10 | tr "[:upper:]" "[:lower:]"`
  TEST_ROOT_DIR=$TEST_DIR_PREFIX$R
  mkdir $TEST_ROOT_DIR
  echo DONE: Created test directory: $TEST_ROOT_DIR
}

clean_all_test_dirs() {
  find . -type d -name "vvv_*" -exec rm -rf {} +
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
