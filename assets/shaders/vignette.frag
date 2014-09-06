#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform sampler2D uImage0;
uniform float amount = 0.2;

void main() {
    //sample our texture
    vec4 texColor = texture2D(uImage0, vTexCoord);

    //determine origin
    vec2 p = (gl_FragCoord.xy / uResolution.xy) - vec2(0.5);

    //determine the vector length of the center position
    float len = length(p) * amount;

    //show our length for debugging
    //gl_FragColor = vec4( vec3(len), 1.0 );
  
    gl_FragColor = vec4(texColor.rgb * (1.0 - len), 1.0);
}
