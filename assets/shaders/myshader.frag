uniform sampler2D fbo_texture;
uniform float offset;
varying vec2 vTexCoord;
uniform float uTime;
 
void main(void) {
    vec2 texcoord = vTexCoord;
    texcoord.x += sin(texcoord.y * uTime * 4.0 * 2.0 * 3.14159 + offset) / 100.0;
    gl_FragColor = texture2D(fbo_texture, texcoord);
}
