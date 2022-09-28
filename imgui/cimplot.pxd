# -*- coding: utf-8 -*-
# distutils: language = c++
# distutils: include_dirs = implot-cpp

from libcpp cimport bool

cdef extern from "imgui.h":
    # cmp: cimgui.pxd:120
    # wraps: imgui.h:230
    ctypedef struct ImVec2:
        float x
        float y

cdef extern from "implot.h":
    # cmp: cimgui.pxd:81
    # wraps: implot.h:80
    ctypedef int ImPlotFlags

cdef extern from "implot.h" namespace "ImPlot":
    # cmp: cimgui.pxd:985
    # wraps: implot.h:626
    bool BeginPlot(
            const char* title_id,
            const ImVec2& size,    # = ImVec2(-1,0)
            ImPlotFlags flags      # = 0
    ) except +
