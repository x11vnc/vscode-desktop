# Docker/Singularity Image for Visual Studio Code with Ubuntu and X11VNC

This Docker image provides the Ubuntu 22.04 environment with X Windows 
with Visual Studio Code. The X Windows can display in your web browser
in full-screen mode. You can use this Docker image on 64-bit Linux,
Mac or Windows. It allows you to use the same programming environment
regardless which OS you are running on your laptop or desktop. In
addition, it is also compatible with 
[Singularity](https://sylabs.io/singularity/)
(tested with Singularity v3.5) for high-performance computing platforms.

![Build Status](https://github.com/x11vnc/vscode-desktop/actions/workflows/docker-image.yml/badge.svg)
[![Docker Pulls](https://img.shields.io/docker/pulls/x11vnc/vscode-desktop.svg)](https://hub.docker.com/r/x11vnc/vscode-desktop/)

## Preparation

Before you start, you need to first install Python 3.x and Docker on your computer by following the steps below.

### Installing Python
If you use Linux or Mac, Python 3.x is most likely already installed on your computer, so you can skip this step.

If you use Windows, you need to install Python if you have not yet done so. The easiest way is to install `Miniconda`, which you can download at https://repo.continuum.io/miniconda/Miniconda3-latest-Windows-x86_64.exe. During installation, make sure you check the option to make Miniconda the system's default Python.

### Installing Docker
Download Docker Desktop for free at https://docs.docker.com/get-docker/ and then run the installer. Note that you need administrator's privilege to install Docker. After installation, make sure you launch Docker before proceeding to the next step.

**Notes for Windows Users**
1. Docker only supports 64-bit Windows 10 Pro or higher. It is highly recommended that you install Docker Desktop with the WSL 2 backend instead of the Hyper-V backend. The latter only supports Enterprise or Education versions, has lower performance, and requires additional configuration steps.
2. For security reasons, it is recommended that you do not use Docker in the Administrator account, even if you are the sole user on the computer.

**Notes for Mac Users**
1. Docker Desktop supports only MacOS 10.15 or newer. The Docker image supports both Intel chips and Apple M1 chips natively. 
Please make sure that you install Docker Desktop for Mac that is native to your computer's CPU.
2. By default, Docker uses half the number of processors and 2GB of memory on Mac. If you want to run large jobs, you can increase the amount of memory or the number of cores dedicated to Docker. Just click on the Docker icon in the system tray, select `Preferences` and then select the `Advanced` tab to adjust the settings.

**Notes for Linux Users**
* Most Linux distributions have a `docker` package. You can use the package installer for your system to install `docker`. Note that on some system (e.g., OpenSUSE), you may need to run the following commands to start up `docker` after installing `docker`:
```
sudo systemctl enable docker
sudo systemctl start docker
```
* After you install Docker, make sure you add yourself to the `docker` group. On Ubuntu, this is done by running the command:
```
sudo adduser $USER docker
```
On other systems, try the following command.
```
sudo usermod -G docker -a $USER
```
After adding yourself to the `docker` group, you need to log out and log back in before you can use Docker.
## Running the Docker Image

To run the Docker image, first download the script [`vscode_desktop.py`](https://raw.githubusercontent.com/x11vnc/vscode-desktop/main/vscode_desktop.py)
and save it to the working directory where you will store your codes and data. You can download the script using command line: On Windows, start `Windows PowerShell`, use the `cd` command to change to the working directory where you will store your codes and data, and then run the following command:
```
curl https://raw.githubusercontent.com/x11vnc/vscode-desktop/main/vscode_desktop.py -outfile vscode_desktop.py
```
On Linux or Mac, start a terminal, use the `cd` command to change to the working directory, and then run the following command:
```
curl -s -O https://raw.githubusercontent.com/x11vnc/vscode-desktop/main/vscode_desktop.py
```

After downloading the script, you can start the Docker image using the command
```
python3 vscode_desktop.py -p
```
This will download and run the Docker image and then launch your default web browser to show the desktop environment. The `-p` option is optional, and it instructs the Python script to pull and update the image to the latest version. The work directory by default will be mapped to the current working directory on your host.

If your source code is in a named Docker volume, e.g. `myproject`, you can mount the volume to the `~/project` directory inside the container using the command
```
python3 vscode_desktop.py -v myproject
```
and the work directory will be the data volume.

For additional command-line options, use the command
```
python3 vscode_desktop.py -h
```

### Running the Docker Image Offline

After you have download the Docker image using the `curl` and `python` commands above, you can run the image offline without internet connection using the following command:
```
python3 vscode_desktop.py
```
in the directory where you ran the `curl` command above.

### Stopping the Docker Image

To stop the Docker image, press Ctrl-C twice in the terminal (or Windows PowerShell on Windows) on your host computer where you started the Docker image, and close the tab for the desktop in your web browser.

## Use with Singularity

This Docker image is constructed to be compatible with Singularity. This 
has been tested with Singularity v3.5. If your system does not yet have
Singularity, you may need to install it by following 
[these instructions](https://www.sylabs.io/guides/3.9/user-guide/quick_start.html#quick-installation-steps).
You must have root access to install Singularity, but you can use
Singularity as a regular user after it has been installed. If you do not
have root access, such as on an HPC platform, ask your system administrator
to install Singularity for you. It is recommended you use Singularity v2.6 or later.

To use the Docker image with Singularity, please issue the command
```
singularity run -c -B $HOME -B /tmp docker://x11vnc/vscode-desktop:latest
```
It will automatically mount some minimal /dev directories and $HOME in Singularity
but does not mount most others (such as /run). If you do not want to
mount your home directory, then remove the `-B $HOME` option.

Alternatively, if you use Singularity v3.x, you may use the commands
```
singularity pull vscode-desktop:latest.sif docker://x11vnc/vscode-desktop:latest
singularity run -c -B $HOME -B /tmp ./vscode-desktop:latest.sif
```

Notes regarding Singularity:
- When using Singularity, the user name in the container will be the same
  as that on the host. You will still have read access to /home/$DOCKER_USER.
- To avoid conflict with the user configuration on the host when using
  Singularity, this image uses /bin/zsh as the login shell in the container.
  By default, /home/$DOCKER_USER/.zprofile and /home/$DOCKER_USER/.zshrc
  will be copied to your home directory if they do not yet exist. This works
  the best if you use another login shell (such as /bin/bash) on the host.
  If you are a `zsh` user, you may need to edit your `.zshrc` and `.zprofile`
  to work both on the host and in the Singularity image.
- To avoid potential conflict with your X11 configuration, this image uses
  LXDE for the desktop manager. This works best if you do not use LXDE on
  your host.

## Entering Full-Screen Mode for Desktop Environment

For the best experience, use [VNC Viewer](http://realvnc.com/download/viewer) to connect to Docker image with the port and password displayed in the terminal output, which supports the full-screen mode. If you don't have the VNC viewer, you can
also use the full-screen mode in a web browser.

When using a web browser, we recommend *Google Chrome*, *Chromium browser*, or *Microsoft Edge*, which has similar user interfaces. On Windows or Linux, you can enter full-screen mode by selecting the menu `View --> "Full Screen"` Alternatively, open the Chrome menu (the three vertical dots at the top right) and select the square to the far right of the Zoom buttons (the "+" and "-" buttons). To exit the full-screen mode, press the `F11` key. On Mac, it behaves similarly except that the menu item is named `Enter Full Screen` instead of `Full Screen`, and the keyboard shortcut is `Ctrl-Cmd-f` instead of `F11`. You can also click on the green circle at the top-left corner of *Google Chrome* to enter and exit the full-screen mode. Note that in the full-screen mode, you need to disable `Always Show Toolbar in Full Screen` under the `View` menu of `Google Chrome`, and you can reveal the menu and the toolbar by sliding your mouse to the top of the display.

Alternatively, you can also use the "native" browsers on different platforms.
- On Windows, you can use the native browser *Microsoft Edge*. Toggle on and off the full-screen mode by pressing Win+Shift+Enter (hold down the Windows and Shift keys and press Enter).
- On Mac, you can use the native browser *Safari*, for which you can toggle the full-screen mode by clicking on the green circle at the top-left corner of *Safari* or selecting the `View --> "Enter Full Screen"` menu. To exit the full-screen mode, press `Ctrl-Cmd-f`, or slide your mouse to the top of the display to enable the menus.
- On Linux, the default browser *Firefox* does not hide its address bar in its native full-screen mode. You are recommended to use *Google Chrome* or *Chromium browser* instead. However, you can use *Firefox* for a full-screen viewing mode by clicking on the `Fullscreen` button in the left sidebar of Docker desktop environment. However, this is not recommended for day-to-day use, because *Firefox* would exit this full-screen mode whenever you press `Esc`, which may happen quite often.

If your Docker desktop environment started automatically in a non-recommended browser, you can copy and paste the URL into a recommended browser.

## Tips and Tricks

1. When using the Docker desktop, the files under `$HOME/.config`, `$HOME/.ssh`,  `$HOME/shared` and any other
directory that you might have mounted explicitly are persistent. Any change to files in other directories will be lost when the Docker container stops. Use `$HOME/.config` to store the configuration files of the desktop environment. `$HOME/shared` maps to the working directory on the host, and you are recommended to use it or a mounted project directory to store codes and data.
2. The `$HOME/.ssh` directory in the Docker container maps to the `.ssh` directory on your host computer. This is particularly convenient for you to use your ssh-keys for authentications with git repositories (such as github or bitbucket). To use your ssh keys, run the `ssh-add` in a terminal to add your keys to the ssh-agent.
3. You can copy and paste between the host and the Docker desktop through the `Clipboard` box in the left toolbar, which is synced automatically with the clipboard of the Docker desktop. To copy from the Docker desktop to the host, first, select the text in the Docker desktop, and then go to the `Clipboard` box to copy. To copy from host to the Docker desktop, first, paste the text into the `Clipboard` box, and then paste the text in the Docker desktop.
4. To stop the Docker container, do not just close the browser window, because the Docker container would still be running in the background. Instead, you can stop the container using one of the following approaches:
 - Use the `logout` button in the lower-left corner of the Docker desktop,
 - Press Ctrl-C twice in the terminal where you started the python script, or
 - Run the command `docker stop <Container ID>` in a terminal on the host, and you can find the `Container ID` using the `docker ps -a` command.

 ## Developer
This project was developed by Xiangmin Jiao as a tool for teaching and research at Stony Brook University. Note that this project is independent of the [LibVNC/x11vnc](https://github.com/LibVNC/x11vnc) project.

## License

See the LICENSE file for details.

