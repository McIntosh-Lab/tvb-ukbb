#!/bin/env python
#
# Script name: bb_file_manager.py
#
# Description: Script to do the organisation of the files of a new dataset
# 			   in UK Biobank file/directory format.
#
# Authors: Fidel Alfaro-Almagro, Stephen M. Smith & Mark Jenkinson
#
# Copyright 2017 University of Oxford
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import os
import re
import glob
import json
import copy
import nibabel as nib
import bb_logging_tool as LT

import sys
from shutil import copyfile

sys.path.insert(1, os.path.dirname(__file__) + "/..")

# print("CWD: " + os.getcwd() + "/..")
# print("FILE: " + os.path.dirname(__file__))

import bb_general_tools.bb_path as bb_path
from subprocess import check_output

# TODO: Create an image class to avoid reading the json file on each check?

logger = None
idealConfig = {}
fileConfig = {}


def formatFileConfig():
    result = ""
    for key in fileConfig:
        result = result + key + "\n"
        for value in fileConfig[key]:
            result = result + "  " + value + "\n"
    return result


def generate_SBRef(origPath, outputPath):
    commandToRun = (
        os.environ["BB_BIN_DIR"]
        + "/bb_functional_pipeline/bb_generate_SBRef "
        + origPath
        + " "
        + outputPath
    )
    logger.warn("There was no SBRef data for the subject " + origPath)
    logger.warn(
        "The SBRef data will be generated now using the middle point of the subject"
    )
    logger.warn("Command to run: " + commandToRun)
    LT.runCommand(logger, commandToRun)


def remove_phase_info(fileName):
    result = re.sub("_[PH]|_[ph].", "", fileName)
    return result


def remove_coil_info(fileName):
    result = re.sub("_COIL[0-9]*_", "_", fileName)
    return result


def remove_echo_info(fileName):
    result = re.sub("_ECHO.*_", "_", fileName)
    return result


def rename_no_coil_echo_info(fileName):
    result = remove_coil_info(fileName)
    result = remove_echo_info(result)

    if fileName != result:
        move_file(fileName, result)

    return result


def read_json(fileName):

    result = {}

    if os.path.isfile(fileName):
        if bb_path.isImage(fileName):
            jsonFileName = bb_path.removeImageExt(fileName) + ".json"

            if os.path.isfile(jsonFileName):
                with open(jsonFileName, "r") as f:
                    result = json.load(f)
    return result


def get_image_json_field(fileName, field):

    result = []
    jsonDict = read_json(fileName)

    if jsonDict != {}:
        result = jsonDict[field]

    return result


def check_if_json_field_exists(fileName, field):

    result = []
    jsonDict = read_json(fileName)
    # return true if field is a key in jsonDict
    if field in jsonDict.keys():
        return True

    return False


def save_acquisition_date_time(fileName):

    dateTime = get_image_json_field(fileName, "AcquisitionDateTime")
    # 20140831122443.796875
    # Format this date


def image_type_contains(fileName, desiredType):

    imageType = get_image_json_field(fileName, "ImageType")

    # 2 possible formats in the BIDS json file
    if isinstance(imageType, str):
        imageType = imageType.split("_")
    elif not isinstance(imageType, list):
        raise NameError(
            "The content of the json file associated with " + fileName + " is incorrect"
        )

    if desiredType in imageType:
        return True

    return False


def is_normalised(fileName):
    normed_siemens = image_type_contains(fileName, "NORM")
    normed_philips = check_if_json_field_exists(fileName, "PhilipsRescaleSlope")
    # if either is True, file is normalised
    return normed_siemens or normed_philips
    # return image_type_contains(fileName, "NORM")


def is_phase(fileName):
    return image_type_contains(fileName, "P")


def move_to(listFiles, destination):
    for fileName in listFiles:
        move_file(fileName, destination + fileName)


