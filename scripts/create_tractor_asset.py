import bpy, math, os
from mathutils import Vector

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
GLB = os.path.join(ROOT, 'game/assets/vehicles/bracken_tractor.glb')
PREVIEW = os.path.join(ROOT, 'docs/previews/bracken-tractor.png')

bpy.ops.wm.read_factory_settings(use_empty=True)

def material(name, color, rough=.68, metallic=0.0):
    m=bpy.data.materials.new(name)
    m.diffuse_color=(*color,1)
    m.use_nodes=True
    bsdf=m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value=(*color,1)
    bsdf.inputs['Roughness'].default_value=rough
    bsdf.inputs['Metallic'].default_value=metallic
    return m

paint=material('Deep Red Enamel',(0.38,0.035,0.022),.48,.10)
paint_light=material('Sunlit Red Enamel',(0.56,0.065,0.032),.52,.08)
paint_dark=material('Shadow Red',(0.24,0.018,0.012),.58,.08)
rubber=material('Agricultural Rubber',(0.012,0.016,0.014),.91)
frame_mat=material('Graphite Chassis',(0.055,0.064,0.061),.63,.28)
steel=material('Weathered Steel',(0.20,0.22,0.20),.58,.30)
glass=material('Smoky Blue Glass',(0.035,0.12,0.145),.23,.12)
glass_glint=material('Sky Reflection',(0.26,0.51,0.56),.18,.08)
rim=material('Warm Ochre Rims',(0.68,0.29,0.055),.58,.16)
lamp=material('Headlamp Glass',(0.92,0.72,0.29),.22,.05)
amber=material('Indicator Amber',(0.95,0.26,0.025),.30)
seat=material('Dark Cab Interior',(0.035,0.04,0.038),.88)
mud=material('Dry Cotswold Mud',(0.21,0.115,0.05),.96)
white=material('Work Light',(0.78,0.86,0.78),.32)
warning=material('Safety Red',(0.72,0.04,0.02),.55)

root=bpy.data.objects.new('BrackenTractor',None)
bpy.context.collection.objects.link(root)

def parent(obj,p=root): obj.parent=p; return obj

def apply_bevel(o,width=.05,segments=2):
    if width<=0:return
    mod=o.modifiers.new('Manufactured edge','BEVEL'); mod.width=width; mod.segments=segments; mod.limit_method='ANGLE'
    bpy.context.view_layer.objects.active=o; o.select_set(True)
    bpy.ops.object.modifier_apply(modifier=mod.name); o.select_set(False)

def cube(name,loc,size,mat,bevel=.045,rot=(0,0,0),p=root):
    bpy.ops.mesh.primitive_cube_add(location=loc,rotation=rot)
    o=bpy.context.object;o.name=name;o.scale=(size[0]/2,size[1]/2,size[2]/2)
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    apply_bevel(o,bevel,2);o.data.materials.append(mat);return parent(o,p)

def cyl(name,loc,radius,depth,mat,rot=(0,0,0),verts=20,bevel=.025,p=root):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts,radius=radius,depth=depth,location=loc,rotation=rot)
    o=bpy.context.object;o.name=name;apply_bevel(o,bevel,2);o.data.materials.append(mat);return parent(o,p)

def sphere(name,loc,radius,mat,p=root,subdiv=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdiv,radius=radius,location=loc)
    o=bpy.context.object;o.name=name;o.data.materials.append(mat);return parent(o,p)

def tapered_box(name,loc,front,back,length,mat,bevel=.055,p=root):
    # width/height at front (-Y) and rear (+Y)
    fw,fh=front;bw,bh=back;y=length/2
    verts=[(-fw/2,-y,-fh/2),(fw/2,-y,-fh/2),(fw/2,-y,fh/2),(-fw/2,-y,fh/2),
           (-bw/2,y,-bh/2),(bw/2,y,-bh/2),(bw/2,y,bh/2),(-bw/2,y,bh/2)]
    faces=[(0,1,2,3),(4,7,6,5),(0,4,5,1),(3,2,6,7),(0,3,7,4),(1,5,6,2)]
    mesh=bpy.data.meshes.new(name+'Mesh');mesh.from_pydata(verts,[],faces);mesh.materials.append(mat)
    o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o);o.location=loc;parent(o,p);apply_bevel(o,bevel,2);return o

def cab_panel(name,loc,size,mat,rot=(0,0,0)):
    return cube(name,loc,size,mat,.025,rot)

def fender(name,x,y,z,radius,width,mat):
    # A thin, manufactured arch following the upper 150 degrees of the tyre.
    steps=18; inner=radius+.09; outer=radius+.27; verts=[]
    for xx in (x-width/2,x+width/2):
        for rr in (inner,outer):
            for i in range(steps+1):
                a=math.radians(15+150*i/steps)
                verts.append((xx,y+math.cos(a)*rr,z+math.sin(a)*rr))
    def idx(face,band,i):return face*2*(steps+1)+band*(steps+1)+i
    faces=[]
    for face in (0,1):
        for i in range(steps): faces.append((idx(face,0,i),idx(face,0,i+1),idx(face,1,i+1),idx(face,1,i)))
    for band in (0,1):
        for i in range(steps): faces.append((idx(0,band,i),idx(1,band,i),idx(1,band,i+1),idx(0,band,i+1)))
    for i in (0,steps): faces.append((idx(0,0,i),idx(0,1,i),idx(1,1,i),idx(1,0,i)))
    mesh=bpy.data.meshes.new(name+'Mesh');mesh.from_pydata(verts,[],faces);mesh.materials.append(mat)
    o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o);parent(o);apply_bevel(o,.025,2)

