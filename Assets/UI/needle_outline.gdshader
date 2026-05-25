shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_size : hint_range(0.0, 10.0) = 3.0;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * outline_size;
	float outline = texture(TEXTURE, UV + vec2(-size.x, 0.0)).a
				  + texture(TEXTURE, UV + vec2( size.x, 0.0)).a
				  + texture(TEXTURE, UV + vec2(0.0, -size.y)).a
				  + texture(TEXTURE, UV + vec2(0.0,  size.y)).a;
	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(vec4(outline_color.rgb, clamp(outline, 0.0, 1.0)), color, color.a);
}