# Convert all the file names to upper case to avoid
# ambiguities (Extensions are always in lower case)
# Remove _ character at the beginning of the filename
def capitalize_and_clean(listFiles):

    logger.info("File names changed to upper case.")
    for fileName in listFiles:
        fPath, fname = os.path.split(fileName)
        newFileName = fname.upper()
        if newFileName.startswith("_"):
            newFileName = newFileName[1:]

        endings = [".NII.GZ", "BVAL", "BVEC", "JSON"]

        for ending in endings:
            if newFileName.endswith(ending):
                newFileName = newFileName.replace(ending, ending.lower())

        fullNew = fPath + "/" + newFileName
        os.rename(fileName, fullNew)


def move_file(oldPath, newPath):

    # The file may be a json file and may have been moved previously
    if os.path.isfile(oldPath):
        logger.info("File moved/renamed: " + oldPath + " to " + newPath)
        # os.rename(oldPath, newPath)
        copyfile(oldPath, newPath)

        # If there is an associated json, move it as well
        if bb_path.isImage(oldPath):
            plainOrigName = bb_path.removeImageExt(oldPath)
            plainNewName = bb_path.removeImageExt(newPath)

            if os.path.isfile(plainOrigName + ".json"):
                # os.rename(plainOrigName + ".json", plainNewName + ".json")
                copyfile(plainOrigName + ".json", plainNewName + ".json")


def move_file_add_to_config(oldPath, key, boolAppend):
    if boolAppend:
        move_file(oldPath, idealConfig[key] + "/" + oldPath)
        fileConfig[key].append(idealConfig[key] + "/" + oldPath)
    else:
        move_file(oldPath, idealConfig[key])
        fileConfig[key] = idealConfig[key]
        print(f"key: {key}, fileConfig: {fileConfig[key]}")


def robustSort(listFiles):
    listFiles.sort()
    finalList = copy.copy(listFiles)
    altern = []

    for fileName in listFiles:

        rest = fileName[fileName.rfind("_") + 1 :]

        try:
            cadNumb = rest[: rest.find(".")]
            if cadNumb[-1] == "A":
                cadNumb = cadNumb[:-1]
            for phaseEnd in ["PH", "ph"]:
                if cadNumb == phaseEnd:
                    rest = fileName[fileName.rfind("_" + phaseEnd) - 2 :]
                    cadNumb = rest[: rest.find("_" + phaseEnd + ".")]

            numb = int(cadNumb)
            altern.append(numb)
        except ValueError:
            logger.error(
                "Found a file with an improper name: "
                + fileName
                + " . It will be moved to the unclassified folder"
            )
            finalList.remove(fileName)

    newList = [x for (y, x) in sorted(zip(altern, finalList))]

    return newList


# The flag parameter indicates whether this is T1 or T2_FLAIR
def manage_struct(listFiles, flag):

    # listFiles = robustSort(listFiles)
    numFiles = len(listFiles)

    listFiles = [rename_no_coil_echo_info(x) for x in listFiles]

    # boolNorm = [is_normalised(x) for x in listFiles]
    # ignore normalization for now
    boolNorm = [True for x in listFiles]

    print(f"{flag} norm: {boolNorm}")

    if not any(boolNorm):
        logger.error("There was not an intensity-normalized " + flag + ".")
        if flag == "T1":
            logger.error("It will not be possible to process the subject")
    else:
        indexLastNorm = (numFiles - list(reversed(boolNorm)).index(True)) - 1
        normalisedFileName = listFiles[indexLastNorm]
        move_file_add_to_config(normalisedFileName, flag, False)
        listFiles.remove(normalisedFileName)
        boolNorm = boolNorm[:indexLastNorm]

        if False in boolNorm:

            indexLastNotNorm = (
                len(boolNorm) - list(reversed(boolNorm[:indexLastNorm])).index(False)
            ) - 1

            if indexLastNotNorm >= 0:
                notNormalisedFileName = listFiles[indexLastNotNorm]
                move_file_add_to_config(notNormalisedFileName, flag + "_notNorm", False)
                listFiles.remove(notNormalisedFileName)

    for fileName in listFiles:
        # os.path.basename will not work on Windows
        move_file(fileName, "unclassified/" + os.path.basename(fileName))


