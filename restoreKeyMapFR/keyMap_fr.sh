#!/bin/bash

# 30/01/2025

# PB keymap suite à redemarage de la VM PB copier coller

# Etre certain que le keymap du clavier est bien en fr et pas sur une version alternative :
echo  "Passage du clavier en Francais !"
setxkbmap fr
setxkbmap -option grp:alt_shift_toggle
