shader_type canvas_item;

render_mode blend_mix;

uniform vec4 flash_color : hint_color;
uniform float flash_amount : hint_range(0.0, 1.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.a = mix(color.a, flash_color.a, flash_amount);
	COLOR = color;
}