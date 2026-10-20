shader_type canvas_item;
render_mode unshaded;
uniform sampler2D water_tex;
vec2 mirrored(vec2 uv){return 1.0-abs(mod(uv,2.0)-1.0);}
void fragment(){
 vec2 p=UV*vec2(2040.0,1440.0)-vec2(170.0,120.0);
 vec4 masks=texture(TEXTURE,clamp(p/vec2(1700.0,1200.0),vec2(0.0),vec2(1.0)))
 *step(0.0,p.x)*step(0.0,p.y)*step(p.x,1700.0)*step(p.y,1200.0);
 vec3 water=texture(water_tex,mirrored(p/170.0+vec2(TIME*.004,0.0))).rgb*vec3(.83,.92,.87);
 float daylight=1.0+sin(p.x*.002+p.y*.001)*.025;
 COLOR=vec4(water*daylight,smoothstep(.24,.92,masks.b));
}
