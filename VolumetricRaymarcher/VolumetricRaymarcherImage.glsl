// ^^^ Everthing is up here in Buffer A ^^^
// It is seperate so you can press the button on the bottom of the editor to export a 32-Bit Float OpenEXR!

// Zi7ar21's Volumetric Raymarcher --- September 1st, 2020 --- Updated December 12th, 2020
// I Deem You Allowed to Use My Code Commercially and Even Modify it as Long as:
// You keep this disclaimer.
// You do not modify the terms

// You do not have to keep my credits, however I urge you to leave them here in the source.

// If this Code is Being Reused Entirely,
// Then the Original and Possibly Updated Version Can be Found Here:
// https://www.shadertoy.com/view/wt2fDD
// Fork of "My Nebula" by Zi7ar21. https://shadertoy.com/view/ttfBDN [August 2nd 2020 00:53:15]

// Learn the Basics of Raymarching Like I Did Here:
// https://youtu.be/PGtv-dBi2wE

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    // Output to screen
    fragColor = texture(iChannel0, uv);
}