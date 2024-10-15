# Ilias Downloader Uni Stuttgart

Download files from your Ilias courses with just one click.

## Features

:heavy_check_mark: Synchronize Ilias courses or Ilias folders to any directory

:heavy_check_mark: Synchronize subfolders of the specified Ilias courses/folders

:heavy_check_mark: Download files

:heavy_check_mark: Download exercises (submission tasks)

:heavy_check_mark: When files are updated on Ilias, the local copy is renamed, and the file is downloaded again.

:heavy_check_mark: Supports Ilias 9!

:heavy_check_mark: Supports Linux and macOS.
## How to use

### Preparations

1. Bash

### Configuration

The script `IliasDownloadInit.sh` needs to be configured **once** before the first execution.

At the top of the file, you need to enter your **Ilias username and password** (Line 5).

```shell
# Enter ILIAS username and password here
# Modify here
ILIAS_USERNAME="st12345"
ILIAS_PASSWORD="password"
```

Further down in the script, you need to set the **base directory** where all Ilias materials should be downloaded.

```shell
# Preset your Homefolder
MY_STUDIES_FOLDER="/E/IliasTest"
```

Next, you need to enter all **Ilias courses or Ilias folders** that you want to download. You need to specify the Ilias course or folder number and a corresponding local directory. It is recommended to use absolute paths and the base directory.

```shell
# Take the id of the folder/course out of the URL, e.g.
#
# https://ilias3.uni-stuttgart.de/go/crs/3633981
#                                    ^^^^^^^^^^^
# or
#
# https://ilias3.uni-stuttgart.de/go/fold/3633981
#                                    ^^^^^^^^^^^^
#
# You find this link at the bottom of every folder page.
# Subfolders and exercises are automatically downloaded, too.
# You need to use absolute paths for local folders!
#
# You can download the whole course or just specific folders from a course.
# Copy for every course/folder you want to download
# Modify here
fetch_folder "crs/3633981" "$MY_STUDIES_FOLDER/Modelling"
```

**Important**: The specified download folders must exist. If the download folder does not exist, the script will not download any files. This is to prevent incorrect configurations. (Any subfolders in the Ilias course/folder will be automatically created during synchronization.)

### Execution

```sh
./IliasDownloadInit.sh
```

## FAQ

#### No files are being downloaded. What am I doing wrong?

There can be several reasons for this. Please check if ...

- the directories specified in `IliasDownloadInit.sh` exist. (The script only downloads to existing directories.)
- your username and password are correct. If the password contains special characters like `"`, `$`, `"` or `\`, these need to be escaped by preceding them with a backslash `\`.
- the `IliasDownload.sh` script is configured for your university.

#### What is the purpose of the `.il-history` file?

The script saves which documents have already been downloaded in this file. If you delete this file, the documents in that folder will be downloaded again.
The name of this file can be changed with the `HISTORY_FILE` variable in the `IliasDownloadInit.sh` script.

#### Individual files are not being downloaded.

This is a known issue that occurs due to overly long file names. The filename, including the path, must be a maximum of 255 (?) characters long. Try specifying shorter paths in `IliasDownloadInit.sh` for your folders.

## Roadmap

- Create an animation that demonstrates how the script works.
- Do not store the password in the script but use a prompt instead.
- Optionally save the username and password in a `.credentials` file.
- Download exercises (exercise books `_lm_<id>.html`) (including links from exercises).
- Fix the count of downloaded/failed files. (Due to parallel downloads, this count is incorrect.)
- Download linked videos.
- Create a shortcut for "View Online".
- Add configuration for other universities.
- Add a notification if there is a new version.
- Hash long Ilias filenames so that files can still be downloaded.

## Disclaimer

This is not an official tool of the listed educational institutions or [Ilias](https://www.ilias.de/) itself. I cannot verify compliance with the given guidelines from Ilias or the respective institution. You are solely responsible. This useful script will send many requests to the Ilias server of your institution in a short time. This could potentially lead to overload (and may not be desired by your institution).

## Credits

https://github.com/digitalshow/IliasDownload
