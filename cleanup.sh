#!/usr/bin/env bash

sudo dnf autoremove -y

sudo dnf clean all

flatpak uninstall --unused -y