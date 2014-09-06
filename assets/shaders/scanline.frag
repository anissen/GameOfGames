#version 120

#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform sampler2D uImage0;

uniform float interval = 2.0;
uniform float scale = 1.0;
uniform float alpha = 0.0;

void main()
{
    vec4 tex = texture2D(uImage0, vTexCoord);
    if (mod(floor(vTexCoord.y * uResolution.y / scale), interval) == 0.0)
        gl_FragColor = vec4(tex.rgb * alpha, 1.0); //vec4(tex.rgb / tex.a, alpha);
    else
        gl_FragColor = tex;
}
