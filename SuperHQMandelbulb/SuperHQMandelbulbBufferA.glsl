// Zi7ar21's Mandelbulb Ray Marcher -- July 6th, 2020
// Super HQ Version July 29th, 2020
// The Original:
// https://www.shadertoy.com/view/ttBcWR

// I Deem You Allowed to Use My Code even Commercially and Even Modify it as Long as:
// You keep this disclaimer.
// You keep the links to source I used (I don't want to get in trouble)
// You keep the link to this on ShaderToy
// You do not modify the terms

// You do not have to keep my credits, however I urge you to leave them here in the source.
// If you are absolutely not able to follow these terms, that is OK and I allow you I guess.

// If this Code is Being Reused Entirely,
// Then the Original and Possibly Updated Version Can be Found Here:
// https://www.shadertoy.com/view/ttBcWR
// Or the exact copy can be found here:
// https://www.shadertoy.com/view/3tXfz4
// Fork of "My Very First Working Raymarcher" by Zi7ar21. [2020-07-06 23:50:09]
// https://shadertoy.com/view/WlBcDz

// Learn the Basics of Raymarching Like I Did Here:
// https://youtu.be/PGtv-dBi2wE

// Change these Parameters to Your Liking! (Warning: These are already nuked so
// I don't recommend bumping them up unless you have a excellent PC)
#define MAX_MARCHES 1024
#define MAX_DISTANCE 32.0
// Fake Volumetric Function
#define COLLISION_DISTANCE abs(tan(hash11(float(iFrame+1))*3.14159265)/512.0)
#define Bailout 4.0
#define Iterations 64

float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}
vec3 hash33(vec3 p3)
{
    p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy + p3.yxx)*p3.zyx);

}

// Mandelbulb Distance Estimator
float sphere(vec3 pos) {
    float Power = float(2.0);
    vec3 z = pos;
    float dr = 1.0;
    float r = 1.0;
    for (int i = 0; i < Iterations ; i++) {
        r = length(z);
        if (r>Bailout) break;
        
        // Convert to Polar Coordinates
        float theta = acos(z.z/r);
        float phi = atan(z.y,z.x);
        dr =  pow( r, Power-1.0)*Power*dr + 1.0;
        
        // Scale and Rotate the Point
        float zr = pow( r,Power);
        theta = theta*Power;
        phi = phi*Power;
        
        // Convert Back to Cartesian Coordinates
        z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
        z+=pos;
    }
    return 0.5*log(r)*r/dr;
}

// Compute/March the Ray
float raymarch(vec3 camerapos, vec3 raydir) {
    float distorigin=0.0;
    
    for(int i=0; i<MAX_MARCHES; i++) {
        vec3 raypos = camerapos + raydir*distorigin;
        float distsurface = sphere(raypos);
        distorigin += distsurface;
        if(distorigin>MAX_DISTANCE || distsurface<COLLISION_DISTANCE) break;
    }
    
    return distorigin;
}

// Get Normal
vec3 normal(vec3 raypos) {
    float dis = sphere(raypos);
    vec2 e = vec2(.01, 0);
    
    vec3 normal = dis - vec3(
        sphere(raypos-e.xyy),
        sphere(raypos-e.yxy),
        sphere(raypos-e.yyx));
    
    return normalize(normal);
}

// Shade Scene
vec3 shade(vec3 march) {
    // Light Positions
    vec3 lightpositiona = vec3(-4, 0, -2);
    vec3 lightpositionb = vec3(0, 0, -2);
    vec3 lightpositionc = vec3(4, 0, -2);
    // Compute Lighting
    vec3 lightinga = normalize(lightpositiona-march);
    vec3 lightingb = normalize(lightpositionb-march);
    vec3 lightingc = normalize(lightpositionc-march);
    // Compute Surface Normal
    vec3 surfacenormal = normal(march);
    // Compute Diffuse
    float diffuseshader = clamp(dot(surfacenormal, lightinga), 0.0, 1.0);
    float diffuseshadeg = clamp(dot(surfacenormal, lightingb), 0.0, 1.0);
    float diffuseshadeb = clamp(dot(surfacenormal, lightingc), 0.0, 1.0);
    // Compute Geometry
    float distancesurfa = raymarch(march+surfacenormal*COLLISION_DISTANCE, lightinga);
    float distancesurfb = raymarch(march+surfacenormal*COLLISION_DISTANCE, lightingb);
    float distancesurfc = raymarch(march+surfacenormal*COLLISION_DISTANCE, lightingc);
    // Shade Geometry
    if(distancesurfa<length(lightpositiona-march)) diffuseshader *= 1.0;
    if(distancesurfa<length(lightpositionb-march)) diffuseshadeg *= 1.0;
    if(distancesurfb<length(lightpositionc-march)) diffuseshadeb *= 1.0;
    // Return Shading
    return vec3(diffuseshader, diffuseshadeg, diffuseshadeb);
}

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

// Render the Image
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    // Camera Orientation
    vec3 xdir = vec3(1.0,0.0,0.0);
    vec3 ydir = vec3(0.0,1.0,0.0);
    vec3 zdir = vec3(0.0,0.0,1.0);
    float FOV = 1.0;
    vec3 camerapos = vec3(sin(float(iFrame))/(iResolution.x/(FOV)), cos(float(iFrame))/(iResolution.y/(FOV)), -4.5);

    // Undistorted Normalized Pixel Coordinates (From 0 to 1)
    vec2 uv = (fragCoord - 0.5*iResolution.xy)/iResolution.x;
    vec3 raydir = normalize(FOV*(uv.x*xdir + uv.y*ydir) + zdir);
    float collide = raymarch(camerapos, raydir);
    vec2 uvb = fragCoord/iResolution.xy;

    // Pixel Color
    vec3 col = vec3(collide / 4.0);

    // Compute and Shade
    float spheredistance = raymarch(camerapos, raydir);
    vec3 march = camerapos + raydir * spheredistance;
    vec3 diffuse = shade(march);

    // Dither
    col = diffuse*(hash33(vec3((float(iFrame)*fragCoord)+(fragCoord*2.0), iFrame*2)));

    // Output to Screen
    fragColor = vec4((col+texture(iChannel0, uvb).rgb),1.0);
}