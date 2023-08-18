# Setting Up Unreal Engine PixelStreaming on AWS

This document provides a step-by-step guide on setting up PixelStreaming service using Unreal Engine on Amazon Web Services (AWS). The installation will be performed on a pre-configured Ubuntu instance with a dedicated graphics card.

## Prerequisites

1. **Amazon Web Services (AWS) Account:** You need an AWS account to proceed with the installation.

2. **Ubuntu Instance:** Create and make accessible an Ubuntu instance that you'll use for running the PixelStreaming service.

3. **Google Drive Link:** You should have a Google Drive link to the PixelStreaming-enabled Unreal Engine game packaged in .zip format.

## Step 1: Command Script Preparation

1. Start by creating a text editor or terminal:

   ```bash
   nano setup-pixelstreaming.sh
   ```

2. Then, paste the content of the script as follows:

   ```bash
   #!/bin/bash

   workdir=$(pwd)

   # GitHub Username, Repo Name, and Autoupdate Directory
   user="serdaraltin"
   repo="AWS-PixelStreaming-Autoupdate"
   autoupdate="autoupdate"

   # Autoupdate Script and Configuration File URLs
   url_autoupdate_script="https://raw.githubusercontent.com/$user/$repo/main/$autoupdate.sh"
   url_autoupdate_config="https://raw.githubusercontent.com/$user/$repo/main/$autoupdate.config"
   file_autoupdate_script="$autoupdate.sh"
   file_autoupdate_config="$autoupdate.config"
   path_autoupdate="${workdir}/$autoupdate"

   # Definitions related to the game and PixelStreaming continue...

   # Other definitions...

   # Commands to start the PixelStreaming service...

   # Step 2 and subsequent steps...
   ```

3. Save with `Ctrl + O`, then exit with `Ctrl + X`.

## Step 2: Editing and Using the Command Script

1. To perform game updates, you'll need to edit the script. Edit the following line by specifying the ID of the .zip file of the Unreal Engine game on Google Drive:

   ```bash
   ./setup-pixelstreaming.sh -u "1YbAN6ZkHKtNF_cPEH0ghvcy1S-X3zyFd"
   ```

   **Note:** Replace `"1YbAN6ZkHKtNF_cPEH0ghvcy1S-X3zyFd"` with the ID part from the Google Drive URL, such as `https://drive.google.com/file/d/1YbAN6ZkHKtNF_cPEH0ghvcy1S-X3zyFd/view?usp=drive_link`.

2. Open a terminal and navigate to the directory of the script:

   ```bash
   cd /path/to/script
   ```

3. Give execution permission to the script:

   ```bash
   chmod +x setup-pixelstreaming.sh
   ```

4. Run the script:

   ```bash
   ./setup-pixelstreaming.sh
   ```

5. Answer necessary questions during the installation and wait for the process to complete.

## Step 3: Starting the PixelStreaming Service

1. When the installation is complete, open a terminal.

2. Start the PixelStreaming service using the following command:

   ```bash
   cd /path/to/pixelstreaming
   ./startstream.sh
   ```

## Step 4: Additional Operations

1. To perform game updates, you can use the script like this:

   ```bash
   ./setup-pixelstreaming.sh -u "1YbAN6ZkHKtNF_cPEH0ghvcy1S-X3zyFd"
   ```

2. Review the script content for more details and options.

## Notes and Warnings

- This document is for guidance purposes and requires careful execution of each step.
- Consider potential AWS costs and ensure to shut down unnecessary resources.

## License Information

The command script and associated files in this repository are distributed under the MIT License. This means that you're free to use, modify, and distribute the code as long as you include the original license notice. For more details, please refer to the [LICENSE](LICENSE) file in the repository.
