# -*- coding: utf-8 -*-
# distutils: language = c++
# distutils: include_dirs = implot-cpp
"""
Notes:
   `✓` marks API element as already mapped in core bindings.
   `✗` marks API element as "yet to be mapped
"""
from libcpp cimport bool

from cimgui cimport ImVec2, ImVec4, ImTextureID, ImGuiCond, ImGuiMouseButton, ImGuiKeyModFlags, ImGuiDragDropFlags, ImU32, ImDrawList, ImGuiContext

# Must be outside cdef extern from "implot.h" since it is not defined there
ctypedef ImPlotPoint (*ImPlotGetterCallback)(void* data, int idx)

cdef extern from "implot.h":
    #-----------------------------------------------------------------------------
    # Forward Declarations and Basic Types
    #-----------------------------------------------------------------------------

    # Forward declarations
    ctypedef struct ImPlotContext

    # Enums/Flags
    ctypedef int ImPlotFlags
    ctypedef int ImPlotAxisFlags
    ctypedef int ImPlotCol
    ctypedef int ImPlotStyleVar
    ctypedef int ImPlotMarker
    ctypedef int ImPlotColormap
    ctypedef int ImPlotLocation
    ctypedef int ImPlotOrientation
    ctypedef int ImPlotYAxis
    ctypedef int ImPlotBin

    # Options for plots.
    ctypedef enum ImPlotFlags_:
        ImPlotFlags_None,
        ImPlotFlags_NoTitle,
        ImPlotFlags_NoLegend,
        ImPlotFlags_NoMenus,
        ImPlotFlags_NoBoxSelect,
        ImPlotFlags_NoMousePos,
        ImPlotFlags_NoHighlight,
        ImPlotFlags_NoChild,
        ImPlotFlags_Equal,
        ImPlotFlags_YAxis2,
        ImPlotFlags_YAxis3,
        ImPlotFlags_Query,
        ImPlotFlags_Crosshairs,
        ImPlotFlags_AntiAliased,
        ImPlotFlags_CanvasOnly,

    # Options for plot axes (X and Y).
    ctypedef enum ImPlotAxisFlags_:
        ImPlotAxisFlags_None,
        ImPlotAxisFlags_NoLabel,
        ImPlotAxisFlags_NoGridLines,
        ImPlotAxisFlags_NoTickMarks,
        ImPlotAxisFlags_NoTickLabels,
        ImPlotAxisFlags_LogScale,
        ImPlotAxisFlags_Time,
        ImPlotAxisFlags_Invert,
        ImPlotAxisFlags_AutoFit,
        ImPlotAxisFlags_LockMin,
        ImPlotAxisFlags_LockMax,
        ImPlotAxisFlags_Lock,
        ImPlotAxisFlags_NoDecorations,

    # Plot styling colors.
    ctypedef enum ImPlotCol_:
        # item styling colors
        ImPlotCol_Line,
        ImPlotCol_Fill,
        ImPlotCol_MarkerOutline,
        ImPlotCol_MarkerFill,
        ImPlotCol_ErrorBar,
        # plot styling colors
        ImPlotCol_FrameBg,
        ImPlotCol_PlotBg,
        ImPlotCol_PlotBorder,
        ImPlotCol_LegendBg,
        ImPlotCol_LegendBorder,
        ImPlotCol_LegendText,
        ImPlotCol_TitleText,
        ImPlotCol_InlayText,
        ImPlotCol_XAxis,
        ImPlotCol_XAxisGrid,
        ImPlotCol_YAxis,
        ImPlotCol_YAxisGrid,
        ImPlotCol_YAxis2,
        ImPlotCol_YAxisGrid2,
        ImPlotCol_YAxis3,
        ImPlotCol_YAxisGrid3,
        ImPlotCol_Selection,
        ImPlotCol_Query,
        ImPlotCol_Crosshairs,
        ImPlotCol_COUNT

    # Plot styling variables.
    ctypedef enum ImPlotStyleVar_:
        # item styling variables
        ImPlotStyleVar_LineWeight,
        ImPlotStyleVar_Marker,
        ImPlotStyleVar_MarkerSize,
        ImPlotStyleVar_MarkerWeight,
        ImPlotStyleVar_FillAlpha,
        ImPlotStyleVar_ErrorBarSize,
        ImPlotStyleVar_ErrorBarWeight,
        ImPlotStyleVar_DigitalBitHeight,
        ImPlotStyleVar_DigitalBitGap,
        # plot styling variables
        ImPlotStyleVar_PlotBorderSize,
        ImPlotStyleVar_MinorAlpha,
        ImPlotStyleVar_MajorTickLen,
        ImPlotStyleVar_MinorTickLen,
        ImPlotStyleVar_MajorTickSize,
        ImPlotStyleVar_MinorTickSize,
        ImPlotStyleVar_MajorGridSize,
        ImPlotStyleVar_MinorGridSize,
        ImPlotStyleVar_PlotPadding,
        ImPlotStyleVar_LabelPadding,
        ImPlotStyleVar_LegendPadding,
        ImPlotStyleVar_LegendInnerPadding,
        ImPlotStyleVar_LegendSpacing,
        ImPlotStyleVar_MousePosPadding,
        ImPlotStyleVar_AnnotationPadding,
        ImPlotStyleVar_FitPadding,
        ImPlotStyleVar_PlotDefaultSize,
        ImPlotStyleVar_PlotMinSize,
        ImPlotStyleVar_COUNT

    # Marker specifications.
    ctypedef enum ImPlotMarker_:
        ImPlotMarker_None,
        ImPlotMarker_Circle,
        ImPlotMarker_Square,
        ImPlotMarker_Diamond,
        ImPlotMarker_Up,
        ImPlotMarker_Down,
        ImPlotMarker_Left,
        ImPlotMarker_Right,
        ImPlotMarker_Cross,
        ImPlotMarker_Plus,
        ImPlotMarker_Asterisk,
        ImPlotMarker_COUNT

    # Built-in colormaps
    ctypedef enum ImPlotColormap_:
        ImPlotColormap_Deep,
        ImPlotColormap_Dark,
        ImPlotColormap_Pastel,
        ImPlotColormap_Paired,
        ImPlotColormap_Viridis,
        ImPlotColormap_Plasma,
        ImPlotColormap_Hot,
        ImPlotColormap_Cool,
        ImPlotColormap_Pink,
        ImPlotColormap_Jet,
        ImPlotColormap_Twilight,
        ImPlotColormap_RdBu,
        ImPlotColormap_BrBG,
        ImPlotColormap_PiYG,
        ImPlotColormap_Spectral,
        ImPlotColormap_Greys,

    # Used to position items on a plot (e.g. legends, labels, etc.)
    ctypedef enum ImPlotLocation_:
        ImPlotLocation_Center,
        ImPlotLocation_North,
        ImPlotLocation_South,
        ImPlotLocation_West,
        ImPlotLocation_East,
        ImPlotLocation_NorthWest,
        ImPlotLocation_NorthEast,
        ImPlotLocation_SouthWest,
        ImPlotLocation_SouthEast,

    # Used to orient items on a plot (e.g. legends, labels, etc.)
    ctypedef enum ImPlotOrientation_:
        ImPlotOrientation_Horizontal,
        ImPlotOrientation_Vertical

    # Enums for different y-axes.
    ctypedef enum ImPlotYAxis_:
        ImPlotYAxis_1
        ImPlotYAxis_2
        ImPlotYAxis_3

    # Enums for different automatic histogram binning methods (k = bin count or w = bin width)
    ctypedef enum ImPlotBin_:
        ImPlotBin_Sqrt,
        ImPlotBin_Sturges,
        ImPlotBin_Rice,
        ImPlotBin_Scott,

    # Double precision version of ImVec2 used by ImPlot. Extensible by end users.
    ctypedef struct ImPlotPoint:
        double x
        double y

    # A range defined by a min/max value. Used for plot axes ranges.
    ctypedef struct ImPlotRange:
        double Min
        double Max

    # Combination of two ranges for X and Y axes.
    ctypedef struct ImPlotLimits:
        ImPlotRange X
        ImPlotRange Y

    # Plot style structure
    cdef cppclass ImPlotStyle:
        # item styling variables
        float   LineWeight
        int     Marker
        float   MarkerSize
        float   MarkerWeight
        float   FillAlpha
        float   ErrorBarSize
        float   ErrorBarWeight
        float   DigitalBitHeight
        float   DigitalBitGap
        # plot styling variables
        float   PlotBorderSize
        float   MinorAlpha
        ImVec2  MajorTickLen
        ImVec2  MinorTickLen
        ImVec2  MajorTickSize
        ImVec2  MinorTickSize
        ImVec2  MajorGridSize
        ImVec2  MinorGridSize
        ImVec2  PlotPadding
        ImVec2  LabelPadding
        ImVec2  LegendPadding
        ImVec2  LegendInnerPadding
        ImVec2  LegendSpacing
        ImVec2  MousePosPadding
        ImVec2  AnnotationPadding
        ImVec2  FitPadding
        ImVec2  PlotDefaultSize
        ImVec2  PlotMinSize
        # colors
        ImVec4  *Colors                                     #original: ImVec4  Colors[ImPlotCol_COUNT]
        # colormap
        ImPlotColormap Colormap
        # settings/flags
        bool    AntiAliasedLines
        bool    UseLocalTime
        bool    UseISO8601
        bool    Use24HourClock

