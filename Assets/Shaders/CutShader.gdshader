shader_type canvas_item;

uniform sampler2D mask_texture;
uniform vec2 mask_scale = vec2(1.0, 1.0);
uniform vec2 mask_offset = vec2(0.0, 0.0);

void fragment() {
    vec4 color = texture(TEXTURE, UV) * COLOR;

    vec2 mask_uv = (UV - 0.5) / mask_scale + 0.5 + mask_offset;
    float mask = texture(mask_texture, mask_uv).a;
	
    vec2 inside = step(vec2(0.0), mask_uv) * step(mask_uv, vec2(1.0));
    mask *= inside.x * inside.y;

    color.a *= mask;
    COLOR = color;
}