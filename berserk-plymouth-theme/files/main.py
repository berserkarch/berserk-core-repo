from manim import *


class CursedInvocation(Scene):
    def construct(self):
        # Load the SVG logo
        logo = SVGMobject("dr-logo-dracula.svg")
        logo.set_fill(WHITE, opacity=1).set_stroke(WHITE, width=1.5)
        logo.scale(2)
        logo.set_opacity(0)

        self.add(logo)

        # Fade in
        self.play(FadeIn(logo), run_time=0.8)
        self.wait(0.3)

        # Pulse (like it's breathing)
        self.play(logo.animate.scale(1.05).set_fill(GREY_B), run_time=0.2)
        self.play(logo.animate.scale(1 / 1.05).set_fill(WHITE), run_time=0.2)

        # Light twitch (horizontal jitter)
        for _ in range(5):
            self.play(logo.animate.shift(RIGHT * 0.03), run_time=0.03)
            self.play(logo.animate.shift(LEFT * 0.03), run_time=0.03)

        # Color glitch flash (simulate visual tear)
        glitch_overlay = logo.copy().set_fill(RED).set_opacity(0.3)
        glitch_overlay.shift(RIGHT * 0.05)
        self.add(glitch_overlay)
        self.wait(0.1)
        self.remove(glitch_overlay)

        glitch_overlay = logo.copy().set_fill(BLUE).set_opacity(0.3)
        glitch_overlay.shift(LEFT * 0.05)
        self.add(glitch_overlay)
        self.wait(0.1)
        self.remove(glitch_overlay)

        # Flicker in opacity
        for _ in range(4):
            self.play(logo.animate.set_opacity(0.2), run_time=0.05)
            self.play(logo.animate.set_opacity(1), run_time=0.05)

        # Shadow clone glitch
        ghost = logo.copy().set_opacity(0.2).shift(UP * 0.1 + LEFT * 0.1)
        self.add(ghost)
        self.wait(0.1)
        self.remove(ghost)

        # Disintegration (parts flying away)
        pieces = VGroup(*[logo.copy() for _ in range(5)])
        for p in pieces:
            p.set_opacity(0.3)
            p.shift(
                RIGHT * (0.05 * (1 - 2 * np.random.rand()))
                + UP * (0.05 * (1 - 2 * np.random.rand()))
            )
            self.add(p)

        self.play(
            *[
                p.animate.shift(
                    RIGHT * (1.5 * (1 - 2 * np.random.rand()))
                    + UP * (1.5 * (1 - 2 * np.random.rand()))
                ).set_opacity(0)
                for p in pieces
            ],
            run_time=0.6
        )

        # Remove original
        self.play(FadeOut(logo), run_time=0.4)
