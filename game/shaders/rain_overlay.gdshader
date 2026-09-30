shader_type canvas_item;
uniform float strength = 0.0;
void fragment(){
 vec2 p=UV*vec2(220.0,90.0);p.x+=p.y*.35;p.y+=TIME*34.0;
 float column=floor(p.x);float h=fract(sin(column*127.1)*43758.5453);
 float streak=step(.91,fract(p.x))*step(.88,fract(p.y+h*17.0));
 COLOR=vec4(.68,.80,.86,streak*strength*.23);
}
