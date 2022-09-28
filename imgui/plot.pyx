# distutils: language = c++
# distutils: sources = implot-cpp/implot.cpp implot-cpp/implot_items.cpp implot-cpp/implot_demo.cpp
# distutils: include_dirs = implot-cpp ansifeed-cpp
# cython: embedsignature=True

"""
def:
    - can be called from Python and Cython
    - cannot take pointers as arguments
    - compiled to C by Cython
    - always returns a Python object

cdef:
    - can be called from Cython and C
    - faster to call from Cython than def
    - supports pointer arguments
    - compiled to C by Cython
    - cannot be declared inside of defs or cdefs
    - output type can be specified

cpdef:
    - generates both a def and a cdef function
        => visible to Python, but quick function call from within Cython
    - inherits restrictions of both function types

"""

import cython
cimport cimplot
cimport enums_plot

# TODO: cimport vs include
#cimport common
cimport cimgui
from cpython.version cimport PY_MAJOR_VERSION
include "imgui/common.pyx" # for _cast_args_ImVec2, _bytes

# ==== Plot Flags ====
PLOT_NONE = enums_plot.ImPlotFlags_None
PLOT_NO_TITLE = enums_plot.ImPlotFlags_NoTitle
PLOT_NO_LEGEND = enums_plot.ImPlotFlags_NoLegend
PLOT_NO_MOUSE_TEXT = enums_plot.ImPlotFlags_NoMouseText
PLOT_NO_INPUTS = enums_plot.ImPlotFlags_NoInputs
PLOT_NO_MENUS = enums_plot.ImPlotFlags_NoMenus
PLOT_NO_BOX_SELECT = enums_plot.ImPlotFlags_NoBoxSelect
PLOT_NO_CHILD = enums_plot.ImPlotFlags_NoChild
PLOT_NO_FRAME = enums_plot.ImPlotFlags_NoFrame
PLOT_EQUAL = enums_plot.ImPlotFlags_Equal
PLOT_CROSSHAIRS = enums_plot.ImPlotFlags_Crosshairs
PLOT_CANVAS_ONLY = enums_plot.ImPlotFlags_CanvasOnly

# wraps: implot.h:626
# comp: core.pyx:3679
def begin_plot(
    str title_id,
    float width = -1, float height = 0,
    cimplot.ImPlotFlags flags = 0,
):
    return cimplot.BeginPlot(
        _bytes(title_id), _cast_args_ImVec2(width, height), flags
    )

# TODO: get the rest from: https://github.com/hinxx/pyimplot/tree/main/implot