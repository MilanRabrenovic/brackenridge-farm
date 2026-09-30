shader_type canvas_item;
render_mode unshaded;
void fragment(){
 vec2 step_uv=TEXTURE_PIXEL_SIZE*2.0;
 float a=texture(TEXTURE,UV).a*.28;
 a+=texture(TEXTURE,UV+vec2(step_uv.x,0)).a*.18;
 a+=texture(TEXTURE,UV-vec2(step_uv.x,0)).a*.18;
 a+=texture(TEXTURE,UV+vec2(0,step_uv.y)).a*.18;
 a+=texture(TEXTURE,UV-vec2(0,step_uv.y)).a*.18;
 COLOR=vec4(.12,.17,.16,a*.24);
}
