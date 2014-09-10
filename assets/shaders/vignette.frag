#ifdef GL_ES
    precision mediump float;
#endif

varying vec2 vTexCoord;
uniform vec2 uResolution;
uniform sampler2D uImage0;
uniform float amount;

void main() {
    //sample our texture
    vec4 texColor = texture2D(uImage0, vTexCoord);

    //determine origin
    vec2 p = (gl_FragCoord.xy / uResolution.xy) - vec2(0.5);

    //determine the vector length of the center position
    float len = length(p) * amount;

    gl_FragColor = vec4(texColor.rgb * (1.0 - len), 1.0);
}



// //RADIUS of our vignette, where 0.5 results in a circle fitting the screen
// const float RADIUS = 0.75;

// //softness of our vignette, between 0.0 and 1.0
// const float SOFTNESS = 0.45;

// const float STRENGHT = 0.5;

// //sepia colour, adjust to taste
// const vec3 SEPIA = vec3(1.2, 1.0, 0.8); 

// void main() {
//     //sample our texture
//     vec4 texColor = texture2D(uImage0, vTexCoord);

//     //1. VIGNETTE

//     //determine center position
//     vec2 position = (gl_FragCoord.xy / uResolution.xy) - vec2(0.5);

//     //determine the vector length of the center position
//     float len = length(position);

//     //use smoothstep to create a smooth vignette
//     float vignette = smoothstep(RADIUS, RADIUS - SOFTNESS, len);

//     //apply the vignette with 50% opacity
//     texColor.rgb = mix(texColor.rgb, texColor.rgb * vignette, STRENGHT);

//     // //2. GRAYSCALE

//     // //convert to grayscale using NTSC conversion weights
//     // float gray = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));

//     // //3. SEPIA

//     // //create our sepia tone from some constant value
//     // vec3 sepiaColor = vec3(gray) * SEPIA;

//     // //again we'll use mix so that the sepia effect is at 75%
//     // texColor.rgb = mix(texColor.rgb, sepiaColor, 0.75);

//     //final colour, multiplied by vertex colour
//     gl_FragColor = texColor;
// }
