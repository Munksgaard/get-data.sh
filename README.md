# get-data.sh

A simple tool to handle large external files in git repositories.

## TL;DR

Usage: `get-data.sh external-data.txt`

`external-data.txt` file must contain lines of the format:

```
PATH URL SHA256SUM
```

`get-data.sh` will attempt to download the file at URL into PATH (relative to the
location of external-data.txt) after verifying that the sha256sum is identical
to SHA256SUM. Neither field can contain spaces.

## Motivation

Git is not ideal for managing large (binary) files, mostly because common forges
like Github don't allow them. For instance, Github will warn you when you push
any files above 50MB and simply fail if you push anything above 100MB. Solutions
like [git-annex](https://git-annex.branchable.com/) and
[git-lfs](https://git-lfs.github.com/) exist to alleviate this problem, but they
have drawbacks:

git-lfs is closely tied to Github. By default you only get 2GB on a free account
or 5GB on an enterprise account. While it is possible to install it on your
own servers, it requires, well, the ability to install software.

git-annex is much more flexible, but it seems to be geared towards slightly
different use cases. For instance, it will happily leak information about your
local setup to other contributors (like hostname), and it will list files on
other peoples computers as sources (e.g. in `git whereis`).

We need something much simpler:

 - We trust some external file storage and wish to canonically store our data
   there.[^1]

 - All information pertaining to the external data should be easily accessible
   in our repository, with no magic handlers or secret branches.

 - We want to avoid having to install a separate program to manage the external
   data.

 - We want as few external dependencies as possible.

## Introducing get-data.sh

`get-data.sh` is a simple bash script that, given a text file containing a
description of external files, will download and verify each file into your
repository. The text-file (we'll call it `external-data.txt`, though any name
will do) contains lines of the following format:

```
some/path/in/your/repository https://example.com/some-file 8c63faf15d9f8028826ed7d9a1647917a833092c1bd291f017b6618584124707
```

Upon running `get-data.sh external-data.txt`, the tool will attempt to download
the file at `https://example.com/some-file`, validate that its SHA-256 checksum
is exactly `8c63fa...` and put the file in `some/path/in/your/repository`,
relative to the location of `external-data.txt`.

That's it. There is no fancy handling of missing or already existent files. You
don't have to install any additional tools (on any reasonable system). There is
no builtin way to add files to `external-data.txt` or migrate from some other
setup. There is just a text file and a shell script.

## Suggested use

In [futhark-benchmarks](https://github.com/diku-dk/futhark-benchmarks), we have
added an `external-data.txt` file in the root of the repository. All the files
described in there are in turn located in the `external-data` directory, which
is ignored by git through a `.gitignore` entry. Then, in the places where we
actually want to use the files, we have symlinks into the `external-data`
directory. Finally, we have vendored the `get-data.sh` script, so that upon
initially cloning the repository, you just need to run `./get-data.sh
external-data.txt` to download the external files needed.

To support this particular use-case, we created [`add-data.sh`](/add-data.sh) to
add new entries into `external-data.txt`. Do note that `add-data.sh` is
currently very dumb, and will almost certainly do the wrong thing if anything
goes wrong. Use with care.

## Dependencies

 - coreutils (for `cut`, `dirname` and `mktemp`)
 - `bash`
 - `curl`
 - `shasum`

Any reasonable UNIX-like system will already have all of these installed.

[^1]: Working at University of Copenhagen, we have access to
    [ERDA](https://erda.dk), but any other web-accessible file store, such as an
    S3 bucket, will do.
