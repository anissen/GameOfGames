
uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uImage0;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

const float bloom = 0.35;  // TODO make uniform input (bloom = good / points)
const float shiftOffset = 0.003; // TODO make uniform input (shift = bad / damage)
const float bloomDisp = 0.005; // Bloom image displacement
const float bloomColorSat = 2.0; // Bloom color satuation
const float vignetteAmount = 20.0;
const float scanlinesScrollSpeed = 8.0;
const float scanlinesScale = 900.0;
const float glitchChance = 0.01; // 

void main(void)
{
    vec2 q = gl_FragCoord.xy / uResolution.xy;
    vec2 uv = 0.5 + (q - 0.5);
    // vec2 uv = 0.5 + (q - 0.5) * (0.9 + 0.1 * sin(0.2 * uTime));
    vec3 col;
    vec4 sum = vec4(0);
    vec4 curcol = texture2D(uImage0, q);
    float shift = shiftOffset;

    // neighbourhood interpolation for bloom
    sum += texture2D(uImage0, vec2(-bloomDisp, -bloomDisp) + q) * bloomColorSat;
    sum += texture2D(uImage0, vec2( bloomDisp, -bloomDisp) + q) * bloomColorSat;
    sum += texture2D(uImage0, vec2(-bloomDisp,  bloomDisp) + q) * bloomColorSat;
    sum += texture2D(uImage0, vec2( bloomDisp,  bloomDisp) + q) * bloomColorSat;
    // for(int i = -4; i < 4; i += 2) {
    //     for (int j = -4; j < 4; j += 2) {
    //         sum += texture2D(uImage0, vec2(j,i) * 0.004 + q) * 0.25;
    //     }
    // }
          
    // electron beam shift (plus random distortion)
    if (rand(vec2(1.0 - uTime, sin(uTime))) < glitchChance) { 
        shift = 0.1 * rand(vec2(uTime, uTime));
        col.r = texture2D(uImage0, vec2(uv.x + shift, uv.y)).x;
        col.g = texture2D(uImage0, vec2(uv.x, uv.y)).y;
        col.b = texture2D(uImage0, vec2(uv.x - shift, uv.y)).z;
    } else {
        col = curcol.rgb;
    }

    // col = clamp(col*0.5+0.5*col*col*1.2,0.0,1.0);          // tone curve
    col *= 0.3 + 0.7 * vignetteAmount * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y); // vignette
    // col *= vec3(0.7,1.0,0.6);                              // green tint
    col *= 0.9 + 0.1 * sin(scanlinesScrollSpeed * uTime + uv.y * scanlinesScale);        // scanlines
    col *= 1.0 - 0.05 * rand(vec2(uTime, tan(uTime)));          // random flicker

    // bloom
    gl_FragColor = bloom * (sum * sum) * (1.0 - curcol.r) / 40.0 + vec4(col, 1.0);
}
