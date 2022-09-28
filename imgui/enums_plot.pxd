cdef extern from "implot.h":

    # cmp: enums.pxd:188
    # accessed in core.pyx:576
    ctypedef enum ImPlotFlags_:
        ImPlotFlags_None          # default
        ImPlotFlags_NoTitle       # the plot title will not be displayed (titles are also hidden if preceeded by double hashes, e.g. "##MyPlot")
        ImPlotFlags_NoLegend      # the legend will not be displayed
        ImPlotFlags_NoMouseText   # the mouse position, in plot coordinates, will not be displayed inside of the plot
        ImPlotFlags_NoInputs      # the user will not be able to interact with the plot
        ImPlotFlags_NoMenus       # the user will not be able to open context menus
        ImPlotFlags_NoBoxSelect   # the user will not be able to box-select
        ImPlotFlags_NoChild       # a child window region will not be used to capture mouse scroll (can boost performance for single ImGui window applications)
        ImPlotFlags_NoFrame       # the ImGui frame will not be rendered
        ImPlotFlags_Equal         # x and y axes pairs will be constrained to have the same units/pixel
        ImPlotFlags_Crosshairs    # the default mouse cursor will be replaced with a crosshair when hovered
        ImPlotFlags_CanvasOnly = ImPlotFlags_NoTitle | ImPlotFlags_NoLegend | ImPlotFlags_NoMenus | ImPlotFlags_NoBoxSelect | ImPlotFlags_NoMouseText