def wheel(name,x,y,z,radius,width,steerable):
    steering=bpy.data.objects.new(name+'SteeringPivot',None);steering.location=(x,y,z);bpy.context.collection.objects.link(steering);parent(steering)
    spin=bpy.data.objects.new(name+'SpinPivot',None);bpy.context.collection.objects.link(spin);parent(spin,steering)
    cyl(name+'Tyre',(0,0,0),radius,width,rubber,(0,math.pi/2,0),24,.055,spin)
    side=1 if x>0 else -1
    cyl(name+'Rim',(side*width*.505,0,0),radius*.53,.065,rim,(0,math.pi/2,0),20,.018,spin)
    cyl(name+'Hub',(side*width*.55,0,0),radius*.19,.11,paint_dark,(0,math.pi/2,0),16,.018,spin)
    # Shallower treads preserve realism at gameplay scale.
    for i in range(14):
        a=2*math.pi*i/14
        lug=cube(name+'Tread', (0,math.cos(a)*(radius+.022),math.sin(a)*(radius+.022)),
                 (width+.07,.11,.24 if radius<.9 else .30),rubber,.018,(a,0,0),spin)
        lug.rotation_euler[1]=math.radians(8 if i%2 else -8)

# Long modern chassis and engine bay.
cube('MainChassis',(0,-.20,.58),(2.02,4.35,.38),frame_mat,.07)
cube('RearTransmission',(0,.93,.96),(2.06,1.42,1.05),paint_dark,.10)
tapered_box('EngineBonnet',(0,-1.24,1.40),(1.63,.76),(2.02,1.02),2.25,paint_light,.09)
tapered_box('BonnetTop',(0,-1.22,1.94),(1.48,.16),(1.82,.20),2.10,paint,.06)
cube('FrontNose',(0,-2.39,1.37),(1.60,.16,.83),frame_mat,.055)
for x in (-.54,-.27,0,.27,.54):
    cube('RadiatorSlot',(x,-2.485,1.37),(.055,.035,.55),steel,.008)
for x in (-.61,.61):
    cyl('HeadlampBezel',(x,-2.49,1.67),.19,.09,frame_mat,(math.pi/2,0,0),20,.018)
    sphere('Headlamp',(x,-2.545,1.67),.135,lamp)
# Side ventilation and unbranded graphic panels.
for x in (-1.015,1.015):
    for y in (-1.65,-1.38,-1.11):
        cube('SideVent',(x,y,1.47),(.035,.15,.40),frame_mat,.008)
    cube('SideAccent',(x*1.008,-.82,1.64),(.022,.78,.10),rim,.006)

# Cab uses slim frames and large dark panes like the reference.
cube('CabFloor',(0,.45,1.18),(2.18,1.90,.35),frame_mat,.07)
cube('RearCabBase',(0,1.22,1.48),(2.08,.54,.76),paint,.09)
for x in (-.95,.95):
    cab_panel('FrontPillar',(x,-.31,2.30),(.12,.14,1.86),frame_mat)
    cab_panel('RearPillar',(x,1.36,2.30),(.13,.14,1.86),frame_mat)
    cab_panel('SideGlass',(x*1.003,.52,2.34),(.045,1.42,1.42),glass)
cab_panel('FrontGlass',(0,-.35,2.35),(1.72,.045,1.40),glass)
cab_panel('RearGlass',(0,1.42,2.35),(1.72,.045,1.34),glass)
# Thin highlights make glass readable without making it opaque blue plastic.
cube('FrontGlassGlint',(-.45,-.379,2.73),(.52,.012,.055),glass_glint,.005)
for x in (-.95,.95):
    cube('SideGlassGlint',(x*1.012,.20,2.70),(.012,.48,.045),glass_glint,.004)
cube('CabRoof',(0,.53,3.25),(2.42,2.18,.22),paint,.10)
cube('RoofInset',(0,.51,3.37),(2.15,1.90,.07),paint_light,.035)
# Interior remains visible through the glazing.
cube('SeatBase',(0,.75,1.48),(.72,.62,.30),seat,.10)
cube('SeatBack',(0,1.04,1.91),(.76,.24,.78),seat,.10,(math.radians(-7),0,0))
cube('Dashboard',(0,-.22,1.79),(1.45,.30,.38),seat,.06)
cyl('SteeringColumn',(0,-.16,1.95),.045,.52,steel,(math.radians(62),0,0),14,.01)
bpy.ops.mesh.primitive_torus_add(major_radius=.255,minor_radius=.028,major_segments=20,minor_segments=6,location=(0,-.36,2.14),rotation=(math.radians(64),0,0))
sw=bpy.context.object;sw.name='SteeringWheel';sw.data.materials.append(seat);parent(sw)

