shader_type canvas_item;

uniform vec4 outline_color : source_color  = vec4(1,1,1,1);
uniform float outline_width = 1;

void fragment() {
	vec2 uv = UV;
	vec2 uv_top = uv + vec2(0,TEXTURE_PIXEL_SIZE.y) * outline_width;
	vec2 uv_bottom = uv + vec2(0,-TEXTURE_PIXEL_SIZE.y) * outline_width;
	vec2 uv_left = uv + vec2(TEXTURE_PIXEL_SIZE.x,0) * outline_width;
	vec2 uv_right = uv + vec2(-TEXTURE_PIXEL_SIZE.x,0) * outline_width;

	vec4 color_top = texture(TEXTURE,uv_top);
	vec4 color_bottom = texture(TEXTURE,uv_bottom);
	vec4 color_left = texture(TEXTURE,uv_left);
	vec4 color_right = texture(TEXTURE,uv_right);

	vec4 outline = color_top + color_bottom + color_left + color_right;
	outline.rgb = outline_color.rgb;
	outline.a = min(outline.a,1);
	vec4 origin_color = texture(TEXTURE,UV);
	COLOR = mix(outline,origin_color,origin_color.a);
}