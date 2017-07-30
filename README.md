# Goal

For projects that produce large amount of data files this script will help to run before/after tests by automating required steps.

It is a simple and a dumb task that on the surface is not worthy of a dedicated tooling, unless...
- You do it frequently
- Your data is mostly static, but contains dynamic bits and pieces that rubbish up the simple diff
- Your project runs long enough to force into context switch
- You need to keep original output data and/or revisions that will help debug if the diff is not as expected.

I've got fed up with dumb tasks and ended up with dumb script that does this for me. (This is what scripts were invented for)

# Usage

First of all, you need to tell the sript how to handle your project - how to run/clean it, how to strip off dynamic stuff, and where the output data is saved. Set it up in `config.sh` file

The simpliest way to use this script is to run it on two branches e.g. `bug-8778-fix-id` against `master`:

`./before-after.sh -b bug-8778-fix-id master`

sit back and relax, once script finishes running your project twice, copying, parsing and comparing, it will save the diff into test directory under `res.diff` name

There are other ways availble to run the script

`./before-after.sh -h`

the above will print the following help:

```
  MANUAL MODE

  First, allocate a new test directory
  $ ./before-after.sh -s

  then run your project in your usual way. When output data is ready use following command
  to save results in the latest test dir or alternatevely provide another test directory
  $ ./before-after.sh -l label1 [-d <dir_name>]

  When you have two output samples in the test dir, run the following to trigger parse and report
  $ ./before-after.sh -r [-d <dir_name>]

  AUTOMATIC MODE

  Run automatically on two codebases and prepare diff on the results. The breakdown of the steps:
  1 setup
  2 cleanup
  3 run on branch1
  4 save output to test dir
  5 cleanup
  6 run on branch2
  7 save output to test dir
  8 cleanup
  9 parse and diff

  $ ./before-after.sh -b name1, name2   - compare output of the two branches
  $ ./before-after.sh -m name           - compare output of 'master' and branch 'name'
  $ ./before-after.sh                   - run on cuurent local copy, then 'git stash' and run again

  Options and equivalents
  -l --label
  -b --branch
  -m --master

  Following options do not have a value and cannot be combined with other options
  -s --setup
  -r --report
```
