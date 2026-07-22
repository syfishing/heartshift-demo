shader_type canvas_item;

// Godot 4 glitch shader.
//
// MODULATE:
// The incoming COLOR built-in is the vertex color, which Godot has already
// filled with this node's self_modulate combined with the inherited modulate
// chain from its parents. It is captured on the first line and reapplied at the
// end. (Exception: if the node lives under a CanvasGroup, the group's modulate
// is composited after this shader runs and will not appear in COLOR.)
//
// TEXTURE WRAPPING:
// Godot 4 disables texture repeat on CanvasItems by default, so UV offsets that
// leave the 0-1 range smear the edge pixels. Either:
//   - set the node's Texture > Repeat to "Enabled" in the inspector, or
//   - leave "clip_outside" on below to make out-of-bounds areas transparent.
//
// ATLASES / REGIONS:
// The clamping below assumes UV spans 0-1. If you use an AtlasTexture or a
// Sprite2D with Region enabled, UV maps into a sub-rect and the clamp will be
// wrong. Turn clip_outside off in that case, or pass the region rect in.

/* ================= SETTINGS ================= */
uniform bool enabled = true;
// Probability of glitch effect happening
uniform float glitch_chance : hint_range(0.0, 1.0) = 0.2;
// Speed of glitch state changes (how many glitch "frames" per second)
uniform float glitch_speed : hint_range(0.1, 60.0) = 7.0;
// Number of horizontal slices
uniform float slice_density : hint_range(1.0, 120.0) = 14.0;
// Strength of horizontal displacement for slices
uniform float slice_strength : hint_range(0.0, 1.0) = 0.38;
// Global shake amount
uniform float shake_strength : hint_range(0.0, 0.5) = 0.02;
// Chromatic color separation amount
uniform float chroma_offset : hint_range(0.0, 0.2) = 0.016;
// Digital noise intensity
uniform float noise_strength : hint_range(0.0, 1.0) = 0.2;
// Intensity of color flashes
uniform float color_flash_strength : hint_range(0.0, 1.0) = 0.4;
// Intensity of scanline drop effect
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.18;
// Strength of local warping distortion
uniform float local_warp_strength : hint_range(0.0, 1.0) = 0.14;
// Chance for horizontal flip of slices
uniform float flip_chance : hint_range(0.0, 1.0) = 0.15;

/* ---- modulate / clipping ---- */
// ON  : modulate tints everything, including flashes and noise grain.
//       The sprite always reads as one coherently tinted object.
// OFF : modulate tints only the source art; flashes and grain keep their
//       raw color and punch through the tint.
uniform bool modulate_affects_glitch = true;
// Discard pixels pushed outside the sprite instead of smearing the edge
uniform bool clip_outside = true;
// TIME is wrapped to this period to keep hash inputs small and precise.
// The effect repeats every N seconds, which is imperceptible for noise.
uniform float time_wrap : hint_range(1.0, 600.0) = 120.0;

/* ================= HASH FUNCTIONS ================= */
// Sine-free hashes (Dave Hoskins style). These stay well-behaved for large
// inputs, unlike fract(sin(x * 143758.5) * 43758.5), which loses all precision
// once TIME grows and produces visible banding.

float hash11(float p) {
	p = fract(p * 0.1031);
	p *= p + 33.33;
	p *= p + p;
	return fract(p);
}

float hash12(vec2 p) {
	vec3 p3 = fract(p.xyx * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p) {
	vec3 p3 = fract(p.xyx * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.xx + p3.yz) * p3.zy);
}

