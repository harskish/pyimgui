# Included at end of core.pyx.
# Results in a single binary containing both
# ImGui and ImPlot, avoiding issues with heaps
# and globals not being shared across DLL boundaries.
# (see imgui.cpp:930 for more information)

import cython
from cython.operator cimport dereference as deref
from cpython cimport array
import warnings

from libcpp cimport bool
from libc.stdlib cimport malloc, free

cimport cimplot
cimport cimgui
cimport core
cimport enums

from cpython.version cimport PY_MAJOR_VERSION

# ImPlot version string
IMPLOT_VERSION = "0.9 WIP"
# Indicates variable should deduced automatically.
IMPLOT_AUTO = -1
# Special color used to indicate that a color should be deduced automatically.
IMPLOT_AUTO_COL = (0, 0, 0, -1)

COLOR_COUNT = cimplot.ImPlotCol_COUNT

# Options for plots
PLOT_FLAGS_NONE = cimplot.ImPlotFlags_None
PLOT_FLAGS_NO_TITLE = cimplot.ImPlotFlags_NoTitle
PLOT_FLAGS_NO_LEGEND = cimplot.ImPlotFlags_NoLegend
PLOT_FLAGS_NO_MENUS = cimplot.ImPlotFlags_NoMenus
PLOT_FLAGS_NO_BOX_SELECT = cimplot.ImPlotFlags_NoBoxSelect
PLOT_FLAGS_NO_MOUSE_POS = cimplot.ImPlotFlags_NoMousePos
PLOT_FLAGS_NO_HIGHLIGHT = cimplot.ImPlotFlags_NoHighlight
PLOT_FLAGS_NO_CHILD = cimplot.ImPlotFlags_NoChild
PLOT_FLAGS_EQUAL = cimplot.ImPlotFlags_Equal
PLOT_FLAGS_YAXIS2 = cimplot.ImPlotFlags_YAxis2
PLOT_FLAGS_YAXIS3 = cimplot.ImPlotFlags_YAxis3
PLOT_FLAGS_QUERY = cimplot.ImPlotFlags_Query
PLOT_FLAGS_CROSSHAIRS = cimplot.ImPlotFlags_Crosshairs
PLOT_FLAGS_ANTI_ALIASED = cimplot.ImPlotFlags_AntiAliased
PLOT_FLAGS_CANVAS_ONLY = cimplot.ImPlotFlags_CanvasOnly

# Options for plot axes (X and Y)
AXIS_FLAGS_NONE = cimplot.ImPlotAxisFlags_None
AXIS_FLAGS_NO_LABEL = cimplot.ImPlotAxisFlags_NoLabel
AXIS_FLAGS_NO_GRID_LINES = cimplot.ImPlotAxisFlags_NoGridLines
AXIS_FLAGS_NO_TICK_MARKS = cimplot.ImPlotAxisFlags_NoTickMarks
AXIS_FLAGS_NO_TICK_LABELS = cimplot.ImPlotAxisFlags_NoTickLabels
AXIS_FLAGS_LOD_SCALE = cimplot.ImPlotAxisFlags_LogScale
AXIS_FLAGS_TIME = cimplot.ImPlotAxisFlags_Time
AXIS_FLAGS_INVERT = cimplot.ImPlotAxisFlags_Invert
AXIS_FLAGS_AUTO_FIT = cimplot.ImPlotAxisFlags_AutoFit
AXIS_FLAGS_LOCK_MIN = cimplot.ImPlotAxisFlags_LockMin
AXIS_FLAGS_LOCK_MAX = cimplot.ImPlotAxisFlags_LockMax
AXIS_FLAGS_LOCK = cimplot.ImPlotAxisFlags_Lock
AXIS_FLAGS_NO_DECORATIONS = cimplot.ImPlotAxisFlags_NoDecorations


##########################################################################################3


#include "common.pyx"

cdef class _ImPlotContext(object):
    cdef cimplot.ImPlotContext* _ptr

    @staticmethod
    cdef from_ptr(cimplot.ImPlotContext* ptr):
        if ptr == NULL:
            return None

        instance = _ImPlotContext()
        instance._ptr = ptr
        return instance

    def __eq__(_ImPlotContext self, _ImPlotContext other):
        return other._ptr == self._ptr


cdef class _PlotColors(object):
    cdef PlotStyle _style

    def __cinit__(self):
        self._style = None

    def __init__(self, PlotStyle style):
        self._style = style

    cdef inline _check_color(self, cimplot.ImPlotCol variable):
        if not (0 <= variable < cimplot.ImPlotCol_COUNT):
            raise ValueError("Unknown style variable: {}".format(variable))

    def __getitem__(self, cimplot.ImPlotCol variable):
        self._check_color(variable)
        self._style._check_ptr()
        cdef int ix = variable
        return _cast_ImVec4_tuple(self._style._ptr.Colors[ix])

    def __setitem__(self, cimplot.ImPlotCol variable, value):
        self._check_color(variable)
        self._style._check_ptr()
        cdef int ix = variable
        self._style._ptr.Colors[ix] = _cast_tuple_ImVec4(value)


