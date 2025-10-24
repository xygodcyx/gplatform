shader_type canvas_item;

// 回放“电视故障风”Shader —— 兼容Godot 4.5，屏幕适配版
// 作者：FORCE BRUTE 优化版（高性能 + 正确尺寸）

uniform float intensity : hint_range(0.0, 1.0) = 0.6;
uniform float time_scale = 1.0;
uniform float scanline_density = 240.0;
uniform float chroma_shift = 0.002;

// 关键：SCREEN_TEXTURE 采样时要配合 SCREEN_UV
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// 简易伪随机函数
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // 使用 SCREEN_UV 保证全屏一致
    vec2 uv = SCREEN_UV;
    float t = TIME * time_scale;

    // --- 扫描线 ---
    float scan = sin(uv.y * scanline_density + t * 10.0);
    scan = mix(1.0, 0.85, scan * 0.5 + 0.5);

    // --- 水平抖动 ---
    float glitch = step(0.95, hash(vec2(floor(t * 5.0), uv.y))) * 0.03;
    uv.x += glitch * intensity;

    // --- 色偏（RGB通道偏移）---
    vec2 shift = vec2(chroma_shift * intensity, 0.0);
    vec4 col;
    col.r = texture(SCREEN_TEXTURE, uv + shift).r;
    col.g = texture(SCREEN_TEXTURE, uv).g;
    col.b = texture(SCREEN_TEXTURE, uv - shift).b;
    col.a = 1.0;

    // --- 混合扫描线 ---
    col.rgb *= scan;

    // --- 轻微噪点 ---
    float noise = hash(uv * vec2(800.0, 600.0) + t) * 0.15;
    col.rgb += noise * intensity * 0.3;

    COLOR = col;
}
