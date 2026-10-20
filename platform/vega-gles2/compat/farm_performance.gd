extends Node

# Bounded local startup timing: counts and durations only, never room/input/clues.
var previous_ms=0
var started_ms=0
var intervals=[]
var reports=0
func _ready():
 if not OS.has_feature("JavaScript"):
  set_process(false)
  return
 previous_ms=OS.get_ticks_msec()
 started_ms=previous_ms
func _process(_delta):
 var now=OS.get_ticks_msec()
 intervals.append(now-previous_ms)
 previous_ms=now
 if now-started_ms<5000:return
 var sorted=intervals.duplicate()
 sorted.sort()
 var report={"source":"farm-startup","kind":"performance","sample":reports,"fps":stepify(intervals.size()*1000.0/(now-started_ms),.1),"frame_p95_ms":sorted[int((sorted.size()-1)*.95)],"process_ms":stepify(Performance.get_monitor(Performance.TIME_PROCESS)*1000,.1),"physics_ms":stepify(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000,.1)}
 JavaScript.eval("window.ReactNativeWebView && window.ReactNativeWebView.postMessage("+to_json(to_json(report))+")")
 intervals.clear()
 started_ms=now
 reports+=1
 if reports>=12:set_process(false)
