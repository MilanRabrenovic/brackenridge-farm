shader_type canvas_item;
// Animate diagonal pairs of legs in existing art; no whole-sprite rotation.
uniform float gait=0.0;
uniform float stride=0.0;
void fragment(){
 vec2 uv=UV;
 float leg=smoothstep(.60,.86,uv.y);
 float pair=(uv.x<.23 || (uv.x>.46 && uv.x<.69))?1.0:-1.0;
 uv.x+=sin(gait)*pair*.017*leg*stride;
 uv.y+=max(0.0,cos(gait)*pair)*.026*leg*stride;
 vec4 pixel=texture(TEXTURE,uv);
 if(uv.x<0.0||uv.x>1.0||uv.y>1.0)pixel=vec4(0.0);
 COLOR*=pixel;
}