/* ================= FRAGMENT SHADER ================= */
void fragment() {
	// Capture modulate / self_modulate / vertex color before COLOR is written.
	vec4 modulate = COLOR;

	// Split the tint into a pre-pass and a post-pass factor. Exactly one of
	// them carries the color at any time, so modulate is never applied twice.
	vec3 pre_tint  = modulate_affects_glitch ? vec3(1.0) : modulate.rgb;
	vec3 post_tint = modulate_affects_glitch ? modulate.rgb : vec3(1.0);

	vec2 uv = UV;
	float t = mod(TIME, time_wrap);

	// Quantized glitch "frame". Every random value below is keyed to this so
	// effects hold for the duration of a step instead of buzzing per-frame.
	float step_id = floor(t * glitch_speed);
	float slow_id = floor(t);

	float glitch = enabled ? step(1.0 - glitch_chance, hash11(step_id)) : 0.0;

	/* ----- SLICES EFFECT ----- */
	float slice_id = floor(uv.y * slice_density + hash11(slow_id) * 10.0);
	float slice_rand = hash12(vec2(slice_id, step_id));
	float slice_mask = step(0.5, slice_rand) * glitch;

	// Flip is gated by the glitch mask and quantized to the glitch step.
	// Branchless so it doesn't cost divergence on wide sprites.
	float flip = step(hash12(vec2(slice_id + 91.7, step_id)), flip_chance) * slice_mask;
	uv.x = mix(uv.x, 1.0 - uv.x, flip);

	// Horizontal displacement for this slice
	uv.x += (slice_rand - 0.5) * slice_strength * slice_mask;

	/* ----- MICRO JITTER ----- */
	float jitter = step(0.85, hash11(step_id * 1.7 + 5.0)) * glitch;
	uv.x += (hash11(step_id * 3.1 + 13.0) - 0.5) * 0.08 * jitter;

	/* ----- LOCAL WARP ----- */
	float warp_zone = step(0.65, hash12(vec2(slice_id, step_id + 17.0)));
	uv += (hash22(uv * 64.0 + step_id) - 0.5) * local_warp_strength * warp_zone * glitch;

	/* ----- GLOBAL SHAKE ----- */
	uv += (vec2(hash11(step_id * 1.3 + 41.0), hash11(step_id * 1.7 + 77.0)) - 0.5)
		* shake_strength * glitch;

	/* ----- SAMPLING ----- */
	// Track whether we left the sprite before clamping, so we can cut the alpha
	// rather than smear the border pixel across the displaced region.
	vec2 in_range = step(vec2(0.0), uv) * step(uv, vec2(1.0));
	float inside = in_range.x * in_range.y;
	vec2 suv = clamp(uv, 0.0, 1.0);

	vec4 base = texture(TEXTURE, suv);
	float r = texture(TEXTURE, clamp(suv + vec2(chroma_offset * glitch, 0.0), 0.0, 1.0)).r;
	float b = texture(TEXTURE, clamp(suv - vec2(chroma_offset * glitch, 0.0), 0.0, 1.0)).b;

	// pre_tint is white unless modulate is set to spare the glitch artifacts.
	vec3 color = vec3(r, base.g, b) * pre_tint;

	/* ----- DIGITAL NOISE ----- */
	// Keyed to UV and the glitch step, so grain resolution stays constant
	// instead of blowing up as TIME grows.
	color += (hash12(UV * 512.0 + vec2(step_id, step_id * 1.7)) - 0.5)
		* noise_strength * glitch;

	/* ----- SCANLINE DROP ----- */
	float scan = step(0.9, hash12(vec2(floor(uv.y * 100.0), step_id)));
	color *= 1.0 - scan * scanline_strength * glitch;

	/* ----- COLOR FLASH ----- */
	vec3 flash_color = step(vec3(0.5), vec3(
		hash11(step_id + 0.1),
		hash11(step_id + 31.7),
		hash11(step_id + 61.3)
	));
	color = mix(color, flash_color, hash11(step_id * 4.0 + 7.0) * color_flash_strength * glitch);

	// post_tint is white unless modulate should cover the glitch artifacts too.
	// modulate.a is always applied here, so fading the node out still works
	// regardless of which tint mode is selected.
	float alpha = base.a * modulate.a * (clip_outside ? inside : 1.0);
	COLOR = vec4(color * post_tint, alpha);
}