# The flag parameter indicates whether this is resting or task fMRI
def manage_fMRI(listFiles, flag):

    # listFiles = robustSort(listFiles)
    numFiles = len(listFiles)
    dim = []

    listFiles = [rename_no_coil_echo_info(x) for x in listFiles]

    # Get the dimensions for all the fMRI images
    for fileName in listFiles:
        epi_img = nib.load(fileName)
        dim.append(epi_img.get_header()["dim"][4])

    if numFiles == 0:
        logger.warn("There was no " + flag + " FMRI data")

    elif numFiles == 1:
        # If the only fMRI we have is the SBRef
        if dim[0] == 1:
            logger.error(
                "There was only SBRef data for the subject. There will be no "
                + flag
                + "fMRI processing"
            )
            move_file_add_to_config(listFiles[0], flag + "_SBRef", False)

        # If we have fMRI data but no SBRef, we generate it.
        else:
            move_file_add_to_config(listFiles[0], flag, False)
            generate_SBRef(idealConfig[flag], idealConfig[flag + "_SBRef"])
            fileConfig[flag + "_SBRef"] = idealConfig[flag + "_SBRef"]

    elif numFiles == 2:
        biggestImageDim = max(dim)
        indBiggestImage = dim.index(biggestImageDim)
        indSmallestImage = 1 - indBiggestImage

        # If there is at least one propper fMRI image
        if biggestImageDim > 1:
            move_file_add_to_config(listFiles[indBiggestImage], flag, False)

            # If the other image is an SBRef image
            if dim[indSmallestImage] == 1:
                move_file_add_to_config(
                    listFiles[indSmallestImage], flag + "_SBRef", False
                )

            # If not, forget about it and generate and SBRef
            else:
                generate_SBRef(idealConfig[flag], idealConfig[flag + "_SBRef"])
                fileConfig[flag + "_SBRef"] = idealConfig[flag + "_SBRef"]

        else:
            logger.error(
                "There was only SBRef data for the subject. There will be no "
                + flag
                + "fMRI processing"
            )
            move_file_add_to_config(listFiles[numFiles - 1], flag + "_SBRef", False)

    # If there are more than 2 rfMRI images, and at least one has more than one volume,
    # we will take the biggest one as the fMRI volume and generate take as SBRef the one
    # with the previous numeration. If that one is not a proper SBRef, generate it.
    elif max(dim) > 1:
        indBiggestImage = dim.index(max(dim))
        move_file_add_to_config(listFiles[indBiggestImage], flag, False)

        fileName = listFiles[indBiggestImage]
        print(f"files: {listFiles}")
        plainFileName = bb_path.removeImageExt(fileName)
        print(f"fname: {plainFileName}")

        ind = -1
        try:
            number = int(plainFileName.split("_")[-1])

            for fileToCheck in listFiles:
                # Check if the file with the previous numeration is in the list
                numberToCheck = int(bb_path.removeImageExt(fileName).split("_")[-1])
                if numberToCheck == (number - 1):
                    ind = listFiles.index(fileToCheck)

        except ValueError:
            logger.error(
                "Unable to determine SBRef via numeric indexing. Generating SBRef."
            )

        # If there is a file with the file number that should correspond to this case
        if ind > 0:
            # If the file with the previous numeration is a SBREF file
            if dim[ind] == 1:
                move_file_add_to_config(listFiles[ind], flag + "_SBRef", False)

            # If not, forget about it and generate a new one
            else:
                generate_SBRef(idealConfig[flag], idealConfig[flag + "_SBRef"])
                fileConfig[flag + "_SBRef"] = idealConfig[flag + "_SBRef"]

        else:
            generate_SBRef(idealConfig[flag], idealConfig[flag + "_SBRef"])
            fileConfig[flag + "_SBRef"] = idealConfig[flag + "_SBRef"]

    # There are several fMRI images but neither of them have more than one volume
    else:
        logger.error(
            "There was only SBRef data for the subject. There will be no "
            + flag
            + "fMRI processing."
        )
        move_file_add_to_config(listFiles[numFiles - 1], flag + "_SBRef", False)


