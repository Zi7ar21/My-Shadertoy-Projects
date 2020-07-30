// ^^^ Check Buffer A ^^^
// See https://www.shadertoy.com/view/ttBcWR for full license details

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    // sample texture and output to screen
    fragColor = texture(iChannel0, uv)/float(iFrame);
}