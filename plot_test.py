# -*- coding: utf-8 -*-
import glfw
import OpenGL.GL as gl

import imgui
from imgui import plot as implot
from imgui.integrations.glfw import GlfwRenderer

import numpy as np
import array

def toarr(a: np.ndarray):
    return array.array(a.dtype.char, a)

N = 50_000
x = np.linspace(0, 4*np.pi, N)
y = 2*np.cos(x)

x = toarr(x)
y = toarr(y)

def draw():
    implot.begin_plot("My Plot")
    implot.plot_line2('legend', x, y, N)
    implot.end_plot()

def main():
    """
    # Context trickery (https://stackoverflow.com/a/19374253):
    
    - imgui_internal.h references 'extern IMGUI_API ImGuiContext* GImGui'
    - imgui.cpp contains definition 'ImGuiContext* GImGui = NULL;'

    # Windows:
    - if implot.cpp tries to include imgui_internal.h, then it needs to provide a second
      definition of GImGUI, since imgui.dll doesn't export it, and the linker can't find it
    - if a separate definition is added, then no syncing can happen between the dlls.
        -> must provide a function for setting the context handle manually.

    # Linux / MacOS:
    - imgui.so exports/exposes the global variable GImGUI.
    - linker can add imgui.so:GImGUI as load-time dependency to implot.so
        -> context is synced.
    
    """

    c1 = imgui.create_context()
    _ = implot.create_context()
    implot.set_imgui_context(c1)

    # Turn global AA on
    implot.get_style().anti_aliased_lines = True
    
    window = impl_glfw_init()
    impl = GlfwRenderer(window)
    
    while not glfw.window_should_close(window):
        glfw.poll_events()
        impl.process_inputs()

        imgui.new_frame()

        if imgui.begin_main_menu_bar():
            if imgui.begin_menu("File", True):

                clicked_quit, selected_quit = imgui.menu_item(
                    "Quit", 'Cmd+Q', False, True
                )

                if clicked_quit:
                    exit(1)

                imgui.end_menu()
            imgui.end_main_menu_bar()

        # Render
        #draw()
        imgui.show_demo_window()
        implot.show_demo_window()

        gl.glClearColor(0.1, 0.1, 0.1, 0.0)
        gl.glClear(gl.GL_COLOR_BUFFER_BIT)

        imgui.render()
        impl.render(imgui.get_draw_data())
        glfw.swap_buffers(window)

        imgui.end_frame()

    impl.shutdown()
    glfw.terminate()


def impl_glfw_init():
    width, height = 1280, 720
    window_name = "minimal ImGui/GLFW3 example"

    if not glfw.init():
        print("Could not initialize OpenGL context")
        exit(1)

    # OS X supports only forward-compatible core profiles from 3.2
    glfw.window_hint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.window_hint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.window_hint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    glfw.window_hint(glfw.OPENGL_FORWARD_COMPAT, gl.GL_TRUE)

    # Create a windowed mode window and its OpenGL context
    window = glfw.create_window(
        int(width), int(height), window_name, None, None
    )
    glfw.make_context_current(window)

    if not window:
        glfw.terminate()
        print("Could not initialize Window")
        exit(1)

    return window


if __name__ == "__main__":
    main()