# Mirrors, work lamps, beacon, exhaust and intake.
for x in (-1.34,1.34):
    cube('MirrorArm',(x,-.13,2.70),(.65,.07,.07),frame_mat,.015)
    cube('MirrorHousing',(x*1.04,-.13,2.68),(.20,.12,.39),frame_mat,.035)
    cube('MirrorGlass',(x*1.047,-.20,2.68),(.15,.018,.29),glass_glint,.01)
    sphere('FrontIndicator',(x*.78,-2.43,1.94),.075,amber)
for x in (-.69,.69):
    cube('RearWorkLamp',(x,1.50,2.85),(.24,.13,.20),frame_mat,.035)
    cube('RearLightFace',(x,1.575,2.85),(.17,.025,.13),white,.01)
cyl('BeaconBase',(.66,.55,3.47),.12,.07,frame_mat,verts=16,bevel=.015)
cyl('Beacon',(.66,.55,3.59),.105,.20,amber,verts=16,bevel=.025)
cyl('Exhaust',(.72,-.63,2.55),.085,1.65,frame_mat,verts=16,bevel=.018)
cyl('ExhaustCap',(.72,-.63,3.40),.135,.065,frame_mat,verts=16,bevel=.015)
cyl('AirIntake',(-.72,-.64,2.38),.10,1.28,steel,verts=16,bevel=.02)
cyl('IntakeHead',(-.72,-.64,3.05),.16,.11,steel,verts=16,bevel=.025)

# Correct agricultural wheel proportions and integrated arches.
for x in (-1.37,1.37): wheel('RearLeft' if x<0 else 'RearRight',x,1.10,1.08,1.08,.56,False)
for x in (-1.20,1.20): wheel('FrontLeft' if x<0 else 'FrontRight',x,-1.62,.75,.75,.42,True)
fender('LeftRearFender',-1.25,1.10,1.08,1.08,.22,paint)
fender('RightRearFender',1.25,1.10,1.08,1.08,.22,paint)
for x in (-1.25,1.25):
    cube('CabStep',(x,.02,.62),(.58,.82,.09),steel,.025)
    cube('StepRiser',(x,.27,.82),(.08,.48,.48),frame_mat,.02)
    cube('LowerMud',(x*1.01,1.06,.49),(.035,.72,.15),mud,.008)

# Functional connection points and road details.
cube('FrontWeight',(0,-2.66,.58),(1.12,.44,.42),steel,.07)
cube('FrontTowEye',(0,-2.92,.54),(.25,.18,.22),frame_mat,.04)
for x in (-.48,.48): cube('RearLinkArm',(x,2.01,.52),(.13,.92,.13),frame_mat,.025,(math.radians(-8),0,0))
cyl('RearHitch',(0,2.48,.46),.12,.66,rim,(0,math.pi/2,0),16,.018)
cube('RearWarningPanel',(0,1.73,1.18),(.72,.08,.18),warning,.02)
# A restrained dirt layer avoids the showroom-plastic look.
cube('BonnetDust',(0,-1.95,1.05),(1.45,.50,.035),mud,.01,(math.radians(8),0,0))
cube('RearDust',(0,1.54,1.16),(1.52,.035,.26),mud,.008)

# Export the authored hierarchy before adding preview-only objects.
bpy.ops.object.select_all(action='DESELECT')
for o in bpy.context.scene.objects: o.select_set(True)
bpy.context.view_layer.objects.active=root
bpy.ops.export_scene.gltf(filepath=GLB,export_format='GLB',use_selection=True,export_apply=True,export_yup=True)

# Neutral farm-colour preview stage.
bpy.ops.object.select_all(action='DESELECT')
bpy.ops.mesh.primitive_plane_add(size=30,location=(0,0,-.02))
ground=bpy.context.object;ground.data.materials.append(material('Preview Grass',(0.33,0.47,0.23),.98))
bpy.ops.object.light_add(type='AREA',location=(-4,-5,9));key=bpy.context.object;key.data.energy=1050;key.data.shape='DISK';key.data.size=6
bpy.ops.object.light_add(type='AREA',location=(5,2,5));fill=bpy.context.object;fill.data.energy=480;fill.data.size=5
bpy.ops.object.camera_add(location=(7.8,-10.2,6.3));cam=bpy.context.object
cam.rotation_euler=(Vector((0,-.1,1.55))-cam.location).to_track_quat('-Z','Y').to_euler()
cam.data.type='ORTHO';cam.data.ortho_scale=6.8
scene=bpy.context.scene;scene.camera=cam;scene.render.engine='BLENDER_EEVEE_NEXT'
scene.render.resolution_x=1000;scene.render.resolution_y=800;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.render.filepath=PREVIEW;scene.render.film_transparent=False
scene.world=bpy.data.worlds.new('Preview World');scene.world.color=(0.095,0.14,0.12)
scene.view_settings.look='AgX - Medium High Contrast'
bpy.ops.render.render(write_still=True)
print('WROTE',GLB)
print('WROTE',PREVIEW)
