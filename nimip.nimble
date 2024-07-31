# SPDX-License-Identifier: MIT


# The package itself.
version       = "1.3"
author        = "HitBlast"
description   = "Asynchronously lookup IP addresses with this tiny, hybrid Nim application."
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nimip"]


# Nim dependencies / required libraries.
requires "nim >= 2.0.0"
requires "argparse >= 4.0"
requires "illwill == 0.3.2"


# External dependencies.
when defined(nimdistros):
  import distros
  if detectOs(Ubuntu):
    foreignDep "libssl-dev"
  else:
    foreignDep "openssl"
