// ##### COMMON VALUES #####

// Change these Parameters to Your Liking!

// Camera's FOV
#define FOV 1.0

// Maximum Number of Marches,
// You want it to limit the raymarcher before the max distance parameter or it will look bad.
#define MAX_MARCHES 32

// Redundant for this idk if the max marches are large and you see ugly stuff then increase this
#define MAX_DISTANCE 32.0

// fBm Number of Octaves (Detail)
#define NUM_OCTAVES 8

// Size of Steps, smaller means more sampling over depth but also means more computation.
// Increase max marches if the scene goes invisible.
#define STEP_SIZE 0.5

// If you march less rays, the nebula will appear darker. Bump this up to make it brighter again,
// Beware there will be more noise
#define DENSITY 1.0

// Uncomment to enable rotation matrix for rotating camera, currently too slow
//#define ROTATION_MATRIX

// Oof ugly mess below watch out lol

#ifdef ROTATION_MATRIX
    // Dumb rotation matrix hecking Michael0884 begged me to add lol
    float xrot = 0.0;
    float yrot = 0.0;
    float zrot = 0.0;
    // Camera Orientation
    vec3 xdir = vec3(cos(yrot)*cos(zrot),-cos(yrot)*sin(zrot),sin(yrot));

    vec3 ydir = vec3(cos(xrot)*sin(zrot)+sin(xrot)*sin(yrot)*cos(zrot),
                     cos(xrot)*cos(zrot)-sin(xrot)*sin(yrot)*sin(zrot),-sin(xrot)*cos(yrot));

    vec3 zdir = vec3(sin(xrot)*sin(zrot)-cos(xrot)*sin(yrot)*cos(zrot),
                     sin(xrot)*cos(zrot)+cos(xrot)*sin(yrot)*sin(zrot),cos(xrot)*cos(yrot));
#endif
#ifndef ROTATION_MATRIX
    // Camera Orientation
    vec3 xdir = vec3(1.0,0.0,0.0);
    vec3 ydir = vec3(0.0,1.0,0.0);
    vec3 zdir = vec3(0.0,0.0,1.0);
#endif

// ##### NOISE #####

// IQ's Regular Noise
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

// Convert Noise to 3D
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

// fBm Noise
float fbm(vec3 x){
    // Initialize Value
    float v = 0.0;
    // Amount to Contribute Next Iteration
    float a = 0.5;
    // Loop Octaves
    for (int i = 0; i < NUM_OCTAVES; ++i){
        // Add Noise based on Octave
        v += a * noise(x);
        // Scale Coordinates by 2 for Next Octave
        x = x * 2.0;
        // Set Next Octave
        a *= 0.5;
    }
    return v;
}

float nebulanoise(vec3 raypos){
    float density = clamp(fbm(raypos)-0.5, 0.0, 1.0)/pow(distance(vec3(0.0), raypos), 4.0);
    return density;
}

// ##### RAYMARCHING #####

// For Dithering
float hash13(vec3 p3){
    p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Compute/March the Ray
float raymarch(vec3 camerapos, vec3 raydir, vec2 coord){
    float distorigin=0.0;
    float density=0.0;
    vec3 raypos = camerapos;
    vec3 raydirmod = (raydir*((hash13(vec3(coord, iFrame))*STEP_SIZE)+1.0))*STEP_SIZE;
    for(int i=0; i<MAX_MARCHES; i++){
        raypos = raypos + raydirmod;
        float densityadd = nebulanoise(raypos)*DENSITY;
        density = density+densityadd;
        distorigin = raypos.z-camerapos.z;
        if(distorigin>MAX_DISTANCE) break;
    }
    return density;
}

// ##### RENDERING #####

// ACES Tone Curve
vec3 acesFilm(const vec3 x){
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return clamp((x*(a*x+b))/(x*(c*x+d)+e),0.0,1.0);
}

// Render the Image
void mainImage(out vec4 fragColor, in vec2 fragCoord){
    // Position
    vec3 camerapos = vec3(0.0, 0.0, -6.0);

    // Undistorted Normalized Pixel Coordinates (From 0 to 1)
    vec2 uv = (fragCoord - 0.5*iResolution.xy)/iResolution.x;
    
    // Ray Direction
    vec3 raydir = normalize(FOV*(uv.x*xdir+uv.y*ydir)+zdir);
    
    // Raymarch
    float raymarched = raymarch(camerapos, raydir, fragCoord);

    // Pixel Color
    vec3 col = vec3(raymarched);
    
    // Apply Tone Map
    col = vec3(acesFilm(col));

    // Output to Screen
    fragColor = vec4(col,1.0);
}