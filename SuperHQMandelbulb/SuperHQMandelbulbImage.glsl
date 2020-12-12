// ^^^ Check Buffer A ^^^
// See https://www.shadertoy.com/view/ttBcWR for full license details

// ACES Tone Curve
vec3 acesFilm(const vec3 x){
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return clamp((x*(a*x+b))/(x*(c*x+d)+e),0.0,1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    
    // Pixel Color
    vec3 col = texture(iChannel0, uv).rgb/float(iFrame+1);

    // sample texture and output to screen
    fragColor = vec4(acesFilm(col), 1.0);
}