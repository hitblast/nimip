# The package itself.
version       = "1.1.0"
author        = "HitBlast"
description   = "Asynchronously lookup IP addresses with this tiny, hybrid Nim application."
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nimip"]


# Nim dependencies / required libraries.
requires "nim >= 1.6"
requires "argparse >= 4.0"
requires "illwill >= 0.3"


# External dependencies.
when defined(nimdistros):
  import distros
  if detectOs(Ubuntu):
    foreignDep "libssl-dev"
  else:
    foreignDep "openssl"


# Some tasks to make building easier.
task release, "Builds a production executable for the package":
  exec "nimble build -d:ssl -d:release --accept"