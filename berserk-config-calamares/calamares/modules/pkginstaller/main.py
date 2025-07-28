#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import os
import libcalamares
from libcalamares.utils import debug, warning


def run():
    # Get target mount point
    root_mount_point = libcalamares.globalstorage.value("rootMountPoint")
    if not root_mount_point:
        return ("Configuration Error", "Could not determine target system mount point")

    # Get package operations
    package_operations = libcalamares.globalstorage.value("packageOperations")
    if not package_operations:
        return None

    selected_packages = []

    # Extract packages from operations
    for operation in package_operations:
        if isinstance(operation, dict):
            for key in ["install", "try_install"]:
                packages = operation.get(key, [])
                if isinstance(packages, list):
                    selected_packages.extend(packages)

    # Remove duplicates
    selected_packages = list(set(selected_packages))

    if not selected_packages:
        return None

    debug(f"Installing {len(selected_packages)} packages to {root_mount_point}")

    try:
        # Update live system package database (for pacstrap)
        subprocess.run(["pacman", "-Sy", "--noconfirm"], check=True)

        # Use pacstrap to install packages into target
        subprocess.run(["pacstrap", root_mount_point] + selected_packages, check=True)

        debug("Packages installed successfully with pacstrap!")
        return None

    except subprocess.CalledProcessError as e:
        # Fallback to target_env_call if pacstrap fails
        try:
            debug("Pacstrap failed, trying chroot method...")
            from libcalamares.utils import target_env_call

            target_env_call(["pacman", "-Sy", "--noconfirm"])
            target_env_call(
                ["pacman", "-S", "--noconfirm", "--needed"] + selected_packages
            )
            return None
        except Exception as e2:
            return (
                "Package installation failed",
                f"Both methods failed: {str(e)}, {str(e2)}",
            )
