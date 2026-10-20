class_name FarmSocket
extends Reference
const STATE_OPEN=2
const STATE_CLOSED=0
var client=WebSocketClient.new()
func connect_to_url(url):return client.connect_to_url(url)
func poll():client.poll()
func get_ready_state():return client.get_connection_status()
func get_available_packet_count():return client.get_peer(1).get_available_packet_count() if get_ready_state()==STATE_OPEN else 0
func get_packet():return client.get_peer(1).get_packet()
func send_text(value):
 var peer=client.get_peer(1);peer.set_write_mode(WebSocketPeer.WRITE_MODE_TEXT);return peer.put_packet(value.to_utf8())