def manage_DWI(listFiles):

    # listFiles = robustSort(listFiles)
    numFiles = len(listFiles)
    listFiles = [rename_no_coil_echo_info(x) for x in listFiles]

    subListFilesD = {}
    imageFilesD = {}

    if numFiles == 0:
        logger.error("There was no DWI data.  There will be no DWI processing.")

    else:
        errorFound = False
        encodingDirections = ["PA", "AP"]

        numNifti = 0

        for fl in listFiles:
            if ".nii.gz" in fl:
                numNifti += 1

        if numNifti == 1:
            encodingDirections = ["dwi"]

        # Code needed for the inconsistency in the file names in Diffusion over the different phases
        if listFiles[0].startswith("MB3"):

            subListFilesD["PA"] = [x for x in listFiles if x.find("PA") != -1]
            imageFilesD["PA"] = [x for x in subListFilesD["PA"] if bb_path.isImage(x)]

            subListFilesD["AP"] = [x for x in listFiles if x not in subListFilesD["PA"]]
            imageFilesD["AP"] = [x for x in subListFilesD["AP"] if bb_path.isImage(x)]

        elif "dwi" in listFiles[0]:

            subListFilesD["dwi"] = [x for x in listFiles if x.find("dwi") != -1]
            imageFilesD["dwi"] = [x for x in subListFilesD["dwi"] if bb_path.isImage(x)]

        else:
            for direction in encodingDirections:
                subListFilesD[direction] = [
                    x for x in listFiles if x.find(direction) != -1
                ]
                imageFilesD[direction] = [
                    x for x in subListFilesD[direction] if bb_path.isImage(x)
                ]
        try:

            for direction in encodingDirections:

                dim = []

                subListFiles = subListFilesD[direction]
                imageFiles = imageFilesD[direction]

                for fileName in imageFiles:
                    epi_img = nib.load(fileName)
                    dim.append(epi_img.get_header()["dim"][4])

                numImageFiles = len(imageFiles)
                # print("HEEERE")

                if numImageFiles == 0:
                    raise Exception(
                        "There should be at least one DWI image in the "
                        + direction
                        + " direction with more than one volume. DWI data is not correct."
                        " There will be no diffusion processing."
                    )

                biggestImageDim = max(dim)
                indBiggestImage = dim.index(biggestImageDim)

                # There is no proper DWI image
                if biggestImageDim <= 1:
                    raise Exception(
                        "There should be at least one DWI image in the "
                        + direction
                        + " direction with more than one volume. DWI data is not correct."
                        " There will be no diffusion processing."
                    )

                if numImageFiles > 1:
                    # Check if there is SBRef file for the direction
                    if dim.count(1) == 0:
                        logger.warn(
                            "There was no SBRef file in the "
                            + direction
                            + " direction."
                        )

                    # If there is at least one, take the last one.
                    else:

                        # Get the index of the last image with dimension = 1
                        indexSBRef = numImageFiles - list(reversed(dim)).index(1) - 1
                        move_file_add_to_config(
                            imageFiles[indexSBRef], direction + "_SBRef", False
                        )

                # Take the biggest image in the selected direction and set it as the DWI image for that direction
                move_file_add_to_config(imageFiles[indBiggestImage], direction, False)

                # BVAL and BVEC files should have the same name as the image, changing the extension
                bvalFileName = (
                    bb_path.removeImageExt(imageFiles[indBiggestImage]) + ".bval"
                )
                bvecFileName = (
                    bb_path.removeImageExt(imageFiles[indBiggestImage]) + ".bvec"
                )

                if (not bvalFileName in subListFiles) or (
                    not bvecFileName in subListFiles
                ):
                    raise Exception(
                        "There should be 1 bval and 1 bvec file in "
                        + direction
                        + " direction. DWI data is not correct. There will be no"
                        " diffusion processing."
                    )

                move_file_add_to_config(bvecFileName, direction + "_bvec", False)
                move_file_add_to_config(bvalFileName, direction + "_bval", False)

        # In case of any big error in the data, set DWI data as inexistent.
        except Exception as e:
            for key in ["AP", "AP_bval", "AP_bvec", "PA", "PA_bval", "PA_bvec"]:
                fileConfig[key] = ""
            logger.error(str(e))

        # Set the rest of the files as unclassified
        for fileName in listFiles:

            if os.path.isfile(fileName):
                fpath, fname = os.path.split(fileName)
                move_file(fileName, "unclassified/" + fname)