cdef extern from "implot.h" namespace "ImPlot":

    #-----------------------------------------------------------------------------
    #  ImPlot Context
    #-----------------------------------------------------------------------------
    ImPlotContext* CreateContext() except + # ✓
    void DestroyContext( # ✓
        ImPlotContext* ctx                  # = NULL
        ) except +
    ImPlotContext* GetCurrentContext() except + # ✓
    void SetCurrentContext(ImPlotContext* ctx) except + # ✓
    void SetImGuiContext(ImGuiContext* ctx) except + # ✓

    #-----------------------------------------------------------------------------
    #  Begin/End Plot
    #-----------------------------------------------------------------------------
    bool BeginPlot( # ✓
        const char* title_id,
        const char* x_label,                # = NULL
        const char* y_label,                # = NULL
        const ImVec2& size,                 # = ImVec2(-1,0)
        ImPlotFlags flags,                  # = ImPlotFlags_None
        ImPlotAxisFlags x_flags,            # = ImPlotAxisFlags_None
        ImPlotAxisFlags y_flags,            # = ImPlotAxisFlags_None
        ImPlotAxisFlags y2_flags,           # = ImPlotAxisFlags_NoGridLines
        ImPlotAxisFlags y3_flags,           # = ImPlotAxisFlags_NoGridLines
        const char* y2_label,               # = NULL
        const char* y3_label,               # = NULL
        ) except +
    void EndPlot() except + # ✓

    #-----------------------------------------------------------------------------
    #  Plot Items
    #-----------------------------------------------------------------------------
    void PlotLine1 "ImPlot::PlotLine"[T]( # ✓
        const char* label_id,
        const T* values,
        int count,
        double xscale,                      # =1,
        double x0,                          # =0,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotLine2 "ImPlot::PlotLine"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        int count,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotLineG( # ✓
        const char* label_id,
        ImPlotGetterCallback callback,
        void* data,
        int count,
        int offset,                         # =0
        ) except +
    void PlotScatter1 "ImPlot::PlotScatter"[T]( # ✓
        const char* label_id,
        const T* values,
        int count,
        double xscale,                      # =1,
        double x0,                          # =0,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotScatter2 "ImPlot::PlotScatter"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        int count,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotScatterG( # ✓
        const char* label_id,
        ImPlotGetterCallback callback,
        void* data,
        int count,
        int offset,                         # =0
        ) except +
    void PlotStairs1 "ImPlot::PlotStairs"[T]( # ✓
        const char* label_id,
        const T* values,
        int count,
        double xscale,                      # =1,
        double x0,                          # =0,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotStairs2 "ImPlot::PlotStairs"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        int count,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotStairsG( # ✓
        const char* label_id,
        ImPlotGetterCallback callback,
        void* data,
        int count,
        int offset,                         # =0
        ) except +
    void PlotShaded1 "ImPlot::PlotShaded"[T]( # ✓
        const char* label_id,
        const T* values,
        int count,
        double y_ref,                       # =0,
        double xscale,                      # =1,
        double x0,                          # =0,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotShaded2 "ImPlot::PlotShaded"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        int count,
        double y_ref,                       # =0,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotShaded3 "ImPlot::PlotShaded"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys1,
        const T* ys2,
        int count,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotShadedG( # ✓
        const char* label_id,
        ImPlotGetterCallback callback1,
        void* data1,
        ImPlotGetterCallback callback2,
        void* data2,
        int count,
        int offset,                         # =0
        ) except +
    void PlotBars1 "ImPlot::PlotBars"[T]( # ✓
        const char* label_id,
        const T* values,
        int count,
        double width,                       # =0.67,
        double shift,                       # =0,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotBars2 "ImPlot::PlotBars"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        int count,
        double width,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotBarsG( # ✓
        const char* label_id,
        ImPlotGetterCallback callback,
        void* data,
        int count,
        double width,
        int offset,                         # =0
        ) except +
    void PlotBarsH1 "ImPlot::PlotBarsH"[T]( # ✓
        const char* label_id,
        const T* values,
        int count,
        double height,                      # =0.67,
        double shift,                       # =0,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotBarsH2 "ImPlot::PlotBarsH"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        int count,
        double height,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotBarsHG( # ✓
        const char* label_id,
        ImPlotGetterCallback callback,
        void* data,
        int count,
        double height,
        int offset,                         # =0
        ) except +
    void PlotErrorBars1 "ImPlot::PlotErrorBars"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        const T* err,
        int count,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotErrorBars2 "ImPlot::PlotErrorBars"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        const T* neg,
        const T* pos,
        int count,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotErrorBarsH1 "ImPlot::PlotErrorBarsH"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        const T* err,
        int count,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotErrorBarsH2 "ImPlot::PlotErrorBarsH"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        const T* neg,
        const T* pos,
        int count,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotStems1 "ImPlot::PlotStems"[T]( # ✓
        const char* label_id,
        const T* values,
        int count,
        double y_ref,                       # =0,
        double xscale,                      # =1,
        double x0,                          # =0,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotStems2 "ImPlot::PlotStems"[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        int count,
        double y_ref,                       # =0,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotVLines1 "ImPlot::PlotVLines"[T]( # ✓
        const char* label_id,
        const T* xs,
        int count,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotHLines1 "ImPlot::PlotHLines"[T]( # ✓
        const char* label_id,
        const T* ys,
        int count,
        int offset,                          # =0,
        int stride,                          # =sizeof(T)
        ) except +
    void PlotPieChart[T]( # ✓
        const char* const label_ids[],
        const T* values,
        int count,
        double x,
        double y,
        double radius,
        bool normalize,                     # =false,
        const char* label_fmt,              # ="%.1f",
        double angle0,                      # =90
        ) except +
    void PlotHeatmap[T]( # ✓
        const char* label_id,
        const T* values,
        int rows,
        int cols,
        double scale_min,                   # =0,
        double scale_max,                   # =0,
        const char* label_fmt,              # ="%.1f",
        const ImPlotPoint& bounds_min,      # =ImPlotPoint(0,0),
        const ImPlotPoint& bounds_max,      # =ImPlotPoint(1,1)
        ) except +
    double PlotHistogram[T]( # ✓
        const char* label_id,
        const T* values,
        int count,
        int bins,                           # =ImPlotBin_Sturges,
        bool cumulative,                    # =false,
        bool density,                       # =false,
        ImPlotRange range,                  # =ImPlotRange(),
        bool outliers,                      # =true,
        double bar_scale,                   # =1.0
        ) except +
    double PlotHistogram2D[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        int count,
        int x_bins,                         # =ImPlotBin_Sturges,
        int y_bins,                         # =ImPlotBin_Sturges,
        bool density,                       # =false,
        ImPlotLimits range,                 # =ImPlotLimits(),
        bool outliers                       # =true
        ) except +
    void PlotDigital[T]( # ✓
        const char* label_id,
        const T* xs,
        const T* ys,
        int count,
        int offset,                         # =0,
        int stride,                         # =sizeof(T)
        ) except +
    void PlotDigitalG( # ✓
        const char* label_id,
        ImPlotGetterCallback callback,
        void* data,
        int count,
        int offset,                         # =0
        ) except +
    void PlotImage( # ✓
        const char* label_id,
        ImTextureID user_texture_id,
        const ImPlotPoint& bounds_min,
        const ImPlotPoint& bounds_max,
        const ImVec2& uv0,                  # =ImVec2(0,0),
        const ImVec2& uv1,                  # =ImVec2(1,1),
        const ImVec4& tint_col,             # =ImVec4(1,1,1,1)
        ) except +
    void PlotText( # ✓
        const char* text,
        double x,
        double y,
        bool vertical,                      # =false,
        const ImVec2& pix_offset,           # =ImVec2(0,0)
        ) except +
    void PlotDummy(const char* label_id) except + # ✓

    #-----------------------------------------------------------------------------
    # Plot Utils
    #-----------------------------------------------------------------------------
    void SetNextPlotLimits( # ✓
        double xmin,
        double xmax,
        double ymin,
        double ymax,
        ImGuiCond cond,                     # = ImGuiCond_Once
        ) except +
    void SetNextPlotLimitsX( # ✓
        double xmin,
        double xmax,
        ImGuiCond cond,                     # = ImGuiCond_Once
        ) except +
    void SetNextPlotLimitsY( # ✓
        double ymin,
        double ymax,
        ImGuiCond cond,                     # = ImGuiCond_Once,
        ImPlotYAxis y_axis,                 # = 0
        ) except +
    void LinkNextPlotLimits( # ✗
        double* xmin,
        double* xmax,
        double* ymin,
        double* ymax,
        double* ymin2,                      # = NULL,
        double* ymax2,                      # = NULL,
        double* ymin3,                      # = NULL,
        double* ymax3,                      # = NULL
        ) except +
    void FitNextPlotAxes( # ✓
        bool x,                             # = true,
        bool y,                             # = true,
        bool y2,                            # = true,
        bool y3,                            # = true
        ) except +
    void SetNextPlotTicksX( # ✓
        const double* values,
        int n_ticks,
        const char* const labels[],         # = NULL,
        bool show_default,                  # = false
        ) except +
    void SetNextPlotTicksX( # ✓
        double x_min,
        double x_max,
        int n_ticks,
        const char* const labels[],         # = NULL,
        bool show_default,                  # = false
        ) except +
    void SetNextPlotTicksY( # ✓
        const double* values,
        int n_ticks,
        const char* const labels[],         # = NULL,
        bool show_default,                  # = false,
        ImPlotYAxis y_axis,                 # = 0
        ) except +
    void SetNextPlotTicksY( # ✓
        double y_min,
        double y_max,
        int n_ticks,
        const char* const labels[],         # = NULL,
        bool show_default,                  # = false,
        ImPlotYAxis y_axis,                 # = 0
        ) except +
    void SetPlotYAxis(ImPlotYAxis y_axis) except + # ✓
    void HideNextItem( # ✓
        bool hidden,                        # = true,
        ImGuiCond cond,                     # = ImGuiCond_Once
        ) except +
    ImPlotPoint PixelsToPlot( # ✓
        const ImVec2& pix,
        ImPlotYAxis y_axis,                 # = IMPLOT_AUTO
        ) except +
    ImPlotPoint PixelsToPlot( # ✓
        float x,
        float y,
        ImPlotYAxis y_axis,                 # = IMPLOT_AUTO
        ) except +
    ImVec2 PlotToPixels( # ✓
        const ImPlotPoint& plt,
        ImPlotYAxis y_axis,                 # = IMPLOT_AUTO
        ) except +
    ImVec2 PlotToPixels( # ✓
        double x,
        double y,
        ImPlotYAxis y_axis,                 # = IMPLOT_AUTO
        ) except +
    ImVec2 GetPlotPos() except + # ✓
    ImVec2 GetPlotSize() except + # ✓
    bool IsPlotHovered() except + # ✓
    bool IsPlotXAxisHovered() except + # ✓
    bool IsPlotYAxisHovered( # ✓
        ImPlotYAxis y_axis,                 # = 0
        ) except +
    ImPlotPoint GetPlotMousePos( # ✓
        ImPlotYAxis y_axis,                 # = IMPLOT_AUTO
        ) except +
    ImPlotLimits GetPlotLimits( # ✓
        ImPlotYAxis y_axis,                 # = IMPLOT_AUTO
        ) except +
    bool IsPlotQueried() except + # ✓
    ImPlotLimits GetPlotQuery( # ✓
        ImPlotYAxis y_axis,                 # = IMPLOT_AUTO
        ) except +

    #-----------------------------------------------------------------------------
    # Plot Tools
    #-----------------------------------------------------------------------------
    void Annotate( # ✓
        double x,
        double y,
        const ImVec2& pix_offset,
        const char* fmt,
        ...
        ) except +
    void Annotate( # ✓
        double x,
        double y,
        const ImVec2& pix_offset,
        const ImVec4& color,
        const char* fmt,
        ...
        ) except +
    #void AnnotateV(double x,
    #               double y,
    #               const ImVec2& pix_offset,
    #               const char* fmt,
    #               va_list args
    #             ) except +
    #void AnnotateV(double x,
    #               double y,
    #               const ImVec2& pix_offset,
    #               const ImVec4& color,
    #               const char* fmt,
    #               va_list args
    #              ) except +
    void AnnotateClamped( # ✓
        double x,
        double y,
        const ImVec2& pix_offset,
        const char* fmt,
        ...
        ) except +
    void AnnotateClamped( # ✓
        double x,
        double y,
        const ImVec2& pix_offset,
        const ImVec4& color,
        const char* fmt,
        ...
        ) except +
    #void AnnotateClampedV(double x,
    #                      double y,
    #                      const ImVec2& pix_offset,
    #                      const char* fmt,
    #                      va_list args
    #                     ) except +
    #void AnnotateClampedV(double x,
    #                      double y,
    #                      const ImVec2& pix_offset,
    #                      const ImVec4& color,
    #                      const char* fmt,
    #                      va_list args
    #                     ) except +
    bool DragLineX( # ✓
        const char* id,
        double* x_value,
        bool show_label,                    # = true,
        const ImVec4& col,                  # = IMPLOT_AUTO_COL,
        float thickness,                    # = 1
        ) except +
    bool DragLineY( # ✓
        const char* id,
        double* y_value,
        bool show_label,                    # = true,
        const ImVec4& col,                  # = IMPLOT_AUTO_COL,
        float thickness,                    # = 1
        ) except +
    bool DragPoint( # ✓
        const char* id,
        double* x,
        double* y,
        bool show_label,                    # = true,
        const ImVec4& col,                  # = IMPLOT_AUTO_COL,
        float radius,                       # = 4
        ) except +

    #-----------------------------------------------------------------------------
    # Legend Utils and Tools
    #-----------------------------------------------------------------------------
    void SetLegendLocation( # ✓
        ImPlotLocation location,
        ImPlotOrientation orientation,      # = ImPlotOrientation_Vertical,
        bool outside,                       # = false
        ) except +
    void SetMousePosLocation(ImPlotLocation location) except + # ✓
    bool IsLegendEntryHovered(const char* label_id) except + # ✓
    bool BeginLegendPopup( # ✓
        const char* label_id,
        ImGuiMouseButton mouse_button,      # = 1
        ) except +
    void EndLegendPopup() except + # ✓

    #-----------------------------------------------------------------------------
    # Drag and Drop Utils
    #-----------------------------------------------------------------------------
    bool BeginDragDropTarget() except + # ✓
    bool BeginDragDropTargetX() except + # ✓
    bool BeginDragDropTargetY( # ✓
        ImPlotYAxis axis                    # = ImPlotYAxis_1
        ) except +
    bool BeginDragDropTargetLegend() except + # ✓
    void EndDragDropTarget() except + # ✓
    bool BeginDragDropSource( # ✓
        ImGuiKeyModFlags key_mods,          # = ImGuiKeyModFlags_Ctrl,
        ImGuiDragDropFlags flags,           # = 0
        ) except +
    bool BeginDragDropSourceX( # ✓
        ImGuiKeyModFlags key_mods,          # = ImGuiKeyModFlags_Ctrl,
        ImGuiDragDropFlags flags,           # = 0
        ) except +
    bool BeginDragDropSourceY( # ✓
        ImPlotYAxis axis,                   # = ImPlotYAxis_1,
        ImGuiKeyModFlags key_mods,          # = ImGuiKeyModFlags_Ctrl,
        ImGuiDragDropFlags flags,           # = 0
        ) except +
    bool BeginDragDropSourceItem( # ✓
        const char* label_id,
        ImGuiDragDropFlags flags,           # = 0
        ) except +
    void EndDragDropSource() except + # ✓

    #-----------------------------------------------------------------------------
    # Plot and Item Styling
    #-----------------------------------------------------------------------------
    ImPlotStyle& GetStyle() except + # ✓
    void StyleColorsAuto( # ✓
        ImPlotStyle* dst                    # = NULL
        ) except +
    void StyleColorsClassic( # ✓
        ImPlotStyle* dst                    # = NULL
        ) except +
    void StyleColorsDark( # ✓
        ImPlotStyle* dst                    # = NULL
        ) except +
    void StyleColorsLight( # ✓
        ImPlotStyle* dst                    # = NULL
        ) except +
    void PushStyleColor(ImPlotCol idx, ImU32 col) except + # ✗
    void PushStyleColor(ImPlotCol idx, const ImVec4& col) except + # ✓
    void PopStyleColor( # ✓
        int count                           # = 1
        ) except +
    void PushStyleVar(ImPlotStyleVar idx, float val) except + # ✓
    void PushStyleVar(ImPlotStyleVar idx, int val) except + # ✓
    void PushStyleVar(ImPlotStyleVar idx, const ImVec2& val) except + # ✓
    void PopStyleVar( # ✓
        int count                           # = 1
        ) except +
    void SetNextLineStyle( # ✓
        const ImVec4& col,                  # = IMPLOT_AUTO_COL,
        float weight                        # = IMPLOT_AUTO
        ) except +
    void SetNextFillStyle( # ✓
        const ImVec4& col,                  # = IMPLOT_AUTO_COL,
        float alpha_mod                     # = IMPLOT_AUTO
        ) except +
    void SetNextMarkerStyle( # ✓
        ImPlotMarker marker,                # = IMPLOT_AUTO,
        float size,                         # = IMPLOT_AUTO,
        const ImVec4& fill,                 # = IMPLOT_AUTO_COL,
        float weight,                       # = IMPLOT_AUTO,
        const ImVec4& outline               # = IMPLOT_AUTO_COL
        ) except +
    void SetNextErrorBarStyle( # ✓
        const ImVec4& col,                  # = IMPLOT_AUTO_COL,
        float size,                         # = IMPLOT_AUTO,
        float weight                        # = IMPLOT_AUTO
        ) except +
    ImVec4 GetLastItemColor() except + # ✓
    const char* GetStyleColorName(ImPlotCol idx) except + # ✓
    const char* GetMarkerName(ImPlotMarker idx) except + # ✓

    #-----------------------------------------------------------------------------
    # Colormaps
    #-----------------------------------------------------------------------------
    ImPlotColormap AddColormap( # ✓
        const char* name,
        const ImVec4* cols,
        int size,
        bool qual                           # =true
        ) except +
    ImPlotColormap AddColormap( # ✗
        const char* name,
        const ImU32* cols,
        int size,
        bool qual                           # =true
        ) except +
    int GetColormapCount() except + # ✓
    const char* GetColormapName(ImPlotColormap cmap) except + # ✓
    ImPlotColormap GetColormapIndex(const char* name) except + # ✓
    void PushColormap(ImPlotColormap cmap) except + # ✓
    void PushColormap(const char* name) except + # ✓
    void PopColormap( # ✓
        int count                           # = 1
        ) except +
    ImVec4 NextColormapColor() except + # ✓
    int GetColormapSize( # ✓
        ImPlotColormap cmap                 #  = IMPLOT_AUTO
        ) except +
    ImVec4 GetColormapColor( # ✓
        int idx,
        ImPlotColormap cmap                 # = IMPLOT_AUTO
        ) except +
    ImVec4 SampleColormap( # ✓
        float t,
        ImPlotColormap cmap                 # = IMPLOT_AUTO
        ) except +
    void ColormapScale( # ✓
        const char* label,
        double scale_min,
        double scale_max,
        const ImVec2& size,                 # = ImVec2(0,0),
        ImPlotColormap cmap                 # = IMPLOT_AUTO
        ) except +
    bool ColormapSlider( # ✓
        const char* label,
        float* t,
        ImVec4* out,                        # = NULL,
        const char* format,                 # = "",
        ImPlotColormap cmap                 # = IMPLOT_AUTO
        ) except +
    bool ColormapButton( # ✓
        const char* label,
        const ImVec2& size,                 # = ImVec2(0,0),
        ImPlotColormap cmap                 # = IMPLOT_AUTO
        ) except +
    void BustColorCache( # ✓
        const char* plot_title_id           # = NULL
        ) except +

    #-----------------------------------------------------------------------------
    # Miscellaneous
    #-----------------------------------------------------------------------------
    void ItemIcon(const ImVec4& col) except + # ✓
    void ItemIcon(ImU32 col) except + # ✓
    void ColormapIcon(ImPlotColormap cmap) except + # ✓
    ImDrawList* GetPlotDrawList() except +
    void PushPlotClipRect() except + # ✓
    void PopPlotClipRect() except + # ✓
    bool ShowStyleSelector(const char* label) except + # ✓
    bool ShowColormapSelector(const char* label) except + # ✓
    void ShowStyleEditor(ImPlotStyle* ref) except + # ✓
    void ShowStyleEditor() except + # ✓
    void ShowUserGuide() except + # ✓
    void ShowMetricsWindow(bool* p_popen) except + # ✓
    void ShowMetricsWindow() except + # ✓

    #-----------------------------------------------------------------------------
    # Demo (add implot_demo.cpp to your sources!)
    #-----------------------------------------------------------------------------
    void ShowDemoWindow(bool* p_open) except + # ✓
    void ShowDemoWindow() except + # ✓