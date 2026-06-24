shader_type canvas_item;

uniform float grayscale_amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    COLOR = mix(color, vec4(gray, gray, gray, color.a), grayscale_amount);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
