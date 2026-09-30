shader_type canvas_item;
varying vec4 tint;
void vertex(){tint=COLOR;}
void fragment(){
 vec4 c=texture(TEXTURE,UV);
 vec2 d=TEXTURE_PIXEL_SIZE*1.5;
 float neighbours=texture(TEXTURE,UV+vec2(d.x,0)).a+texture(TEXTURE,UV-vec2(d.x,0)).a;
 neighbours+=texture(TEXTURE,UV+vec2(0,d.y)).a+texture(TEXTURE,UV-vec2(0,d.y)).a;
 // Suppress isolated extraction flecks, preserve connected beams and leaves.
 c.a*=smoothstep(.35,1.25,neighbours);
 COLOR=c*tint;
}