def manage_SWI(listFiles):

    # listFiles = robustSort(listFiles)
    numFiles = len(listFiles)

    # TODO: Find all files with actual coil info

    if numFiles <= 133:
        logger.error(
            "There should be at least 134 SWI files. Only "
            + str(numFiles)
            + " found. There will be no SWI processing"
        )

    elif numFiles > 134:
        logger.error(
            "The number of SWI files ("
            + str(numFiles)
            + ") is incorrect. There will be no processing"
        )

    else:
        mainFiles = [x for x in listFiles if ("_COIL_" in x)]

        numMainFiles = len(mainFiles)

        for mainFile in mainFiles:
            listFiles.remove(mainFile)

        for key in ["SWI_MAG_TE1", "SWI_MAG_TE2", "SWI_PHA_TE1", "SWI_PHA_TE2"]:
            fileConfig[key] = []

        # Classifying coil files
        for fileName in listFiles:

            boolPhase = is_phase(fileName)
            # boolPhase= bb_path.removeImageExt(fileName).endswith('_PHA')
            boolTE1 = fileName.find("_ECHO1_") != -1

            if boolPhase:
                if boolTE1:
                    move_file_add_to_config(fileName, "SWI_PHA_TE1", True)
                else:
                    move_file_add_to_config(fileName, "SWI_PHA_TE2", True)

            else:
                if boolTE1:
                    move_file_add_to_config(fileName, "SWI_MAG_TE1", True)

                else:
                    move_file_add_to_config(fileName, "SWI_MAG_TE2", True)

        # Classifying SWI files
        # is_phase function does not work due to SWI acquisition not complying with standard
        # DICOM configuration and hence, dcm2niix does not get the phase properly
        notNormMagFiles = [
            mainFile
            for mainFile in mainFiles
            if (
                (not is_normalised(mainFile))
                and (not (bb_path.removeImageExt(mainFile).endswith("_PH")))
            )
        ]

        if len(notNormMagFiles) != 2:
            logger.warn(
                "There should be 2 not normalised SWI files. SWI data will not be processed"
            )
            for mainFile in mainFiles:
                if os.path.isfile(mainFile):
                    move_file(mainFile, "SWI/unclassified/" + mainFile)

        else:
            for notNormMagFile in notNormMagFiles:
                if notNormMagFile.find("_ECHO1_") != -1:
                    move_file_add_to_config(
                        notNormMagFile, "SWI_TOTAL_MAG_notNorm", False
                    )
                else:
                    move_file_add_to_config(
                        notNormMagFile, "SWI_TOTAL_MAG_notNorm_TE2", False
                    )

                mainFiles.remove(notNormMagFile)

            for mainFile in mainFiles:

                # boolPhase=is_phase(mainFile)
                boolPhase = bb_path.removeImageExt(mainFile).endswith("_PH")
                boolTE1 = mainFile.find("_ECHO1_") != -1

                if boolPhase:
                    if boolTE1:
                        move_file_add_to_config(mainFile, "SWI_TOTAL_PHA", False)
                    else:
                        move_file_add_to_config(mainFile, "SWI_TOTAL_PHA_TE2", False)

                else:
                    if boolTE1:
                        move_file_add_to_config(mainFile, "SWI_TOTAL_MAG", False)

                    else:
                        move_file_add_to_config(mainFile, "SWI_TOTAL_MAG_TE2", False)


