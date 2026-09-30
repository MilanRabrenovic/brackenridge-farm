shader_type canvas_item;
render_mode unshaded;
uniform sampler2D wear_tex : filter_linear;
uniform sampler2D meadow_tex : source_color, filter_linear;
uniform sampler2D grass_tex : source_color, filter_linear;
uniform sampler2D earth_tex : source_color, filter_linear;
uniform sampler2D yard_tex : source_color, filter_linear;
uniform sampler2D water_tex : source_color, filter_linear;
vec2 mirrored(vec2 uv) { return 1.0-abs(mod(uv,2.0)-1.0); }
void fragment(){
 vec2 p=UV*vec2(2040.0,1440.0)-vec2(170.0,120.0);
 vec4 masks=texture(TEXTURE,clamp(p/vec2(1700.0,1200.0),vec2(0.0),vec2(1.0)))
 *step(0.0,p.x)*step(0.0,p.y)*step(p.x,1700.0)*step(p.y,1200.0);
 float variation=sin(p.x*.013+p.y*.007)*sin(p.y*.021-p.x*.003);
 vec3 grass=texture(grass_tex,mirrored(p/440.0)).rgb;
 grass*=vec3(.87,.95,.84)*(1.0+variation*.07);
 vec3 flowers=texture(meadow_tex,mirrored(p/310.0)).rgb*vec3(.93,.98,.90);
 float patches=smoothstep(-.6,.6,variation);
 grass=mix(grass,flowers,.48+patches*.35);
 float meadow=(1.0-smoothstep(510.0,560.0,p.x))*smoothstep(520.0,550.0,p.y)*(1.0-smoothstep(960.0,1000.0,p.y));
 grass=mix(grass,grass*vec3(1.13,1.04,.80),meadow*.7);
 vec3 earth=texture(earth_tex,mirrored(p/300.0)).rgb*vec3(.94,.92,.85);
 vec3 yard=texture(yard_tex,mirrored(p/210.0)).rgb*vec3(.96,.97,.95);
 yard=mix(yard,vec3(.65,.51,.30),.16);
 vec3 ground=mix(grass,mix(earth,yard,masks.g*.65),masks.r);
 ground=mix(ground,earth*vec3(.78,.81,.76),texture(wear_tex,clamp(p/vec2(1700.0,1200.0),vec2(0.0),vec2(1.0))).r*masks.r*.33);
 vec3 water=texture(water_tex,mirrored(p/170.0+vec2(TIME*.004,0.0))).rgb*vec3(.83,.92,.87);
 float edge=smoothstep(.02,.35,masks.b)*(1.0-smoothstep(.40,.85,masks.b));
 ground=mix(ground,earth*vec3(.65,.75,.62),edge*.72);
 ground=mix(ground,water,smoothstep(.24,.92,masks.b));
 float daylight=1.0+sin(p.x*.002+p.y*.001)*.025;
 COLOR=vec4(ground*daylight,1.0);
}
