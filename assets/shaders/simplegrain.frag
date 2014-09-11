
uniform sampler2D uImage0;
varying vec2 vTexCoord;
 
uniform float uTime;
uniform float strength;
 
void main() {
    // Random, adding values to get rid of edge errors    and mods that return 0
    float x = (vTexCoord.x + 4.0) * (vTexCoord.y + 4.0) * (uTime * 10.0);
    vec4 grain = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01) - 0.005) * strength;
     
    gl_FragColor = texture2D(uImage0, vTexCoord) + grain;
}