cdef class PlotStyle(object):
    """
    Container for ImPlot style information

    """
    cdef cimplot.ImPlotStyle* _ptr
    cdef bool _owner
    cdef _PlotColors _colors

    def __cinit__(self):
        self._ptr = NULL
        self._owner = False
        self._colors = None

    def __dealloc__(self):
        if self._owner:
            del self._ptr
            self._ptr = NULL


    cdef inline _check_ptr(self):
        if self._ptr is NULL:
            raise RuntimeError(
                "Improperly initialized, use imgui.plot.get_style() or "
                "PlotStyle.created() to obtain style classes"
            )

    def __eq__(PlotStyle self, PlotStyle other):
        return other._ptr == self._ptr

    @staticmethod
    def create():
        return PlotStyle._create()

    @staticmethod
    cdef PlotStyle from_ref(cimplot.ImPlotStyle& ref):
        cdef PlotStyle instance = PlotStyle()
        instance._ptr = &ref
        instance._colors = _PlotColors(instance)
        return instance

    @staticmethod
    cdef PlotStyle _create():
        cdef cimplot.ImPlotStyle* _ptr = new cimplot.ImPlotStyle()
        cdef PlotStyle instance = PlotStyle.from_ref(deref(_ptr))
        instance._owner = True
        instance._colors = _PlotColors(instance)
        return instance
    ## float LineWeight

    @property
    def line_weight(self):
        self._check_ptr()
        return self._ptr.LineWeight

    @line_weight.setter
    def line_weight(self, float value):
        self._check_ptr()
        self._ptr.LineWeight = value

    ## int Marker

    @property
    def marker(self):
        self._check_ptr()
        return self._ptr.Marker

    @marker.setter
    def marker(self, int value):
        self._check_ptr()
        self._ptr.Marker = value

    ## float MarkerSize

    @property
    def marker_size(self):
        self._check_ptr()
        return self._ptr.MarkerSize

    @marker_size.setter
    def marker_size(self, float value):
        self._check_ptr()
        self._ptr.MarkerSize = value

    ## float MarkerWeight

    @property
    def marker_weight(self):
        self._check_ptr()
        return self._ptr.MarkerWeight

    @marker_weight.setter
    def marker_weight(self, float value):
        self._check_ptr()
        self._ptr.MarkerWeight = value

    ## float FillAlpha

    @property
    def fill_alpha(self):
        self._check_ptr()
        return self._ptr.FillAlpha

    @fill_alpha.setter
    def fill_alpha(self, float value):
        self._check_ptr()
        self._ptr.FillAlpha = value

    ## float ErrorBarSize

    @property
    def error_bar_size(self):
        self._check_ptr()
        return self._ptr.ErrorBarSize

    @error_bar_size.setter
    def error_bar_size(self, float value):
        self._check_ptr()
        self._ptr.ErrorBarSize = value

    ## float ErrorBarWeight

    @property
    def error_bar_weight(self):
        self._check_ptr()
        return self._ptr.ErrorBarWeight

    @error_bar_weight.setter
    def error_bar_weight(self, float value):
        self._check_ptr()
        self._ptr.ErrorBarWeight = value

    ## float DigitalBitHeight

    @property
    def digital_bit_height(self):
        self._check_ptr()
        return self._ptr.DigitalBitHeight

    @digital_bit_height.setter
    def digital_bit_height(self, float value):
        self._check_ptr()
        self._ptr.DigitalBitHeight = value

    ## float DigitalBitGap

    @property
    def digital_bit_gap(self):
        self._check_ptr()
        return self._ptr.DigitalBitGap

    @digital_bit_gap.setter
    def digital_bit_gap(self, float value):
        self._check_ptr()
        self._ptr.DigitalBitGap = value

    ## float PlotBorderSize

    @property
    def plot_border_size(self):
        self._check_ptr()
        return self._ptr.PlotBorderSize

    @plot_border_size.setter
    def plot_border_size(self, float value):
        self._check_ptr()
        self._ptr.PlotBorderSize = value

    ## float MinorAlpha

    @property
    def minor_alpha(self):
        self._check_ptr()
        return self._ptr.MinorAlpha

    @minor_alpha.setter
    def minor_alpha(self, float value):
        self._check_ptr()
        self._ptr.MinorAlpha = value

    ## ImVec2 MajorTickLen

    @property
    def major_tick_len(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.MajorTickLen)

    @major_tick_len.setter
    def major_tick_len(self, value):
        self._check_ptr()
        self._ptr.MajorTickLen = _cast_tuple_ImVec2(value)

    ## ImVec2 MinorTickLen

    @property
    def minor_tick_len(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.MinorTickLen)

    @minor_tick_len.setter
    def minor_tick_len(self, value):
        self._check_ptr()
        self._ptr.MinorTickLen = _cast_tuple_ImVec2(value)

    ## ImVec2 MajorTickSize

    @property
    def major_tick_size(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.MajorTickSize)

    @major_tick_size.setter
    def major_tick_size(self, value):
        self._check_ptr()
        self._ptr.MajorTickSize = _cast_tuple_ImVec2(value)

    ## ImVec2 MinorTickSize

    @property
    def minor_tick_size(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.MinorTickSize)

    @minor_tick_size.setter
    def minor_tick_size(self, value):
        self._check_ptr()
        self._ptr.MinorTickSize = _cast_tuple_ImVec2(value)

    ## ImVec2 MajorGridSize

    @property
    def major_grid_size(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.MajorGridSize)

    @major_grid_size.setter
    def major_grid_size(self, value):
        self._check_ptr()
        self._ptr.MajorGridSize = _cast_tuple_ImVec2(value)

    ## ImVec2 MinorGridSize

    @property
    def minor_grid_size(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.MinorGridSize)

    @minor_grid_size.setter
    def minor_grid_size(self, value):
        self._check_ptr()
        self._ptr.MinorGridSize = _cast_tuple_ImVec2(value)

    ## ImVec2 PlotPadding

    @property
    def plot_padding(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.PlotPadding)

    @plot_padding.setter
    def plot_padding(self, value):
        self._check_ptr()
        self._ptr.PlotPadding = _cast_tuple_ImVec2(value)

    ## ImVec2 LabelPadding

    @property
    def label_padding(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.LabelPadding)

    @label_padding.setter
    def label_padding(self, value):
        self._check_ptr()
        self._ptr.LabelPadding = _cast_tuple_ImVec2(value)

    ## ImVec2 LegendPadding

    @property
    def legend_padding(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.LegendPadding)

    @legend_padding.setter
    def legend_padding(self, value):
        self._check_ptr()
        self._ptr.LegendPadding = _cast_tuple_ImVec2(value)

    ## ImVec2 LegendInnerPadding

    @property
    def legend_inner_padding(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.LegendInnerPadding)

    @legend_inner_padding.setter
    def legend_inner_padding(self, value):
        self._check_ptr()
        self._ptr.LegendInnerPadding = _cast_tuple_ImVec2(value)

    ## ImVec2 LegendSpacing

    @property
    def legend_spacing(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.LegendSpacing)

    @legend_spacing.setter
    def legend_spacing(self, value):
        self._check_ptr()
        self._ptr.LegendSpacing = _cast_tuple_ImVec2(value)

    ## ImVec2 MousePosPadding

    @property
    def mouse_pos_padding(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.MousePosPadding)

    @mouse_pos_padding.setter
    def mouse_pos_padding(self, value):
        self._check_ptr()
        self._ptr.MousePosPadding = _cast_tuple_ImVec2(value)

    ## ImVec2 AnnotationPadding

    @property
    def annotation_padding(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.AnnotationPadding)

    @annotation_padding.setter
    def annotation_padding(self, value):
        self._check_ptr()
        self._ptr.AnnotationPadding = _cast_tuple_ImVec2(value)

    ## ImVec2 FitPadding

    @property
    def fit_padding(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.FitPadding)

    @fit_padding.setter
    def fit_padding(self, value):
        self._check_ptr()
        self._ptr.FitPadding = _cast_tuple_ImVec2(value)

    ## ImVec2 PlotDefaultSize

    @property
    def plot_default_size(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.PlotDefaultSize)

    @plot_default_size.setter
    def plot_default_size(self, value):
        self._check_ptr()
        self._ptr.PlotDefaultSize = _cast_tuple_ImVec2(value)

    ## ImVec2 PlotMinSize

    @property
    def plot_min_size(self):
        self._check_ptr()
        return _cast_ImVec2_tuple(self._ptr.PlotMinSize)

    @plot_min_size.setter
    def plot_min_size(self, value):
        self._check_ptr()
        self._ptr.PlotMinSize = _cast_tuple_ImVec2(value)

    ## ImVec4 *Colors


    def color(self, cimplot.ImPlotCol variable):
        if not (0 <= variable < cimplot.ImPlotCol_COUNT):
            raise ValueError("Unknown style variable: {}".format(variable))

        self._check_ptr()
        cdef int ix = variable
        return _cast_ImVec4_tuple(self._ptr.Colors[ix])

    @property
    def colors(self):
        """Retrieve and modify style colors through list-like interface.

        .. visual-example::
            :width: 700
            :height: 500
            :auto_layout:

            style = imgui.get_style()
            imgui.begin("Color window")
            imgui.columns(4)
            for color in range(0, imgui.COLOR_COUNT):
                imgui.text("Color: {}".format(color))
                imgui.color_button("color#{}".format(color), *style.colors[color])
                imgui.next_column()

            imgui.end()
        """
        self._check_ptr()
        return self._colors

    ## ImPlotColormap Colormap

    @property
    def colormap(self):
        self._check_ptr()
        return self._ptr.Colormap

    @colormap.setter
    def colormap(self, cimplot.ImPlotColormap value):
        self._check_ptr()
        self._ptr.Colormap = value

    ## bool AntiAliasedLines

    @property
    def anti_aliased_lines(self):
        self._check_ptr()
        return self._ptr.AntiAliasedLines

    @anti_aliased_lines.setter
    def anti_aliased_lines(self, cimgui.bool value):
        self._check_ptr()
        self._ptr.AntiAliasedLines = value

    ## bool UseLocalTime

    @property
    def use_local_time(self):
        self._check_ptr()
        return self._ptr.UseLocalTime

    @use_local_time.setter
    def use_local_time(self, cimgui.bool value):
        self._check_ptr()
        self._ptr.UseLocalTime = value

    ## bool UseISO8601

    @property
    def use_i_s_o8601(self):
        self._check_ptr()
        return self._ptr.UseISO8601

    @use_i_s_o8601.setter
    def use_i_s_o8601(self, cimgui.bool value):
        self._check_ptr()
        self._ptr.UseISO8601 = value

    ## bool Use24HourClock

    @property
    def use24_hour_clock(self):
        self._check_ptr()
        return self._ptr.Use24HourClock

    @use24_hour_clock.setter
    def use24_hour_clock(self, cimgui.bool value):
        self._check_ptr()
        self._ptr.Use24HourClock = value


##########################################################################################3


def create_context():
    cdef cimplot.ImPlotContext* _ptr
    _ptr = cimplot.CreateContext()
    return _ImPlotContext.from_ptr(_ptr)


def destroy_context(_ImPlotContext ctx = None):
    if ctx and ctx._ptr != NULL:
        cimplot.DestroyContext(ctx._ptr)
        ctx._ptr = NULL
    else:
        raise RuntimeError("Context invalid (None or destroyed)")


def get_current_context():
    cdef cimplot.ImPlotContext* _ptr
    _ptr = cimplot.GetCurrentContext()
    return _ImPlotContext.from_ptr(_ptr)


def set_current_context(_ImPlotContext ctx):
    cimplot.SetCurrentContext(ctx._ptr)


#def set_imgui_context(_ImGuiContext ctx):
def set_imgui_context(core._ImGuiContext ctx):
    if ctx._ptr == NULL:
        raise RuntimeError("ImGui Context invalid (None or destroyed)")
    cimplot.SetImGuiContext(ctx._ptr)


def begin_plot(str title_id,
               str x_label = None,
               str y_label = None,
               size = (-1,0),
               cimplot.ImPlotFlags flags = cimplot.ImPlotFlags_None,
               cimplot.ImPlotAxisFlags x_flags = cimplot.ImPlotAxisFlags_None,
               cimplot.ImPlotAxisFlags y_flags = cimplot.ImPlotAxisFlags_None,
               cimplot.ImPlotAxisFlags y2_flags = cimplot.ImPlotAxisFlags_NoGridLines,
               cimplot.ImPlotAxisFlags y3_flags = cimplot.ImPlotAxisFlags_NoGridLines,
               str y2_label = None,
               str y3_label = None):
    cdef char* c_x_label = NULL
    if x_label is not None:
        py_x_label = _bytes(x_label)
        c_x_label = py_x_label
    cdef char* c_y_label = NULL
    if y_label is not None:
        py_y_label = _bytes(y_label)
        c_y_label = py_y_label
    cdef char* c_y2_label = NULL
    if y2_label is not None:
        py_y2_label = _bytes(y2_label)
        c_y2_label = py_y2_label
    cdef char* c_y3_label = NULL
    if y3_label is not None:
        py_y3_label = _bytes(y3_label)
        c_y3_label = py_y3_label
    return cimplot.BeginPlot(
        _bytes(title_id),
        c_x_label, c_y_label,
        _cast_tuple_ImVec2(size),
        flags, x_flags, y_flags, y2_flags, y3_flags,
        c_y2_label, c_y3_label)


def end_plot():
    cimplot.EndPlot()


cdef class _callback_info(object):

    cdef object callback_fn
    cdef user_data

    def __init__(self):
        pass

    def populate(self, callback_fn, user_data):
        if callable(callback_fn):
            self.callback_fn = callback_fn
            self.user_data = user_data
        else:
            raise ValueError("callback_fn is not a callable: %s" % str(callback_fn))


cdef cimplot.ImPlotPoint _ImPlotGetterCallback(void* data, int idx):
    cdef _callback_info _cb_info = <_callback_info>(data)
    x, y = _cb_info.callback_fn(_cb_info.user_data, idx)
    cdef cimplot.ImPlotPoint point
    point.x = x
    point.y = y
    return point


