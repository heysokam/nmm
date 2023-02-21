# Package
packageName           = "nmm"
version               = "0.0.0"
author                = "sOkam"
description           = "Nim Manual Memory Management"
license               = "GPL-3.0-or-later"

# Dependencies
requires "nim >= 1.6.10"

# Folders
binDir                = "bin"
srcDir                = "src"

# Binaries
let current           = packageName
namedBin[current]     = current
# namedBin[packageName] = packageName
