shader_type canvas_item;
uniform float phase=0.0;
void vertex(){
 float crown=1.0-UV.y;
 VERTEX.x+=sin(TIME*1.15+phase+UV.y*2.0)*crown*crown*2.3;
}
