shader_type canvas_item;
render_mode unshaded;
uniform vec2 edge_points[16];
uniform int point_count=0;
varying vec2 ground_position;
varying vec4 surface_tint;
void vertex(){ground_position=VERTEX;surface_tint=COLOR;}
void fragment(){
 float d=99999.0;
 for(int i=0;i<16;i++){
  if(i>=point_count)break;
  vec2 a=edge_points[i],b=edge_points[(i+1)%point_count];
  vec2 ab=b-a;float t=clamp(dot(ground_position-a,ab)/dot(ab,ab),0.0,1.0);
  d=min(d,length(ground_position-a-t*ab));
 }
 float noise=sin(ground_position.x*.8+ground_position.y*.34)*2.0+sin(ground_position.y*1.3)*1.5;
 vec4 tex=texture(TEXTURE,1.0-abs(mod(UV,2.0)-1.0));
 COLOR=vec4(tex.rgb,smoothstep(0.0,10.0,d+noise))*surface_tint;
}