def bb_file_manager(subject):

    global logger
    global idealConfig
    global fileConfig
    logger = LT.initLogging(__file__, subject)

    idealConfigFile = os.environ["BB_BIN_DIR"] + "/bb_data/ideal_config.json"
    with open(idealConfigFile, "r") as f:
        idealConfig = json.load(f)

    directories = [
        "delete",
        "unclassified",
        "raw",
        "T1",
        "T2_FLAIR",
        "SWI",
        "SWI/PHA_TE1",
        "SWI/PHA_TE2",
        "SWI/MAG_TE1",
        "SWI/MAG_TE2",
        "SWI/unclassified",
        "dMRI",
        "dMRI/raw",
        "fMRI",
        "fieldmap",
    ]

    patterns_actions = [
        [["*.[^log]"], capitalize_and_clean],
        [["dicom", "DICOM"], move_to, "delete/"],
        [["*T1*.nii.gz"], manage_struct, "T1"],
        [["T2*FLAIR*.nii.gz", "*FLAIR*.nii.gz", "*T2*.nii.gz"], manage_struct, "T2"],
        [
            [
                "*FMRI*RESTING*.nii.gz",
                "MB8*RESTING*.nii.gz",
                "*TASK*REST*.nii.gz",
                "*task*rest*.nii.gz",
                "*epi_rest*.nii.gz",
            ],
            manage_fMRI,
            "rfMRI",
        ],
        [
            [
                "*fmri*task*.nii.gz",
                "*FMRI*TASK*.nii.gz",
                "MB8*TASK*.nii.gz",
                "*epi_movie*.nii.gz",
                "*epi_smt*.nii.gz",
            ],
            manage_fMRI,
            "tfMRI",
        ],
        [["SWI*nii.gz"], manage_SWI],
        # [["DIFF_*", "MB3_*", "*dwi*.nii.gz", "*DWI*.nii.gz"], manage_DWI],
        [["DIFF_*", "MB3_*", "*dwi*.*", "*DWI*.*"], manage_DWI],
        [["SWI*.*"], move_to, "SWI/unclassified/"],
        [["*.[^log]"], move_to, "unclassified/"],
    ]

    os.chdir(subject)
    fd_fileName = "logs/file_descriptor.json"

    # Check if the subject has already been managed
    if os.path.isfile(fd_fileName):
        with open(fd_fileName, "r") as f:
            fileConfig = json.load(f)

    else:
        for directory in directories:
            if not os.path.isdir(directory):
                os.mkdir(directory)

        # listFiles = glob.glob("*.*")
        listF = glob.glob(os.getcwd() + "/**/*.*", recursive=True)
        listF.sort()
        listFiles = [fl for fl in listF if fl[-4:] != ".log"]

        print("FILES: ")
        print(listFiles)
        # Organize the files in sets
        for patterns_action in patterns_actions:
            patterns = patterns_action[0]
            action = patterns_action[1]
            args = patterns_action[2:]

            listFiles = []
            for fileTy in patterns:
                print(f"FILETYPE: {fileTy}")
                pat = glob.glob(os.getcwd() + "/**/" + fileTy, recursive=True)
                print(f"PATT: {pat}")
                listFiles.extend(
                    [
                        x
                        for x in glob.glob(
                            os.getcwd() + "/**/" + fileTy, recursive=True
                        )
                        if x not in listFiles
                    ]
                )
            logger.info(
                "Performing action "
                + action.__name__
                + " on files with patterns "
                + str(patterns)
            )

            # print(f"DOING {action.__name__} on {listFiles}")
            action(listFiles, *args)

        # Create file descriptor
        logger.info(f"FILECONFIG: {fileConfig}")
        fd = open(fd_fileName, "w")
        json.dump(fileConfig, fd, sort_keys=True, indent=4)
        fd.close()

    os.chdir("..")

    fileConfigFormatted = formatFileConfig()

    return fileConfig
