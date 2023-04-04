# homeconf

**homeconf** is a Ruby utility to create and manage your home directory files and configuration in a single, portable,
version controllable directory.

----------

## Installation

**homeconf**'s installation is pretty standard:

```sh
$ gem install homeconf
```

If you'd rather install homeconf using `bundler`, add a line for it in your `Gemfile` (but set the `require` option
to `false`, as it is a standalone tool):

```rb
gem 'homeconf', require: false
```

----------

## Quickstart

Just type `homeconf` to see your homeconf directory and if it's initialized.

```
$ cd
$ homeconf
```

### Create homeconf directory

Create your homeconf directory and start adding files and directories.

```
$ cd
$ homeconf --create
```

### Initialize to create symlinks

You can add files and directories to your homeconf directory, then initialize to create symlinks from your home
directory.
```
$ echo "echo 'hello world'" > ~/homeconf/hello.sh
$ mkdir ~/homeconf/my_scripts
$ homeconf --init
```

### Add files and directories
Move existing files and directories into homeconf directory.  Homeconf will create the symlink from your home directory.

```
$ homeconf --add .zshrc
$ homeconf --add bin
```

### See configuration
Run with verbose to see homeconf files and directories, and whether they're linked.
```
$ homeconf --verbose
```