def plot_line1(str label_id, array.array values, int count, double xscale=1, double x0=0, int offset=0, int stride=0):
    if values.typecode == 'd':
        cimplot.PlotLine1[double](_bytes(label_id), values.data.as_doubles, count, xscale, x0, offset, sizeof(double))
    elif values.typecode == 'f':
        cimplot.PlotLine1[float](_bytes(label_id), values.data.as_floats, count, xscale, x0, offset, sizeof(float))
    elif values.typecode == 'q':
        cimplot.PlotLine1[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>values.data.as_longlongs, count, xscale, x0, offset, sizeof(cimgui.ImS64))
    elif values.typecode == 'Q':
        cimplot.PlotLine1[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>values.data.as_ulonglongs, count, xscale, x0, offset, sizeof(cimgui.ImU64))
    elif values.typecode == 'l':
        cimplot.PlotLine1[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>values.data.as_longs, count, xscale, x0, offset, sizeof(cimgui.ImS32))
    elif values.typecode == 'L':
        cimplot.PlotLine1[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>values.data.as_ulongs, count, xscale, x0, offset, sizeof(cimgui.ImU32))
    elif values.typecode == 'h':
        cimplot.PlotLine1[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>values.data.as_shorts, count, xscale, x0, offset, sizeof(cimgui.ImS16))
    elif values.typecode == 'H':
        cimplot.PlotLine1[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>values.data.as_ushorts, count, xscale, x0, offset, sizeof(cimgui.ImU16))
    elif values.typecode == 'b':
        cimplot.PlotLine1[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>values.data.as_schars, count, xscale, x0, offset, sizeof(cimgui.ImS8))
    elif values.typecode == 'B':
        cimplot.PlotLine1[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>values.data.as_uchars, count, xscale, x0, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_line2(str label_id, array.array xs, array.array ys, int count, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd':
        cimplot.PlotLine2[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, count, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f':
        cimplot.PlotLine2[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, count, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q':
        cimplot.PlotLine2[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, count, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q':
        cimplot.PlotLine2[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, count, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l':
        cimplot.PlotLine2[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, count, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L':
        cimplot.PlotLine2[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, count, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h':
        cimplot.PlotLine2[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, count, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H':
        cimplot.PlotLine2[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, count, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b':
        cimplot.PlotLine2[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, count, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B':
        cimplot.PlotLine2[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, count, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_lineg(str label_id, object callback, data, int count, int offset=0):
    cdef _callback_info _cb_info = _callback_info()
    cdef cimplot.ImPlotGetterCallback _callback = NULL
    cdef void *_data = NULL
    if callback is not None:
        _callback = _ImPlotGetterCallback
        _cb_info.populate(callback, data)
        _data = <void*>_cb_info
    cimplot.PlotLineG(_bytes(label_id), _callback, _data, count, offset)


def plot_scatter1(str label_id, array.array values, int count, double xscale=1, double x0=0, int offset=0, int stride=0):
    if values.typecode == 'd':
        cimplot.PlotScatter1[double](_bytes(label_id), values.data.as_doubles, count, xscale, x0, offset, sizeof(double))
    elif values.typecode == 'f':
        cimplot.PlotScatter1[float](_bytes(label_id), values.data.as_floats, count, xscale, x0, offset, sizeof(float))
    elif values.typecode == 'q':
        cimplot.PlotScatter1[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>values.data.as_longlongs, count, xscale, x0, offset, sizeof(cimgui.ImS64))
    elif values.typecode == 'Q':
        cimplot.PlotScatter1[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>values.data.as_ulonglongs, count, xscale, x0, offset, sizeof(cimgui.ImU64))
    elif values.typecode == 'l':
        cimplot.PlotScatter1[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>values.data.as_longs, count, xscale, x0, offset, sizeof(cimgui.ImS32))
    elif values.typecode == 'L':
        cimplot.PlotScatter1[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>values.data.as_ulongs, count, xscale, x0, offset, sizeof(cimgui.ImU32))
    elif values.typecode == 'h':
        cimplot.PlotScatter1[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>values.data.as_shorts, count, xscale, x0, offset, sizeof(cimgui.ImS16))
    elif values.typecode == 'H':
        cimplot.PlotScatter1[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>values.data.as_ushorts, count, xscale, x0, offset, sizeof(cimgui.ImU16))
    elif values.typecode == 'b':
        cimplot.PlotScatter1[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>values.data.as_schars, count, xscale, x0, offset, sizeof(cimgui.ImS8))
    elif values.typecode == 'B':
        cimplot.PlotScatter1[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>values.data.as_uchars, count, xscale, x0, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_scatter2(str label_id, array.array xs, array.array ys, int count, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd':
        cimplot.PlotScatter2[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, count, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f':
        cimplot.PlotScatter2[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, count, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q':
        cimplot.PlotScatter2[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, count, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q':
        cimplot.PlotScatter2[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, count, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l':
        cimplot.PlotScatter2[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, count, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L':
        cimplot.PlotScatter2[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, count, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h':
        cimplot.PlotScatter2[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, count, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H':
        cimplot.PlotScatter2[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, count, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b':
        cimplot.PlotScatter2[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, count, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B':
        cimplot.PlotScatter2[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, count, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_scatterg(str label_id, object callback, data, int count, int offset=0):
    cdef _callback_info _cb_info = _callback_info()
    cdef cimplot.ImPlotGetterCallback _callback = NULL
    cdef void *_data = NULL
    if callback is not None:
        _callback = _ImPlotGetterCallback
        _cb_info.populate(callback, data)
        _data = <void*>_cb_info
    cimplot.PlotScatterG(_bytes(label_id), _callback, _data, count, offset)


def plot_stairs1(str label_id, array.array values, int count, double xscale=1, double x0=0, int offset=0, int stride=0):
    if values.typecode == 'd':
        cimplot.PlotStairs1[double](_bytes(label_id), values.data.as_doubles, count, xscale, x0, offset, sizeof(double))
    elif values.typecode == 'f':
        cimplot.PlotStairs1[float](_bytes(label_id), values.data.as_floats, count, xscale, x0, offset, sizeof(float))
    elif values.typecode == 'q':
        cimplot.PlotStairs1[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>values.data.as_longlongs, count, xscale, x0, offset, sizeof(cimgui.ImS64))
    elif values.typecode == 'Q':
        cimplot.PlotStairs1[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>values.data.as_ulonglongs, count, xscale, x0, offset, sizeof(cimgui.ImU64))
    elif values.typecode == 'l':
        cimplot.PlotStairs1[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>values.data.as_longs, count, xscale, x0, offset, sizeof(cimgui.ImS32))
    elif values.typecode == 'L':
        cimplot.PlotStairs1[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>values.data.as_ulongs, count, xscale, x0, offset, sizeof(cimgui.ImU32))
    elif values.typecode == 'h':
        cimplot.PlotStairs1[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>values.data.as_shorts, count, xscale, x0, offset, sizeof(cimgui.ImS16))
    elif values.typecode == 'H':
        cimplot.PlotStairs1[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>values.data.as_ushorts, count, xscale, x0, offset, sizeof(cimgui.ImU16))
    elif values.typecode == 'b':
        cimplot.PlotStairs1[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>values.data.as_schars, count, xscale, x0, offset, sizeof(cimgui.ImS8))
    elif values.typecode == 'B':
        cimplot.PlotStairs1[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>values.data.as_uchars, count, xscale, x0, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_stairs2(str label_id, array.array xs, array.array ys, int count, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd':
        cimplot.PlotStairs2[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, count, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f':
        cimplot.PlotStairs2[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, count, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q':
        cimplot.PlotStairs2[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, count, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q':
        cimplot.PlotStairs2[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, count, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l':
        cimplot.PlotStairs2[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, count, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L':
        cimplot.PlotStairs2[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, count, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h':
        cimplot.PlotStairs2[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, count, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H':
        cimplot.PlotStairs2[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, count, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b':
        cimplot.PlotStairs2[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, count, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B':
        cimplot.PlotStairs2[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, count, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_stairsg(str label_id, object callback, data, int count, int offset=0):
    cdef _callback_info _cb_info = _callback_info()
    cdef cimplot.ImPlotGetterCallback _callback = NULL
    cdef void *_data = NULL
    if callback is not None:
        _callback = _ImPlotGetterCallback
        _cb_info.populate(callback, data)
        _data = <void*>_cb_info
    cimplot.PlotStairsG(_bytes(label_id), _callback, _data, count, offset)


def plot_shaded1(str label_id, array.array values, int count, double y_ref=0, double xscale=1, double x0=0, int offset=0, int stride=0):
    if values.typecode == 'd':
        cimplot.PlotShaded1[double](_bytes(label_id), values.data.as_doubles, count, y_ref, xscale, x0, offset, sizeof(double))
    elif values.typecode == 'f':
        cimplot.PlotShaded1[float](_bytes(label_id), values.data.as_floats, count, y_ref, xscale, x0, offset, sizeof(float))
    elif values.typecode == 'q':
        cimplot.PlotShaded1[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>values.data.as_longlongs, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImS64))
    elif values.typecode == 'Q':
        cimplot.PlotShaded1[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>values.data.as_ulonglongs, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImU64))
    elif values.typecode == 'l':
        cimplot.PlotShaded1[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>values.data.as_longs, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImS32))
    elif values.typecode == 'L':
        cimplot.PlotShaded1[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>values.data.as_ulongs, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImU32))
    elif values.typecode == 'h':
        cimplot.PlotShaded1[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>values.data.as_shorts, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImS16))
    elif values.typecode == 'H':
        cimplot.PlotShaded1[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>values.data.as_ushorts, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImU16))
    elif values.typecode == 'b':
        cimplot.PlotShaded1[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>values.data.as_schars, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImS8))
    elif values.typecode == 'B':
        cimplot.PlotShaded1[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>values.data.as_uchars, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_shaded2(str label_id, array.array xs, array.array ys, int count, double y_ref=0, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd':
        cimplot.PlotShaded2[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, count, y_ref, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f':
        cimplot.PlotShaded2[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, count, y_ref, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q':
        cimplot.PlotShaded2[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, count, y_ref, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q':
        cimplot.PlotShaded2[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, count, y_ref, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l':
        cimplot.PlotShaded2[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, count, y_ref, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L':
        cimplot.PlotShaded2[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, count, y_ref, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h':
        cimplot.PlotShaded2[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, count, y_ref, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H':
        cimplot.PlotShaded2[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, count, y_ref, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b':
        cimplot.PlotShaded2[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, count, y_ref, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B':
        cimplot.PlotShaded2[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, count, y_ref, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_shaded3(str label_id, array.array xs, array.array ys1, array.array ys2, int count, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys1.typecode == 'd' and ys2.typecode == 'd':
        cimplot.PlotShaded3[double](_bytes(label_id), xs.data.as_doubles, ys1.data.as_doubles, ys2.data.as_doubles, count, offset, sizeof(double))
    elif xs.typecode == 'f' and ys1.typecode == 'f' and ys2.typecode == 'f':
        cimplot.PlotShaded3[float](_bytes(label_id), xs.data.as_floats, ys1.data.as_floats, ys2.data.as_floats, count, offset, sizeof(float))
    elif xs.typecode == 'q' and ys1.typecode == 'q' and ys2.typecode == 'q':
        cimplot.PlotShaded3[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys1.data.as_longlongs, <cimgui.ImS64*>ys2.data.as_longlongs, count, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys1.typecode == 'Q' and ys2.typecode == 'Q':
        cimplot.PlotShaded3[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys1.data.as_ulonglongs, <cimgui.ImU64*>ys2.data.as_ulonglongs, count, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys1.typecode == 'l' and ys2.typecode == 'l':
        cimplot.PlotShaded3[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys1.data.as_longs, <cimgui.ImS32*>ys2.data.as_longs, count, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys1.typecode == 'L' and ys2.typecode == 'L':
        cimplot.PlotShaded3[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys1.data.as_ulongs, <cimgui.ImU32*>ys2.data.as_ulongs, count, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys1.typecode == 'h' and ys2.typecode == 'h':
        cimplot.PlotShaded3[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys1.data.as_shorts, <cimgui.ImS16*>ys2.data.as_shorts, count, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys1.typecode == 'H' and ys2.typecode == 'H':
        cimplot.PlotShaded3[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys1.data.as_ushorts, <cimgui.ImU16*>ys2.data.as_ushorts, count, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys1.typecode == 'b' and ys2.typecode == 'b':
        cimplot.PlotShaded3[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys1.data.as_schars, <cimgui.ImS8*>ys2.data.as_schars, count, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys1.typecode == 'B' and ys2.typecode == 'B':
        cimplot.PlotShaded3[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys1.data.as_uchars, <cimgui.ImU8*>ys2.data.as_uchars, count, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_shadedg(str label_id, object callback1, data1, object callback2, data2, int count, int offset=0):
    cdef _callback_info _cb_info1 = _callback_info()
    cdef cimplot.ImPlotGetterCallback _callback = NULL
    cdef void *_data1 = NULL
    if callback1 is not None:
        _callback1 = _ImPlotGetterCallback
        _cb_info1.populate(callback1, data1)
        _data1 = <void*>_cb_info1
    cdef _callback_info _cb_info2 = _callback_info()
    cdef cimplot.ImPlotPoint (*_callback2)(void* data, int idx)
    cdef void *_data2 = NULL
    if callback2 is not None:
        _callback2 = _ImPlotGetterCallback
        _cb_info2.populate(callback2, data2)
        _data2 = <void*>_cb_info2
    cimplot.PlotShadedG(_bytes(label_id), _callback1, _data1, _callback2, _data2, count, offset)


def plot_bars1(str label_id, array.array values, int count, double width=0.67, double shift=0, int offset=0, int stride=0):
    if values.typecode == 'd':
        cimplot.PlotBars1[double](_bytes(label_id), values.data.as_doubles, count, width, shift, offset, sizeof(double))
    elif values.typecode == 'f':
        cimplot.PlotBars1[float](_bytes(label_id), values.data.as_floats, count, width, shift, offset, sizeof(float))
    elif values.typecode == 'q':
        cimplot.PlotBars1[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>values.data.as_longlongs, count, width, shift, offset, sizeof(cimgui.ImS64))
    elif values.typecode == 'Q':
        cimplot.PlotBars1[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>values.data.as_ulonglongs, count, width, shift, offset, sizeof(cimgui.ImU64))
    elif values.typecode == 'l':
        cimplot.PlotBars1[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>values.data.as_longs, count, width, shift, offset, sizeof(cimgui.ImS32))
    elif values.typecode == 'L':
        cimplot.PlotBars1[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>values.data.as_ulongs, count, width, shift, offset, sizeof(cimgui.ImU32))
    elif values.typecode == 'h':
        cimplot.PlotBars1[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>values.data.as_shorts, count, width, shift, offset, sizeof(cimgui.ImS16))
    elif values.typecode == 'H':
        cimplot.PlotBars1[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>values.data.as_ushorts, count, width, shift, offset, sizeof(cimgui.ImU16))
    elif values.typecode == 'b':
        cimplot.PlotBars1[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>values.data.as_schars, count, width, shift, offset, sizeof(cimgui.ImS8))
    elif values.typecode == 'B':
        cimplot.PlotBars1[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>values.data.as_uchars, count, width, shift, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_bars2(str label_id, array.array xs, array.array ys, int count, double width, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd':
        cimplot.PlotBars2[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, count, width, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f':
        cimplot.PlotBars2[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, count, width, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q':
        cimplot.PlotBars2[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, count, width, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q':
        cimplot.PlotBars2[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, count, width, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l':
        cimplot.PlotBars2[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, count, width, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L':
        cimplot.PlotBars2[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, count, width, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h':
        cimplot.PlotBars2[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, count, width, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H':
        cimplot.PlotBars2[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, count, width, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b':
        cimplot.PlotBars2[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, count, width, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B':
        cimplot.PlotBars2[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, count, width, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_barsg(str label_id, object callback, data, int count, double width, int offset=0):
    cdef _callback_info _cb_info = _callback_info()
    cdef cimplot.ImPlotGetterCallback _callback = NULL
    cdef void *_data = NULL
    if callback is not None:
        _callback = _ImPlotGetterCallback
        _cb_info.populate(callback, data)
        _data = <void*>_cb_info
    cimplot.PlotBarsG(_bytes(label_id), _callback, _data, count, width, offset)


def plot_barsh1(str label_id, array.array values, int count, double height=0.67, double shift=0, int offset=0, int stride=0):
    if values.typecode == 'd':
        cimplot.PlotBarsH1[double](_bytes(label_id), values.data.as_doubles, count, height, shift, offset, sizeof(double))
    elif values.typecode == 'f':
        cimplot.PlotBarsH1[float](_bytes(label_id), values.data.as_floats, count, height, shift, offset, sizeof(float))
    elif values.typecode == 'q':
        cimplot.PlotBarsH1[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>values.data.as_longlongs, count, height, shift, offset, sizeof(cimgui.ImS64))
    elif values.typecode == 'Q':
        cimplot.PlotBarsH1[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>values.data.as_ulonglongs, count, height, shift, offset, sizeof(cimgui.ImU64))
    elif values.typecode == 'l':
        cimplot.PlotBarsH1[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>values.data.as_longs, count, height, shift, offset, sizeof(cimgui.ImS32))
    elif values.typecode == 'L':
        cimplot.PlotBarsH1[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>values.data.as_ulongs, count, height, shift, offset, sizeof(cimgui.ImU32))
    elif values.typecode == 'h':
        cimplot.PlotBarsH1[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>values.data.as_shorts, count, height, shift, offset, sizeof(cimgui.ImS16))
    elif values.typecode == 'H':
        cimplot.PlotBarsH1[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>values.data.as_ushorts, count, height, shift, offset, sizeof(cimgui.ImU16))
    elif values.typecode == 'b':
        cimplot.PlotBarsH1[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>values.data.as_schars, count, height, shift, offset, sizeof(cimgui.ImS8))
    elif values.typecode == 'B':
        cimplot.PlotBarsH1[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>values.data.as_uchars, count, height, shift, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_barsh2(str label_id, array.array xs, array.array ys, int count, double height, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd':
        cimplot.PlotBarsH2[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, count, height, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f':
        cimplot.PlotBarsH2[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, count, height, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q':
        cimplot.PlotBarsH2[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, count, height, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q':
        cimplot.PlotBarsH2[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, count, height, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l':
        cimplot.PlotBarsH2[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, count, height, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L':
        cimplot.PlotBarsH2[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, count, height, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h':
        cimplot.PlotBarsH2[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, count, height, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H':
        cimplot.PlotBarsH2[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, count, height, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b':
        cimplot.PlotBarsH2[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, count, height, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B':
        cimplot.PlotBarsH2[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, count, height, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_barshg(str label_id, object callback, data, int count, double height, int offset=0):
    cdef _callback_info _cb_info = _callback_info()
    cdef cimplot.ImPlotGetterCallback _callback = NULL
    cdef void *_data = NULL
    if callback is not None:
        _callback = _ImPlotGetterCallback
        _cb_info.populate(callback, data)
        _data = <void*>_cb_info
    cimplot.PlotBarsHG(_bytes(label_id), _callback, _data, count, height, offset)


def plot_error_bars1(str label_id, array.array xs, array.array ys, array.array err, int count, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd' and err.typecode == 'd':
        cimplot.PlotErrorBars1[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, err.data.as_doubles, count, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f' and err.typecode == 'f':
        cimplot.PlotErrorBars1[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, err.data.as_floats, count, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q' and err.typecode == 'q':
        cimplot.PlotErrorBars1[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, <cimgui.ImS64*>err.data.as_longlongs, count, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q' and err.typecode == 'Q':
        cimplot.PlotErrorBars1[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, <cimgui.ImU64*>err.data.as_ulonglongs, count, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l' and err.typecode == 'l':
        cimplot.PlotErrorBars1[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, <cimgui.ImS32*>err.data.as_longs, count, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L' and err.typecode == 'L':
        cimplot.PlotErrorBars1[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, <cimgui.ImU32*>err.data.as_ulongs, count, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h' and err.typecode == 'h':
        cimplot.PlotErrorBars1[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, <cimgui.ImS16*>err.data.as_shorts, count, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H' and err.typecode == 'H':
        cimplot.PlotErrorBars1[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, <cimgui.ImU16*>err.data.as_ushorts, count, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b' and err.typecode == 'b':
        cimplot.PlotErrorBars1[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, <cimgui.ImS8*>err.data.as_schars, count, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B' and err.typecode == 'B':
        cimplot.PlotErrorBars1[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, <cimgui.ImU8*>err.data.as_uchars, count, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_error_bars2(str label_id, array.array xs, array.array ys, array.array neg, array.array pos, int count, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd' and neg.typecode == 'd' and pos.typecode == 'd':
        cimplot.PlotErrorBars2[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, neg.data.as_doubles, pos.data.as_doubles, count, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f' and neg.typecode == 'f' and pos.typecode == 'f':
        cimplot.PlotErrorBars2[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, neg.data.as_floats, pos.data.as_floats, count, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q' and neg.typecode == 'q' and pos.typecode == 'q':
        cimplot.PlotErrorBars2[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, <cimgui.ImS64*>neg.data.as_longlongs, <cimgui.ImS64*>pos.data.as_longlongs, count, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q' and neg.typecode == 'Q' and pos.typecode == 'Q':
        cimplot.PlotErrorBars2[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, <cimgui.ImU64*>neg.data.as_ulonglongs, <cimgui.ImU64*>pos.data.as_ulonglongs, count, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l' and neg.typecode == 'l' and pos.typecode == 'l':
        cimplot.PlotErrorBars2[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, <cimgui.ImS32*>neg.data.as_longs, <cimgui.ImS32*>pos.data.as_longs, count, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L' and neg.typecode == 'L' and pos.typecode == 'L':
        cimplot.PlotErrorBars2[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, <cimgui.ImU32*>neg.data.as_ulongs, <cimgui.ImU32*>pos.data.as_ulongs, count, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h' and neg.typecode == 'h' and pos.typecode == 'h':
        cimplot.PlotErrorBars2[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, <cimgui.ImS16*>neg.data.as_shorts, <cimgui.ImS16*>pos.data.as_shorts, count, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H' and neg.typecode == 'H' and pos.typecode == 'H':
        cimplot.PlotErrorBars2[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, <cimgui.ImU16*>neg.data.as_ushorts, <cimgui.ImU16*>pos.data.as_ushorts, count, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b' and neg.typecode == 'b' and pos.typecode == 'b':
        cimplot.PlotErrorBars2[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, <cimgui.ImS8*>neg.data.as_schars, <cimgui.ImS8*>pos.data.as_schars, count, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B' and neg.typecode == 'B' and pos.typecode == 'B':
        cimplot.PlotErrorBars2[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, <cimgui.ImU8*>neg.data.as_uchars, <cimgui.ImU8*>pos.data.as_uchars, count, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_error_barsh1(str label_id, array.array xs, array.array ys, array.array err, int count, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd' and err.typecode == 'd':
        cimplot.PlotErrorBarsH1[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, err.data.as_doubles, count, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f' and err.typecode == 'f':
        cimplot.PlotErrorBarsH1[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, err.data.as_floats, count, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q' and err.typecode == 'q':
        cimplot.PlotErrorBarsH1[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, <cimgui.ImS64*>err.data.as_longlongs, count, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q' and err.typecode == 'Q':
        cimplot.PlotErrorBarsH1[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, <cimgui.ImU64*>err.data.as_ulonglongs, count, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l' and err.typecode == 'l':
        cimplot.PlotErrorBarsH1[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, <cimgui.ImS32*>err.data.as_longs, count, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L' and err.typecode == 'L':
        cimplot.PlotErrorBarsH1[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, <cimgui.ImU32*>err.data.as_ulongs, count, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h' and err.typecode == 'h':
        cimplot.PlotErrorBarsH1[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, <cimgui.ImS16*>err.data.as_shorts, count, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H' and err.typecode == 'H':
        cimplot.PlotErrorBarsH1[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, <cimgui.ImU16*>err.data.as_ushorts, count, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b' and err.typecode == 'b':
        cimplot.PlotErrorBarsH1[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, <cimgui.ImS8*>err.data.as_schars, count, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B' and err.typecode == 'B':
        cimplot.PlotErrorBarsH1[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, <cimgui.ImU8*>err.data.as_uchars, count, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_error_barsh2(str label_id, array.array xs, array.array ys, array.array neg, array.array pos, int count, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd' and neg.typecode == 'd' and pos.typecode == 'd':
        cimplot.PlotErrorBarsH2[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, neg.data.as_doubles, pos.data.as_doubles, count, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f' and neg.typecode == 'f' and pos.typecode == 'f':
        cimplot.PlotErrorBarsH2[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, neg.data.as_floats, pos.data.as_floats, count, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q' and neg.typecode == 'q' and pos.typecode == 'q':
        cimplot.PlotErrorBarsH2[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, <cimgui.ImS64*>neg.data.as_longlongs, <cimgui.ImS64*>pos.data.as_longlongs, count, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q' and neg.typecode == 'Q' and pos.typecode == 'Q':
        cimplot.PlotErrorBarsH2[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, <cimgui.ImU64*>neg.data.as_ulonglongs, <cimgui.ImU64*>pos.data.as_ulonglongs, count, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l' and neg.typecode == 'l' and pos.typecode == 'l':
        cimplot.PlotErrorBarsH2[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, <cimgui.ImS32*>neg.data.as_longs, <cimgui.ImS32*>pos.data.as_longs, count, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L' and neg.typecode == 'L' and pos.typecode == 'L':
        cimplot.PlotErrorBarsH2[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, <cimgui.ImU32*>neg.data.as_ulongs, <cimgui.ImU32*>pos.data.as_ulongs, count, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h' and neg.typecode == 'h' and pos.typecode == 'h':
        cimplot.PlotErrorBarsH2[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, <cimgui.ImS16*>neg.data.as_shorts, <cimgui.ImS16*>pos.data.as_shorts, count, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H' and neg.typecode == 'H' and pos.typecode == 'H':
        cimplot.PlotErrorBarsH2[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, <cimgui.ImU16*>neg.data.as_ushorts, <cimgui.ImU16*>pos.data.as_ushorts, count, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b' and neg.typecode == 'b' and pos.typecode == 'b':
        cimplot.PlotErrorBarsH2[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, <cimgui.ImS8*>neg.data.as_schars, <cimgui.ImS8*>pos.data.as_schars, count, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B' and neg.typecode == 'B' and pos.typecode == 'B':
        cimplot.PlotErrorBarsH2[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, <cimgui.ImU8*>neg.data.as_uchars, <cimgui.ImU8*>pos.data.as_uchars, count, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_stems1(str label_id, array.array values, int count, double y_ref=0, double xscale=1, double x0=0, int offset=0, int stride=0):
    if values.typecode == 'd':
        cimplot.PlotStems1[double](_bytes(label_id), values.data.as_doubles, count, y_ref, xscale, x0, offset, sizeof(double))
    elif values.typecode == 'f':
        cimplot.PlotStems1[float](_bytes(label_id), values.data.as_floats, count, y_ref, xscale, x0, offset, sizeof(float))
    elif values.typecode == 'q':
        cimplot.PlotStems1[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>values.data.as_longlongs, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImS64))
    elif values.typecode == 'Q':
        cimplot.PlotStems1[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>values.data.as_ulonglongs, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImU64))
    elif values.typecode == 'l':
        cimplot.PlotStems1[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>values.data.as_longs, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImS32))
    elif values.typecode == 'L':
        cimplot.PlotStems1[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>values.data.as_ulongs, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImU32))
    elif values.typecode == 'h':
        cimplot.PlotStems1[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>values.data.as_shorts, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImS16))
    elif values.typecode == 'H':
        cimplot.PlotStems1[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>values.data.as_ushorts, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImU16))
    elif values.typecode == 'b':
        cimplot.PlotStems1[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>values.data.as_schars, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImS8))
    elif values.typecode == 'B':
        cimplot.PlotStems1[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>values.data.as_uchars, count, y_ref, xscale, x0, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_stems2(str label_id, array.array xs, array.array ys, int count, double y_ref=0, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd':
        cimplot.PlotStems2[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, count, y_ref, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f':
        cimplot.PlotStems2[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, count, y_ref, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q':
        cimplot.PlotStems2[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, count, y_ref, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q':
        cimplot.PlotStems2[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, count, y_ref, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l':
        cimplot.PlotStems2[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, count, y_ref, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L':
        cimplot.PlotStems2[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, count, y_ref, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h':
        cimplot.PlotStems2[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, count, y_ref, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H':
        cimplot.PlotStems2[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, count, y_ref, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b':
        cimplot.PlotStems2[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, count, y_ref, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B':
        cimplot.PlotStems2[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, count, y_ref, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_vlines1(str label_id, array.array xs, int count, int offset=0, int stride=0):
    if xs.typecode == 'd':
        cimplot.PlotVLines1[double](_bytes(label_id), xs.data.as_doubles, count, offset, sizeof(double))
    elif xs.typecode == 'f':
        cimplot.PlotVLines1[float](_bytes(label_id), xs.data.as_floats, count, offset, sizeof(float))
    elif xs.typecode == 'q':
        cimplot.PlotVLines1[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, count, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q':
        cimplot.PlotVLines1[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, count, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l':
        cimplot.PlotVLines1[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, count, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L':
        cimplot.PlotVLines1[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, count, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h':
        cimplot.PlotVLines1[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, count, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H':
        cimplot.PlotVLines1[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, count, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b':
        cimplot.PlotVLines1[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, count, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B':
        cimplot.PlotVLines1[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, count, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_hlines1(str label_id, array.array ys, int count, int offset=0, int stride=0):
    if ys.typecode == 'd':
        cimplot.PlotHLines1[double](_bytes(label_id), ys.data.as_doubles, count, offset, sizeof(double))
    elif ys.typecode == 'f':
        cimplot.PlotHLines1[float](_bytes(label_id), ys.data.as_floats, count, offset, sizeof(float))
    elif ys.typecode == 'q':
        cimplot.PlotHLines1[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>ys.data.as_longlongs, count, offset, sizeof(cimgui.ImS64))
    elif ys.typecode == 'Q':
        cimplot.PlotHLines1[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>ys.data.as_ulonglongs, count, offset, sizeof(cimgui.ImU64))
    elif ys.typecode == 'l':
        cimplot.PlotHLines1[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>ys.data.as_longs, count, offset, sizeof(cimgui.ImS32))
    elif ys.typecode == 'L':
        cimplot.PlotHLines1[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>ys.data.as_ulongs, count, offset, sizeof(cimgui.ImU32))
    elif ys.typecode == 'h':
        cimplot.PlotHLines1[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>ys.data.as_shorts, count, offset, sizeof(cimgui.ImS16))
    elif ys.typecode == 'H':
        cimplot.PlotHLines1[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>ys.data.as_ushorts, count, offset, sizeof(cimgui.ImU16))
    elif ys.typecode == 'b':
        cimplot.PlotHLines1[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>ys.data.as_schars, count, offset, sizeof(cimgui.ImS8))
    elif ys.typecode == 'B':
        cimplot.PlotHLines1[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>ys.data.as_uchars, count, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")



def plot_pie_chart(label_ids, array.array values, int count, double x, double y, double radius, bool normalize=False, str label_fmt="%.1f", double angle0=90):
    # XXX: add checks for n_ticks == len(labels), and more..
    # create python reference to labels
    py_label_ids = [_bytes(label_id) for label_id in label_ids]
    # create C strings from above python references
    cdef char **c_label_ids = NULL
    cdef int i
    c_label_ids = <char **>malloc(len(label_ids) * sizeof(char *))
    for i, s in enumerate(py_label_ids):
        c_label_ids[i] = s

    if values.typecode == 'd':
        cimplot.PlotPieChart[double](c_label_ids, values.data.as_doubles, count, x, y, radius, normalize, _bytes(label_fmt), angle0)
    elif values.typecode == 'f':
        cimplot.PlotPieChart[float](c_label_ids, values.data.as_floats, count, x, y, radius, normalize, _bytes(label_fmt), angle0)
    elif values.typecode == 'q':
        cimplot.PlotPieChart[cimgui.ImS64](c_label_ids, <cimgui.ImS64*>values.data.as_longlongs, count, x, y, radius, normalize, _bytes(label_fmt), angle0)
    elif values.typecode == 'Q':
        cimplot.PlotPieChart[cimgui.ImU64](c_label_ids, <cimgui.ImU64*>values.data.as_ulonglongs, count, x, y, radius, normalize, _bytes(label_fmt), angle0)
    elif values.typecode == 'l':
        cimplot.PlotPieChart[cimgui.ImS32](c_label_ids, <cimgui.ImS32*>values.data.as_longs, count, x, y, radius, normalize, _bytes(label_fmt), angle0)
    elif values.typecode == 'L':
        cimplot.PlotPieChart[cimgui.ImU32](c_label_ids, <cimgui.ImU32*>values.data.as_ulongs, count, x, y, radius, normalize, _bytes(label_fmt), angle0)
    elif values.typecode == 'h':
        cimplot.PlotPieChart[cimgui.ImS16](c_label_ids, <cimgui.ImS16*>values.data.as_shorts, count, x, y, radius, normalize, _bytes(label_fmt), angle0)
    elif values.typecode == 'H':
        cimplot.PlotPieChart[cimgui.ImU16](c_label_ids, <cimgui.ImU16*>values.data.as_ushorts, count, x, y, radius, normalize, _bytes(label_fmt), angle0)
    elif values.typecode == 'b':
        cimplot.PlotPieChart[cimgui.ImS8](c_label_ids, <cimgui.ImS8*>values.data.as_schars, count, x, y, radius, normalize, _bytes(label_fmt), angle0)
    elif values.typecode == 'B':
        cimplot.PlotPieChart[cimgui.ImU8](c_label_ids, <cimgui.ImU8*>values.data.as_uchars, count, x, y, radius, normalize, _bytes(label_fmt), angle0)
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")

    for i, s in enumerate(py_label_ids):
        free(c_label_ids[i])
    free(c_label_ids)


def plot_heatmap(str label_id, array.array values, int rows, int cols, double scale_min=0.0, double scale_max=0.0, str label_fmt="%.1f", bounds_min=(0,0), bounds_max=(1,1)):
    cdef cimplot.ImPlotPoint _bounds_min
    _bounds_min.x = bounds_min[0]
    _bounds_min.y = bounds_min[1]
    cdef cimplot.ImPlotPoint _bounds_max
    _bounds_max.x = bounds_max[0]
    _bounds_max.y = bounds_max[1]

    if values.typecode == 'd':
        cimplot.PlotHeatmap[double](_bytes(label_id), values.data.as_doubles, rows, cols, scale_min, scale_max, _bytes(label_fmt), _bounds_min, _bounds_max)
    elif values.typecode == 'f':
        cimplot.PlotHeatmap[float](_bytes(label_id), values.data.as_floats, rows, cols, scale_min, scale_max, _bytes(label_fmt), _bounds_min, _bounds_max)
    elif values.typecode == 'q':
        cimplot.PlotHeatmap[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>values.data.as_longlongs, rows, cols, scale_min, scale_max, _bytes(label_fmt), _bounds_min, _bounds_max)
    elif values.typecode == 'Q':
        cimplot.PlotHeatmap[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>values.data.as_ulonglongs, rows, cols, scale_min, scale_max, _bytes(label_fmt), _bounds_min, _bounds_max)
    elif values.typecode == 'l':
        cimplot.PlotHeatmap[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>values.data.as_longs, rows, cols, scale_min, scale_max, _bytes(label_fmt), _bounds_min, _bounds_max)
    elif values.typecode == 'L':
        cimplot.PlotHeatmap[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>values.data.as_ulongs, rows, cols, scale_min, scale_max, _bytes(label_fmt), _bounds_min, _bounds_max)
    elif values.typecode == 'h':
        cimplot.PlotHeatmap[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>values.data.as_shorts, rows, cols, scale_min, scale_max, _bytes(label_fmt), _bounds_min, _bounds_max)
    elif values.typecode == 'H':
        cimplot.PlotHeatmap[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>values.data.as_ushorts, rows, cols, scale_min, scale_max, _bytes(label_fmt), _bounds_min, _bounds_max)
    elif values.typecode == 'b':
        cimplot.PlotHeatmap[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>values.data.as_schars, rows, cols, scale_min, scale_max, _bytes(label_fmt), _bounds_min, _bounds_max)
    elif values.typecode == 'B':
        cimplot.PlotHeatmap[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>values.data.as_uchars, rows, cols, scale_min, scale_max, _bytes(label_fmt), _bounds_min, _bounds_max)
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_histogram(str label_id, array.array values, int count, int bins=cimplot.ImPlotBin_Sturges, bool cumulative=False, bool density=False, tuple range=(0.0, 0.0), bool outliers=True, double bar_scale=1.0):
    cdef cimplot.ImPlotRange _range
    _range.x = range[0]
    _range.y = range[1]

    if values.typecode == 'd':
        cimplot.PlotHistogram[double](_bytes(label_id), values.data.as_doubles, count, bins, cumulative, density, _range, outliers, bar_scale)
    elif values.typecode == 'f':
        cimplot.PlotHistogram[float](_bytes(label_id), values.data.as_floats, count, bins, cumulative, density, _range, outliers, bar_scale)
    elif values.typecode == 'q':
        cimplot.PlotHistogram[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>values.data.as_longlongs, count, bins, cumulative, density, _range, outliers, bar_scale)
    elif values.typecode == 'Q':
        cimplot.PlotHistogram[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>values.data.as_ulonglongs, count, bins, cumulative, density, _range, outliers, bar_scale)
    elif values.typecode == 'l':
        cimplot.PlotHistogram[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>values.data.as_longs, count, bins, cumulative, density, _range, outliers, bar_scale)
    elif values.typecode == 'L':
        cimplot.PlotHistogram[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>values.data.as_ulongs, count, bins, cumulative, density, _range, outliers, bar_scale)
    elif values.typecode == 'h':
        cimplot.PlotHistogram[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>values.data.as_shorts, count, bins, cumulative, density, _range, outliers, bar_scale)
    elif values.typecode == 'H':
        cimplot.PlotHistogram[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>values.data.as_ushorts, count, bins, cumulative, density, _range, outliers, bar_scale)
    elif values.typecode == 'b':
        cimplot.PlotHistogram[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>values.data.as_schars, count, bins, cumulative, density, _range, outliers, bar_scale)
    elif values.typecode == 'B':
        cimplot.PlotHistogram[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>values.data.as_uchars, count, bins, cumulative, density, _range, outliers, bar_scale)
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_histogram_2d(str label_id, array.array xs, array.array ys, int count, int x_bins=cimplot.ImPlotBin_Sturges, int y_bins=cimplot.ImPlotBin_Sturges, bool density=False, tuple range=(0.0, 0.0, 0.0, 0.0), bool outliers=True):
    cdef cimplot.ImPlotRange _X
    _X.x = range[0]
    _X.y = range[1]
    cdef cimplot.ImPlotRange _Y
    _Y.x = range[2]
    _Y.y = range[3]
    cdef cimplot.ImPlotLimits _range
    _range.X = _X
    _range.Y = _Y

    if xs.typecode == 'd' and ys.typecode == 'd':
        cimplot.PlotHistogram2D[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, count, x_bins, y_bins, density, _range, outliers)
    elif xs.typecode == 'f' and ys.typecode == 'f':
        cimplot.PlotHistogram2D[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, count, x_bins, y_bins, density, _range, outliers)
    elif xs.typecode == 'q' and ys.typecode == 'q':
        cimplot.PlotHistogram2D[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, count, x_bins, y_bins, density, _range, outliers)
    elif xs.typecode == 'Q' and ys.typecode == 'Q':
        cimplot.PlotHistogram2D[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, count, x_bins, y_bins, density, _range, outliers)
    elif xs.typecode == 'l' and ys.typecode == 'l':
        cimplot.PlotHistogram2D[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, count, x_bins, y_bins, density, _range, outliers)
    elif xs.typecode == 'L' and ys.typecode == 'L':
        cimplot.PlotHistogram2D[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, count, x_bins, y_bins, density, _range, outliers)
    elif xs.typecode == 'h' and ys.typecode == 'h':
        cimplot.PlotHistogram2D[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, count, x_bins, y_bins, density, _range, outliers)
    elif xs.typecode == 'H' and ys.typecode == 'H':
        cimplot.PlotHistogram2D[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, count, x_bins, y_bins, density, _range, outliers)
    elif xs.typecode == 'b' and ys.typecode == 'b':
        cimplot.PlotHistogram2D[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, count, x_bins, y_bins, density, _range, outliers)
    elif xs.typecode == 'B' and ys.typecode == 'B':
        cimplot.PlotHistogram2D[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, count, x_bins, y_bins, density, _range, outliers)
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_digital(str label_id, array.array xs, array.array ys, int count, int offset=0, int stride=0):
    if xs.typecode == 'd' and ys.typecode == 'd':
        cimplot.PlotDigital[double](_bytes(label_id), xs.data.as_doubles, ys.data.as_doubles, count, offset, sizeof(double))
    elif xs.typecode == 'f' and ys.typecode == 'f':
        cimplot.PlotDigital[float](_bytes(label_id), xs.data.as_floats, ys.data.as_floats, count, offset, sizeof(float))
    elif xs.typecode == 'q' and ys.typecode == 'q':
        cimplot.PlotDigital[cimgui.ImS64](_bytes(label_id), <cimgui.ImS64*>xs.data.as_longlongs, <cimgui.ImS64*>ys.data.as_longlongs, count, offset, sizeof(cimgui.ImS64))
    elif xs.typecode == 'Q' and ys.typecode == 'Q':
        cimplot.PlotDigital[cimgui.ImU64](_bytes(label_id), <cimgui.ImU64*>xs.data.as_ulonglongs, <cimgui.ImU64*>ys.data.as_ulonglongs, count, offset, sizeof(cimgui.ImU64))
    elif xs.typecode == 'l' and ys.typecode == 'l':
        cimplot.PlotDigital[cimgui.ImS32](_bytes(label_id), <cimgui.ImS32*>xs.data.as_longs, <cimgui.ImS32*>ys.data.as_longs, count, offset, sizeof(cimgui.ImS32))
    elif xs.typecode == 'L' and ys.typecode == 'L':
        cimplot.PlotDigital[cimgui.ImU32](_bytes(label_id), <cimgui.ImU32*>xs.data.as_ulongs, <cimgui.ImU32*>ys.data.as_ulongs, count, offset, sizeof(cimgui.ImU32))
    elif xs.typecode == 'h' and ys.typecode == 'h':
        cimplot.PlotDigital[cimgui.ImS16](_bytes(label_id), <cimgui.ImS16*>xs.data.as_shorts, <cimgui.ImS16*>ys.data.as_shorts, count, offset, sizeof(cimgui.ImS16))
    elif xs.typecode == 'H' and ys.typecode == 'H':
        cimplot.PlotDigital[cimgui.ImU16](_bytes(label_id), <cimgui.ImU16*>xs.data.as_ushorts, <cimgui.ImU16*>ys.data.as_ushorts, count, offset, sizeof(cimgui.ImU16))
    elif xs.typecode == 'b' and ys.typecode == 'b':
        cimplot.PlotDigital[cimgui.ImS8](_bytes(label_id), <cimgui.ImS8*>xs.data.as_schars, <cimgui.ImS8*>ys.data.as_schars, count, offset, sizeof(cimgui.ImS8))
    elif xs.typecode == 'B' and ys.typecode == 'B':
        cimplot.PlotDigital[cimgui.ImU8](_bytes(label_id), <cimgui.ImU8*>xs.data.as_uchars, <cimgui.ImU8*>ys.data.as_uchars, count, offset, sizeof(cimgui.ImU8))
    else:
        raise ValueError("Style value must be float, double, ImS8, ImU8, ImS16, ImU16, ImS32, ImU32, ImS64, ImU64")


def plot_digitalg(str label_id, object callback, data, int count, int offset=0):
    cdef _callback_info _cb_info = _callback_info()
    cdef cimplot.ImPlotGetterCallback _callback = NULL
    cdef void *_data = NULL
    if callback is not None:
        _callback = _ImPlotGetterCallback
        _cb_info.populate(callback, data)
        _data = <void*>_cb_info
    cimplot.PlotDigitalG(_bytes(label_id), _callback, _data, count, offset)


def plot_text(str text, double x, double y, bool vertical=False, pix_offset=(0,0)):
    cimplot.PlotText(_bytes(text), x, y, vertical, _cast_tuple_ImVec2(pix_offset))


def plot_image(str label_id, user_texture_id, tuple bounds_min, tuple bounds_max, tuple uv0=(0,0), tuple uv1=(1,1), tuple tint_col=(1,1,1,1)):
    cdef cimplot.ImPlotPoint _bounds_min
    _bounds_min.x = bounds_min[0]
    _bounds_min.y = bounds_min[1]
    cdef cimplot.ImPlotPoint _bounds_max
    _bounds_max.x = bounds_max[0]
    _bounds_max.y = bounds_max[1]
    cimplot.PlotImage(_bytes(label_id), <void*>user_texture_id, _bounds_min, _bounds_max, _cast_tuple_ImVec2(uv0), _cast_tuple_ImVec2(uv1), _cast_tuple_ImVec4(tint_col))


def plot_dummy(str label_id):
    cimplot.PlotDummy(_bytes(label_id))






def set_next_plot_limits(double xmin, double xmax, double ymin, double ymax, cimgui.ImGuiCond cond = enums.ImGuiCond_Once):
    cimplot.SetNextPlotLimits(xmin, xmax, ymin, ymax, cond)


def set_next_plot_limits_x(double xmin, double xmax, cimgui.ImGuiCond cond = enums.ImGuiCond_Once):
    cimplot.SetNextPlotLimitsX(xmin, xmax, cond)


def set_next_plot_limits_y(double ymin, double ymax, cimgui.ImGuiCond cond = enums.ImGuiCond_Once, cimplot.ImPlotYAxis y_axis = 0):
    cimplot.SetNextPlotLimitsY(ymin, ymax, cond, y_axis)


# XXX: The pointer data must remain valid until the matching call EndPlot.
#      Q: How to achieve that?!
#def link_next_plot_limits(double* xmin, double* xmax, double* ymin, double* ymax, double* ymin2 = NULL, double* ymax2 = NULL, double* ymin3 = NULL, double* ymax3 = NULL):
#    cimplot.LinkNextPlotLimits(double* xmin, double* xmax, double* ymin, double* ymax, double* ymin2 = NULL, double* ymax2 = NULL, double* ymin3 = NULL, double* ymax3 = NULL)


def fit_next_plot_axes(bool x = True, bool y = True, bool y2 = True, bool y3 = True):
    cimplot.FitNextPlotAxes(x, y, y2, y3)


def set_next_plot_ticks_x_range(double x_min, double x_max, int n_ticks, labels = None, bool show_default = False):
    # XXX: NOT tested
    # XXX: add checks for n_ticks == len(labels), and more..
    cdef char **c_labels
    cdef int i
    if not labels:
        c_labels = NULL
    else:
        c_labels = <char **>malloc(len(labels) * sizeof(char *))
        for i, s in enumerate(labels):
            c_labels[i] = s
    cimplot.SetNextPlotTicksX(x_min, x_max, n_ticks, c_labels, show_default)
    free(c_labels)


def set_next_plot_ticks_x(array.array values, int n_ticks, labels = None, bool show_default = False):
    # XXX: NOT tested
    # XXX: add checks for n_ticks == len(labels), and more..
    cdef char **c_labels
    cdef int i
    if not labels:
        c_labels = NULL
    else:
        c_labels = <char **>malloc(len(labels) * sizeof(char *))
        for i, s in enumerate(labels):
            c_labels[i] = s
    cimplot.SetNextPlotTicksX(values.data.as_doubles, n_ticks, c_labels, show_default)
    free(c_labels)


def set_next_plot_ticks_y_range(double y_min, double y_max, int n_ticks, labels = None, bool show_default = False, cimplot.ImPlotYAxis y_axis = 0):
    # XXX: NOT tested
    # XXX: add checks for n_ticks == len(labels), and more..
    cdef char **c_labels
    cdef int i
    if not labels:
        c_labels = NULL
    else:
        c_labels = <char **>malloc(len(labels) * sizeof(char *))
        for i, s in enumerate(labels):
            c_labels[i] = s
    cimplot.SetNextPlotTicksY(y_min, y_max, n_ticks, c_labels, show_default, y_axis)
    free(c_labels)


def set_next_plot_ticks_y(array.array values, int n_ticks, labels = None, bool show_default = False, cimplot.ImPlotYAxis y_axis = 0):
    # XXX: NOT tested
    # XXX: add checks for n_ticks == len(labels), and more..
    cdef char **c_labels
    cdef int i
    if not labels:
        c_labels = NULL
    else:
        c_labels = <char **>malloc(len(labels) * sizeof(char *))
        for i, s in enumerate(labels):
            c_labels[i] = s
    cimplot.SetNextPlotTicksY(values.data.as_doubles, n_ticks, c_labels, show_default, y_axis)
    free(c_labels)


def set_plot_y_axis(cimplot.ImPlotYAxis y_axis):
    cimplot.SetPlotYAxis(y_axis)


def hide_next_item(bool hidden = True, cimgui.ImGuiCond cond = enums.ImGuiCond_Once):
    cimplot.HideNextItem(hidden, cond)


def pixels_to_plot(float x, float y, cimplot.ImPlotYAxis y_axis = -1):
    cdef cimplot.ImPlotPoint point
    point = cimplot.PixelsToPlot(x, y, y_axis)
    return point.x, point.y


def plot_to_pixels(double x, double y, cimplot.ImPlotYAxis y_axis = -1):
    return _cast_ImVec2_tuple(cimplot.PlotToPixels(x, y, y_axis))


def get_plot_pos():
    return _cast_ImVec2_tuple(cimplot.GetPlotPos())


def get_plot_size():
    return _cast_ImVec2_tuple(cimplot.GetPlotSize())


def is_plot_hovered():
    return cimplot.IsPlotHovered()

def is_plot_x_axis_hovered():
    return cimplot.IsPlotXAxisHovered()


def is_plot_y_axis_hovered(cimplot.ImPlotYAxis y_axis = 0):
    return cimplot.IsPlotYAxisHovered(y_axis)


def get_plot_mouse_pos(cimplot.ImPlotYAxis y_axis = -1):
    cdef cimplot.ImPlotPoint point
    point = cimplot.GetPlotMousePos(y_axis)
    return point.x, point.y


def get_plot_limits(cimplot.ImPlotYAxis y_axis = -1):
    cdef cimplot.ImPlotLimits limits
    limits = cimplot.GetPlotLimits(y_axis)
    return limits.X, limits.Y


def is_plot_queried():
    return cimplot.IsPlotQueried()


def get_plot_query(cimplot.ImPlotYAxis y_axis = -1):
    cdef cimplot.ImPlotLimits limits
    limits = cimplot.GetPlotQuery(y_axis)
    return limits.X, limits.Y


def annotate(double x, double y, double pix_offset_x, double pix_offset_y, str text):
    cimplot.Annotate(x, y, _cast_args_ImVec2(pix_offset_x, pix_offset_y), "%s", _bytes(text))


def annotate_color(double x, double y, double pix_offset_x, double pix_offset_y,
    float r, float g, float b, float a, str text):
    cimplot.Annotate(x, y, _cast_args_ImVec2(pix_offset_x, pix_offset_y), _cast_args_ImVec4(r, g, b, a), "%s", _bytes(text))


def annotate_clamped(double x, double y, double pix_offset_x, double pix_offset_y, str text):
    cimplot.AnnotateClamped(x, y, _cast_args_ImVec2(pix_offset_x, pix_offset_y), "%s", _bytes(text))


def annotate_clamped_color(double x, double y, double pix_offset_x, double pix_offset_y,
    float r, float g, float b, float a, str text):
    cimplot.AnnotateClamped(x, y, _cast_args_ImVec2(pix_offset_x, pix_offset_y), _cast_args_ImVec4(r, g, b, a), "%s", _bytes(text))

def drag_line_x(str id, double x_value, bool show_label = True,
    float r = 0., float g = 0., float b = 0., float a = -1., float thickness = 1.):
    cdef double inout_x = x_value
    return cimplot.DragLineX(
        _bytes(id), &inout_x, show_label, _cast_args_ImVec4(r, g, b, a), thickness
    ), inout_x


def drag_line_y(str id, double y_value, bool show_label = True,
    float r = 0., float g = 0., float b = 0., float a = -1., float thickness = 1.):
    cdef double inout_y = y_value
    return cimplot.DragLineY(
        _bytes(id), &inout_y, show_label, _cast_args_ImVec4(r, g, b, a), thickness
    ), inout_y


def drag_point(str id, double x, double y, bool show_label = True,
    float r = 0., float g = 0., float b = 0., float a = -1., float radius = 4.):
    cdef double inout_x = x
    cdef double inout_y = y
    return cimplot.DragPoint(
        _bytes(id), &inout_x, &inout_y, show_label, _cast_args_ImVec4(r, g, b, a), radius
    ), inout_x, inout_y


def set_legend_location(cimplot.ImPlotLocation location, cimplot.ImPlotOrientation orientation = cimplot.ImPlotOrientation_Vertical, bool outside = False):
    cimplot.SetLegendLocation(location, orientation, outside)


def set_mouse_pos_location(cimplot.ImPlotLocation location):
    cimplot.SetMousePosLocation(location)


def is_legend_entry_hovered(str label_id):
    return cimplot.IsLegendEntryHovered(label_id)


def begin_legend_popup(str label_id, cimgui.ImGuiMouseButton mouse_button = enums.ImGuiMouseButton_Right):
    return cimplot.BeginLegendPopup(label_id, mouse_button)


def end_legend_popup():
    cimplot.EndLegendPopup()


def begin_drag_drop_target():
    return cimplot.BeginDragDropTarget()


def begin_drag_drop_target_x():
    return cimplot.BeginDragDropTargetX()


def begin_drag_drop_target_y(cimplot.ImPlotYAxis axis = cimplot.ImPlotYAxis_1):
    return cimplot.BeginDragDropTargetY(axis)


def begin_drag_drop_target_legend():
    return cimplot.BeginDragDropTargetLegend()


def end_drag_drop_target():
    cimplot.EndDragDropTarget()


def begin_drag_drop_source(cimgui.ImGuiKeyModFlags key_mods = enums.ImGuiKeyModFlags_Ctrl, cimgui.ImGuiDragDropFlags flags = 0):
    return cimplot.BeginDragDropSource(key_mods, flags)


def begin_drag_drop_source_x(cimgui.ImGuiKeyModFlags key_mods = enums.ImGuiKeyModFlags_Ctrl, cimgui.ImGuiDragDropFlags flags = 0):
    return cimplot.BeginDragDropSourceX(key_mods, flags)


def begin_drag_drop_source_y(cimplot.ImPlotYAxis axis = cimplot.ImPlotYAxis_1, cimgui.ImGuiKeyModFlags key_mods = enums.ImGuiKeyModFlags_Ctrl, cimgui.ImGuiDragDropFlags flags = 0):
    return cimplot.BeginDragDropSourceY(axis, key_mods, flags)


def begin_drag_drop_source_item(str label_id, cimgui.ImGuiDragDropFlags flags=0):
    return cimplot.BeginDragDropSourceItem(label_id, flags)


def end_drag_drop_source():
    cimplot.EndDragDropSource()


def get_style():
    return PlotStyle.from_ref(cimplot.GetStyle())


def style_colors_auto(PlotStyle dst = None):
    if dst:
        cimplot.StyleColorsAuto(dst._ptr)
    else:
        cimplot.StyleColorsAuto(NULL)


def style_colors_dark(PlotStyle dst = None):
    if dst:
        cimplot.StyleColorsDark(dst._ptr)
    else:
        cimplot.StyleColorsDark(NULL)


def style_colors_classic(PlotStyle dst = None):
    if dst:
        cimplot.StyleColorsClassic(dst._ptr)
    else:
        cimplot.StyleColorsClassic(NULL)


def style_colors_light(PlotStyle dst = None):
    if dst:
        cimplot.StyleColorsLight(dst._ptr)
    else:
        cimplot.StyleColorsLight(NULL)


def plot_push_style_var(cimplot.ImPlotStyleVar variable, value):
    if not (0 <= variable < cimplot.ImPlotStyleVar_COUNT):
        warnings.warn("Unknown style variable: {}".format(variable))
        return False

    try:
        if isinstance(value, (tuple, list)):
            cimplot.PushStyleVar(variable, _cast_tuple_ImVec2(value))
        elif isinstance(value, float):
            cimplot.PushStyleVar(variable, <float>(float(value)))
        elif isinstance(value, int):
            cimplot.PushStyleVar(variable, <int>(int(value)))
    except ValueError:
        raise ValueError(
            "Style value must be float, or int or two-elements list/tuple"
        )
    else:
        return True


def plot_pop_style_var(int count=1):
    cimplot.PopStyleVar(count)


def set_next_line_style(tuple col = IMPLOT_AUTO_COL, float weight = IMPLOT_AUTO):
    cimplot.SetNextLineStyle(_cast_tuple_ImVec4(col), weight)


def set_next_fill_style(tuple col = IMPLOT_AUTO_COL, float alpha_mod = IMPLOT_AUTO):
    cimplot.SetNextFillStyle(_cast_tuple_ImVec4(col), alpha_mod)


def set_next_marker_style(cimplot.ImPlotMarker marker = IMPLOT_AUTO, float size = IMPLOT_AUTO, tuple fill = IMPLOT_AUTO_COL, float weight = IMPLOT_AUTO, tuple outline = IMPLOT_AUTO_COL):
    cimplot.SetNextMarkerStyle(marker, size, _cast_tuple_ImVec4(fill), weight, _cast_tuple_ImVec4(outline))


def set_next_error_bar_style(tuple col = IMPLOT_AUTO_COL, float size = IMPLOT_AUTO, float weight = IMPLOT_AUTO):
    cimplot.SetNextErrorBarStyle(_cast_tuple_ImVec4(col), size, weight)


def plot_push_style_color(
    cimplot.ImPlotCol variable,
    float r,
    float g,
    float b,
    float a = 1.
):
    if not (0 <= variable < cimplot.ImPlotCol_COUNT):
        warnings.warn("Unknown style variable: {}".format(variable))
        return False

    cimplot.PushStyleColor(variable, _cast_args_ImVec4(r, g, b, a))
    return True


def plot_pop_style_color(int count=1):
    cimplot.PopStyleColor(count)


def get_last_item_color():
    return _cast_ImVec4_tuple(cimplot.GetLastItemColor())


def get_style_color_name(int index):
    cdef const char* c_string = cimplot.GetStyleColorName(index)
    cdef bytes py_string = c_string
    return c_string.decode("utf-8")


def get_marker_name(int index):
    cdef const char* c_string = cimplot.GetMarkerName(index)
    cdef bytes py_string = c_string
    return c_string.decode("utf-8")


def add_colormap(str name, float r, float g, float b, float a, int size, bool qual=True):
    cdef cimgui.ImVec4 _vec
    _vec = _cast_args_ImVec4(r, g, b, a)
    cimplot.AddColormap(_bytes(name), &_vec, size, qual)


def get_colormap_count():
    return cimplot.GetColormapCount()


def get_colormap_name(cimplot.ImPlotColormap cmap):
    cdef const char* c_string = cimplot.GetColormapName(cmap)
    cdef bytes py_string = c_string
    return c_string.decode("utf-8")


def get_colormap_index(str name):
    return cimplot.GetColormapIndex(_bytes(name))


def push_colormap(cimplot.ImPlotColormap cmap):
    cimplot.PushColormap(cmap)


def push_colormap_name(str name):
    cimplot.PushColormap(name)


def pop_colormap(int count = 1):
    cimplot.PopColormap(count)


def next_colormap_color():
    return _cast_ImVec4_tuple(cimplot.NextColormapColor())


def get_colormap_size(cimplot.ImPlotColormap cmap = IMPLOT_AUTO):
    return cimplot.GetColormapSize(cmap)


def get_colormap_color(int idx, cimplot.ImPlotColormap cmap = IMPLOT_AUTO):
    return _cast_ImVec4_tuple(cimplot.GetColormapColor(idx, cmap))


def sample_colormap(float t, cimplot.ImPlotColormap cmap = IMPLOT_AUTO):
    return _cast_ImVec4_tuple(cimplot.SampleColormap(t, cmap))


def colormap_scale(str label, double scale_min, double scale_max, tuple size = (0,0), cimplot.ImPlotColormap cmap = IMPLOT_AUTO):
    cimplot.ColormapScale(_bytes(label), scale_min, scale_max, _cast_tuple_ImVec2(size), cmap)


def colormap_slider(str label, float t, str format = "", cimplot.ImPlotColormap cmap = IMPLOT_AUTO):
    cdef float _t = t
    cdef cimgui.ImVec4 _out
    _out = _cast_args_ImVec4(0.0, 0.0, 0.0, 0.0)
    return (
        cimplot.ColormapSlider(_bytes(label), &_t, &_out, _bytes(format), cmap),
        _cast_ImVec4_tuple(_out))


def colormap_button(str label, tuple size = (0,0), cimplot.ImPlotColormap cmap = IMPLOT_AUTO):
    return cimplot.ColormapButton(_bytes(label), _cast_tuple_ImVec2(size), cmap)


def bust_color_cache(str plot_title_id):
    cimplot.BustColorCache(_bytes(plot_title_id))


def item_icon_idx(value):
    cimplot.ItemIcon(<cimgui.ImU32>(value))


def item_icon_rgba(float r, float g, float b, float a = 1.):
    cimplot.ItemIcon(_cast_args_ImVec4(r, g, b, a))


def colormap_icon(cimplot.ImPlotColormap cmap = IMPLOT_AUTO):
    return cimplot.ColormapIcon(cmap)


def push_plot_clip_rect():
    cimplot.PushPlotClipRect()


def pop_plot_clip_rect():
    cimplot.PopPlotClipRect()


def show_style_selector(str label):
    return cimplot.ShowStyleSelector(_bytes(label))


def show_colormap_selector(str label):
    return cimplot.ShowColormapSelector(_bytes(label))


def show_style_editor(PlotStyle style=None):
    if style:
        cimplot.ShowStyleEditor(style._ptr)
    else:
        cimplot.ShowStyleEditor()


def show_user_guide():
    cimplot.ShowUserGuide()


def show_metrics_window(closable=False):
    cdef cimplot.bool opened = True

    if closable:
        cimplot.ShowMetricsWindow(&opened)
    else:
        cimplot.ShowMetricsWindow()

    return opened


def show_demo_window(closable=False):
    cdef cimplot.bool opened = True

    if closable:
        cimplot.ShowDemoWindow(&opened)
    else:
        cimplot.ShowDemoWindow()

    return opened