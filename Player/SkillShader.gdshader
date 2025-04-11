shader_type canvas_item;
uniform float percent: hint_range(0.0, 1.0, 0.05) = 0.0;

void fragment() {
    if (UV.x < percent) {
        COLOR.r = 0.0;
    } else {
        COLOR.r = 1.0;
    }
}
