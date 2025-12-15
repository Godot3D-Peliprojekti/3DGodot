shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float value;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	float avg = (COLOR.r + COLOR.g + COLOR.b) / 10.0;
    COLOR.rgb = COLOR.rgb * (1.0 - value) + vec3(avg) * value;
}
