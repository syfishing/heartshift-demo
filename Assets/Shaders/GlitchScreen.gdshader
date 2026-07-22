shader_type canvas_item;

// Godot 4 screen-space glitch shader.
// Glitches everything drawn BEHIND this node, rather than the node's own texture.
//
// SETUP:
//  1. Attach to a ColorRect (easiest), Sprite2D, or Polygon2D.
//  2. Put it in a CanvasLayer above the content you want distorted, or give it a
//     higher z_index. The back buffer only contains what was drawn BEFORE this
//     node, so anything drawn after it is untouched.
//  3. For a single effect you do NOT need a BackBufferCopy node -- Godot copies
//     the screen automatically the first time hint_screen_texture is hit.
//     You only need one if a SECOND screen-reading shader overlaps this one and
//     must see this one's output. In that case use copy_mode = Viewport;
//     Rect mode has had update bugs across several 4.x releases.
//
// SCALE NOTE:
// Offsets are in screen-UV units, so 0.1 means 10% of viewport WIDTH horizontally
// and 10% of HEIGHT vertically -- not equal distances on a non-square viewport.
// Defaults are lowered from the sprite version accordingly. For pixel-exact
// offsets instead, multiply by SCREEN_PIXEL_SIZE (which is 1.0 / viewport size).

/* ================= SETTINGS ================= */
uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear;

uniform bool enabled = true;
// Probability of glitch effect happening
uniform float glitch_chance : hint_range(0.0, 1.0) = 0.2;
// Speed of glitch state changes (how many glitch "frames" per second)
uniform float glitch_speed : hint_range(0.1, 60.0) = 7.0;
// Number of horizontal slices, measured across the NODE's height
uniform float slice_density : hint_range(1.0, 120.0) = 14.0;
// Strength of horizontal displacement for slices
uniform float slice_strength : hint_range(0.0, 1.0) = 0.12;
// Global shake amount
uniform float shake_strength : hint_range(0.0, 0.5) = 0.008;
// Chromatic color separation amount
uniform float chroma_offset : hint_range(0.0, 0.2) = 0.006;
// Digital noise intensity
uniform float noise_strength : hint_range(0.0, 1.0) = 0.2;
// Intensity of color flashes
uniform float color_flash_strength : hint_range(0.0, 1.0) = 0.4;
// Intensity of scanline drop effect
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.18;
// Strength of local warping distortion
uniform float local_warp_strength : hint_range(0.0, 1.0) = 0.04;
// Chance for horizontal flip of slices. In screen space this mirrors a band of
// the background around the node's centre line, which is a strong effect --
// keep it low or set it to 0.
uniform float flip_chance : hint_range(0.0, 1.0) = 0.08;

