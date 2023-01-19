# pyplotgui

A Python package that extends
[pyimgui](https://github.com/pyimgui/pyimgui/tree/dev/version-2.0) (v2.0 beta) with
[pyimplot](https://github.com/hinxx/pyimplot).

The package uses the same `imgui` namespace as pyimgui, but adds `imgui.plot`. The implot API is only partially implemented (pull requests are always welcome).

See the Pyimgui documentation: [pyimgui.readthedocs.io](https://pyimgui.readthedocs.io/en/latest/index.html) for information on pyimgui.

# Installation

**pyplotgui** is available on PyPI and can be easily installed with `pip`:
 
    pip install pyplotgui


# Project distribution

This project has a working build pipeline using GitHub actions. It builds
succesfully for all major operating systems with different architectures:

* Windows (32bit & 64bit)
* Linux (32bit & 64bit)
* OS X (universal build)

The build pipeline covers Python versions `py36-py311`.