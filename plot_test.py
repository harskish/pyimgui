# -*- coding: utf-8 -*-
import glfw
import OpenGL.GL as gl

import imgui
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
    imgui.begin_plot("My Plot")
    imgui.plot_line2('legend', x, y, N)
    imgui.end_plot()

def main():
    c1 = imgui.create_context()
    _ = imgui.plot_create_context()
    imgui.plot_set_imgui_context(c1)

    # Turn global AA on
    imgui.plot_get_style().anti_aliased_lines = True
    
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
        draw()
        #imgui.show_demo_window()
        imgui.plot_show_demo_window()

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