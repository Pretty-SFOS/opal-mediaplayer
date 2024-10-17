#!/bin/bash
#
# This file is part of Opal and has been released into the public domain.
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024 Mirian Margiani
#
# See https://github.com/Pretty-SFOS/opal for more information.
#
# Changelog:
#
# * 1.0.0 (2024-07-25):
#   - initial release
#

function log() {
    printf -- "%s\n" "$*"
}

if [[ "$1" == "-h" || "$1" == "--help" ]] || (( $# == 0 )); then
    log "*** Configure a new Opal module ***"
    log
    log "Run this script to configure a new Opal module. The script"
    log "automatically updates all files with proper copyright info,"
    log "renames necessary files to use the module's new name, and"
    log "updates the module metadata file at doc/module.opal."
    log
    log "Usage: ./setup.sh NAME NAME-STYLED AUTHOR BRIEF-DESCRIPTION DESCRIPTION"
    log
    log "Arguments:"
    log "   NAME              - plain name of the module, like 'sfpm' for 'opal-sfpm'"
    log "   NAME-STYLED       - styled name of the module, like 'SortFilterProxyModel'"
    log "                       for 'Opal.SortFilterProxyModel'"
    log "   AUTHOR            - author of the module, like 'Jane Doe'"
    log "   BRIEF-DESCRIPTION - very short description of this module, in the form of"
    log "                       'QML module for SOMETHING in Sailfish apps'"
    log "   DESCRIPTION       - longer description in the form of"
    log "                       'This module provides SOMETHING to DO SOMETHING.'"
    exit 0
fi

cYEAR="$(date +%Y)"

cNAME="${1#opal-}"
cNAME="${cNAME,,}"

cNAME_STYLED="${2#Opal.}"
cAUTHOR="$3"
cBRIEF="${4:-QML module for TODO in Sailfish apps}"
cDESCRIPTION="${5:-This module provides TODO.}"

if [[ -z "$cNAME" || -z "$cNAME_STYLED" || -z "$cAUTHOR" ]]; then
    log "error: NAME, NAME-STYLED, and AUTHOR must be defined"
    exit 1
fi

sed -i "s/MyModule/${cNAME_STYLED//\//\\\/}/g" \
    README.md \
    .reuse/templates/opal.jinja2 \
    .reuse/dep5 \
    Opal/MyModule/qmldir \
    Opal/MyModule/private/qmldir \
    Opal/MyModule/private/ExtraTranslations.qml \
    doc/gallery.qml \
    doc/module.opal \

sed -i "s/opal-mymodule/opal-${cNAME//\//\\\/}/g" \
    README.md \
    .reuse/templates/opal.jinja2 \
    .reuse/dep5 \
    Opal/MyModule/qmldir \
    Opal/MyModule/private/qmldir \
    Opal/MyModule/private/ExtraTranslations.qml \
    doc/gallery.qml \
    doc/module.opal \

if [[ "$cAUTHOR" != "Mirian Margiani" ]]; then
    sed -i -e "/SPDX-FileCopyrightText:/a\\" -e "SPDX-FileCopyrightText: $cYEAR $cAUTHOR" \
        README.md \
        CONTRIBUTORS.md \
        CHANGELOG.md \

    sed -i -e "/SPDX-FileCopyrightText:/a\\" -e "# SPDX-FileCopyrightText: $cYEAR $cAUTHOR" \
        Opal/MyModule/qmldir \
        Opal/MyModule/private/qmldir \
        doc/module.opal \

    sed -i -e "/SPDX-FileCopyrightText:/a\\" -e "//@ SPDX-FileCopyrightText: $cYEAR $cAUTHOR" \
        Opal/MyModule/private/ExtraTranslations.qml \
        doc/gallery.qml \

    sed -i "s/Copyright: Screenshot Author/Copyright: ${cAUTHOR//\//\\\/}/g" \
        .reuse/dep5
fi

sed -i "
    s/name: mymodule/name: ${cNAME//\//\\\/}/g;
    s/briefDescription: .*/briefDescription: ${cBRIEF//\//\\\/}/g;
    s/description: .*/description: ${cDESCRIPTION//\//\\\/}/g;
    s/attribution: .*/attribution: $cYEAR ${cAUTHOR//\//\\\/}/g;
    s/maintainers: .*/maintainers: ${cAUTHOR//\//\\\/}/g;
    s/authors: .*/authors: ${cAUTHOR//\//\\\/}/g;
        " doc/module.opal

sed -i "s/Brief description of the module./${cBRIEF//\//\\\/}/g;" \
    README.md

sed -i "s/Longer description of which problem the module solves, and how it makes life easier./${cDESCRIPTION//\//\\\/}/g;" \
    README.md

sed -i "s/Copyright (C)  Mirian Margiani/Copyright (C)  ${cAUTHOR//\//\\\/}/g" \
    README.md

sed -i "s/- author: Mirian Margiani/- author: ${cAUTHOR//\//\\\/}/g" \
    CONTRIBUTORS.md

mv "Opal/MyModule" "Opal/$cNAME_STYLED"

if [[ ! -d ../opal ]]; then
    back="$(pwd)"
    cd ..
    git clone --depth=1 https://github.com/Pretty-SFOS/opal
    cd "$back" || true
fi
