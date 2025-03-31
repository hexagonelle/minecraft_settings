#version 330

#moj_import <utils.glsl>
#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform float FogStart;
uniform float FogEnd;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 tintColor;
out vec4 lightColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec4 normal;
out vec4 glpos;

flat out int skinEffects;
flat out int isFace;
flat out vec3 Times;

void main() {
    //skin effects
    skinEffects = 0;
    isFace = 0;
    vec4 skindata = textureLod(Sampler0, vec2(0.5, 0.0), -4);
    //face vertices
    if(((gl_VertexID >= 16 && gl_VertexID < 20) || (gl_VertexID >= 160 && gl_VertexID < 164))) {
        isFace = 1;
    }
    //enable blink
    if (abs(skindata.a - float(ALPHA_PLAYER_CTL) / 255.0) < 0.005) {
        skinEffects = 1;
        Times = skindata.rgb;
    }
    
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    glpos = gl_Position;

    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1.0));
    tintColor = Color;
    lightColor = vec4(1.0);
    if (!is_gui(ProjMat)) {
        lightColor = minecraft_sample_lightmap_of(Sampler2, UV2);
    }
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