/* ---- masking / modulate ---- */
// Use the node's own texture alpha as a mask, so the glitch only shows inside
// the sprite's shape. Leave off for a plain rectangular ColorRect.
uniform bool use_texture_as_mask = false;
// Fade the effect out toward the node's edges instead of a hard rectangular cut.
uniform float edge_feather : hint_range(0.0, 0.5) = 0.0;
// ON  : modulate tints everything, including flashes and noise grain.
// OFF : modulate tints only the background; flashes and grain keep raw color.
uniform bool modulate_affects_glitch = true;
// TIME is wrapped to this period to keep hash inputs small and precise.
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
	vec3 pre_tint  = modulate_affects_glitch ? vec3(1.0) : modulate.rgb;
	vec3 post_tint = modulate_affects_glitch ? modulate.rgb : vec3(1.0);

	// Two coordinate spaces here, and the split matters:
	//   UV        - local to the node. Drives the slice PATTERN, so the bands
	//               stay locked to the object and keep a consistent count no
	//               matter the viewport resolution or where the node sits.
	//   SCREEN_UV - where we actually SAMPLE the background from.
	vec2 suv = SCREEN_UV;
	float t = mod(TIME, time_wrap);

	// Quantized glitch "frame". Every random value below is keyed to this so
	// effects hold for the duration of a step instead of buzzing per-frame.
	// SEED matters: these hashes all return exactly 0.0 for an input of 0.0, so
	// without an offset the first glitch step can never pass the gate -- and if
	// TIME is pinned near zero (a non-redrawing editor viewport, say) the shader
	// sits on that dead step forever and renders a pure pass-through.
	const float SEED = 137.13;
	float step_id = floor(t * glitch_speed) + SEED;
	float slow_id = floor(t) + SEED;

	float glitch = enabled ? step(1.0 - glitch_chance, hash11(step_id)) : 0.0;

	/* ----- SLICES EFFECT ----- */
	float slice_id = floor(UV.y * slice_density + hash11(slow_id) * 10.0);
	float slice_rand = hash12(vec2(slice_id, step_id));
	float slice_mask = step(0.5, slice_rand) * glitch;

	// Flip mirrors the sampled band around the NODE's horizontal centre, not the
	// screen's. The mirrored local position is (1.0 - UV.x), so the local shift
	// is (1.0 - 2.0 * UV.x); dFdx gives screen-UV per local-UV to convert that
	// into a screen offset. Assumes the node is unrotated -- if you rotate it,
	// pass the rect in from GDScript and use that instead.
	float flip = step(hash12(vec2(slice_id + 91.7, step_id)), flip_chance) * slice_mask;
	float u_to_screen = dFdx(SCREEN_UV.x) / max(abs(dFdx(UV.x)), 1e-6);
	suv.x += (1.0 - 2.0 * UV.x) * u_to_screen * flip;

	// Horizontal displacement for this slice
	suv.x += (slice_rand - 0.5) * slice_strength * slice_mask;

	/* ----- MICRO JITTER ----- */
	float jitter = step(0.85, hash11(step_id * 1.7 + 5.0)) * glitch;
	suv.x += (hash11(step_id * 3.1 + 13.0) - 0.5) * 0.08 * jitter;

	/* ----- LOCAL WARP ----- */
	float warp_zone = step(0.65, hash12(vec2(slice_id, step_id + 17.0)));
	suv += (hash22(UV * 64.0 + step_id) - 0.5) * local_warp_strength * warp_zone * glitch;

	/* ----- GLOBAL SHAKE ----- */
	suv += (vec2(hash11(step_id * 1.3 + 41.0), hash11(step_id * 1.7 + 77.0)) - 0.5)
		* shake_strength * glitch;

	/* ----- SAMPLING ----- */
	// Clamp rather than clip: sampling past the screen edge should smear the
	// border pixel, not punch a transparent hole in the middle of the effect.
	suv = clamp(suv, vec2(0.0), vec2(1.0));

	vec3 base = texture(screen_tex, suv).rgb;
	float r = texture(screen_tex, clamp(suv + vec2(chroma_offset * glitch, 0.0), 0.0, 1.0)).r;
	float b = texture(screen_tex, clamp(suv - vec2(chroma_offset * glitch, 0.0), 0.0, 1.0)).b;

	vec3 color = vec3(r, base.g, b) * pre_tint;

	/* ----- DIGITAL NOISE ----- */
	color += (hash12(UV * 512.0 + vec2(step_id, step_id * 1.7)) - 0.5)
		* noise_strength * glitch;

	/* ----- SCANLINE DROP ----- */
	float scan = step(0.9, hash12(vec2(floor(UV.y * 100.0), step_id)));
	color *= 1.0 - scan * scanline_strength * glitch;

	/* ----- COLOR FLASH ----- */
	vec3 flash_color = step(vec3(0.5), vec3(
		hash11(step_id + 0.1),
		hash11(step_id + 31.7),
		hash11(step_id + 61.3)
	));
	color = mix(color, flash_color, hash11(step_id * 4.0 + 7.0) * color_flash_strength * glitch);

	/* ----- MASK ----- */
	float mask = 1.0;
	if (use_texture_as_mask) {
		mask *= texture(TEXTURE, UV).a;
	}
	if (edge_feather > 0.0) {
		vec2 e = smoothstep(vec2(0.0), vec2(edge_feather), UV)
			* smoothstep(vec2(0.0), vec2(edge_feather), 1.0 - UV);
		mask *= e.x * e.y;
	}

	// Blend back toward the untouched background by the mask, so feathered
	// edges dissolve into the scene instead of fading to transparent and
	// revealing a hard rectangle of un-glitched screen underneath.
	vec3 clean = texture(screen_tex, SCREEN_UV).rgb;
	color = mix(clean, color, mask);

	COLOR = vec4(color * post_tint, modulate.a);
}
