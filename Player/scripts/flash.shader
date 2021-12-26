shader_type canvas_item;

render_mode blend_mix;

uniform vec4 flash_color : hint_color;
uniform float flash_amount : hint_range(0.0, 1.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, flash_color.rgb, flash_amount);
	COLOR = color;
}