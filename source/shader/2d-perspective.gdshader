shader_type canvas_item;

/* Shift this value to create the dissolving effect. Represents the percentage
   of the image that's been dissolved. */
uniform float progress : hint_range(0.0, 1.0);
uniform vec2 texture_size;
// How far the pixels will float away before dissolving
uniform float float_dist = 6.0;
// Increase how far pixels can vertically differ from the "wave"
uniform float progress_rand_range = 0.2;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 438.5453);
}

void fragment() {
	// Float dist in terms of UV
	float v = float_dist / texture_size.y;
	/* "Adjusted" progress based on how far above/below the image that the float
	   dist extends, plus a bit of randomness for which pixel floats when */
	float p = progress * (1.0 + (v + progress_rand_range) * 2.0) - v -
	   progress_rand_range + random(UV) * progress_rand_range;
	/* Value ranging from 0 to 1 depending on how far UV.y is above p */
	float q = smoothstep(p - v * 2.0, p, UV.y);
	// Map another pixel's UV to this one based on q (shift by up to v pixels)
	float mapped_uv_y = UV.y + v - v * q * step(q, 1.0);
	
	COLOR = texture(TEXTURE, vec2(UV.x, mapped_uv_y));
	// Increase transparency as particles begin to float away
	COLOR.a -= 1.0 - q;
	}