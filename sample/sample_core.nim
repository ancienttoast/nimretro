import
  libretro
include
  libretro/exports



var
  frame_buf: seq[uint32]
  logging: retro_log_callback
  log_cb: retro_log_printf_t

var
  video_cb: retro_video_refresh_t
  audio_cb: retro_audio_sample_t
  audio_batch_cb: retro_audio_sample_batch_t
  environ_cb: retro_environment_t
  input_poll_cb: retro_input_poll_t
  input_state_cb: retro_input_state_t

var
  x_coord: uint32
  y_coord: uint32
  mouse_rel_x: int32 = 0
  mouse_rel_y: int32 = 0



proc update_input() =
  input_poll_cb()
  if input_state_cb(0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_UP) != 0:
    #[ stub ]#
    discard

  mouse_rel_x = ((input_state_cb(0, RETRO_DEVICE_POINTER, 0, RETRO_DEVICE_ID_POINTER_X) / 0x7fff) * 160 + 160).int32
  mouse_rel_y = ((input_state_cb(0, RETRO_DEVICE_POINTER, 0, RETRO_DEVICE_ID_POINTER_Y) / 0x7fff) * 120 + 120).int32
  log_cb(RETRO_LOG_DEBUG, "Mouse position: %d %d\n", mouse_rel_x, mouse_rel_y)

proc render_checkered() =
  var
    stride = 320.cuint
    color_r = 0xff'u32 shl 16
    color_g = 0xff'u32 shl 8
  
  for y in 0..<240:
    let
      index_y = ((y - y_coord.int) shr 4) and 1
    for x in 0..<320:
      let
        index_x = ((x - x_coord.int) shr 4) and 1
        i = y * 320 + x
      frame_buf[i] = if (index_y xor index_x) != 0: color_r else: color_g

  for y in mouse_rel_y - 5 ..< mouse_rel_y + 5:
    for x in mouse_rel_x - 5 ..< mouse_rel_x + 5:
      let
        i = y * 320 + x
      if i >= 0 and i <= frame_buf.high:
        frame_buf[i] = 0xff

  video_cb(addr frame_buf[0], 320, 240, stride shl 2)

proc check_variables() =
  discard

proc audio_callback() =
  audio_cb(0, 0)



proc retro_init*() =
  frame_buf = newSeq[uint32](320 * 240)

proc retro_deinit*() =
  discard

proc retro_api_version*(): cuint =
  RETRO_API_VERSION

proc retro_set_controller_port_device*(port: cuint; device: cuint) =
  discard

proc retro_get_system_info*(info: ptr retro_system_info) =
  info.library_name     = "NimRetro Sample Core"
  info.library_version  = "v1"
  info.need_fullpath    = false
  info.valid_extensions = nil # Anything is fine, we don't care.

proc retro_get_system_av_info*(info: ptr retro_system_av_info) =
  let
    aspect = 4'f32 / 3'f32

  info.timing = retro_system_timing(
    fps: 60,
    sample_rate: 0
  )

  info.geometry = retro_game_geometry(
    base_width: 320,
    base_height: 240,
    max_width: 320,
    max_height: 240,
    aspect_ratio: aspect
  )



proc retro_set_environment*(cb: retro_environment_t) =
  environ_cb = cb

  var
    no_content = true
  discard cb(RETRO_ENVIRONMENT_SET_SUPPORT_NO_GAME, addr no_content)

  if cb(RETRO_ENVIRONMENT_GET_LOG_INTERFACE, addr logging):
    log_cb = logging.log
  #[
  else:
    log_cb = fallback_log
  ]#

proc retro_set_audio_sample*(cb: retro_audio_sample_t) =
  audio_cb = cb

proc retro_set_audio_sample_batch*(cb: retro_audio_sample_batch_t) =
  audio_batch_cb = cb

proc retro_set_input_poll*(cb: retro_input_poll_t) =
  input_poll_cb = cb

proc retro_set_input_state*(cb: retro_input_state_t) =
  input_state_cb = cb

proc retro_set_video_refresh*(cb: retro_video_refresh_t) =
  video_cb = cb


proc retro_reset*() =
  x_coord = 0
  y_coord = 0

proc retro_run*() =
  update_input()
  render_checkered()
  audio_callback()

  var
    updated = false
  if environ_cb(RETRO_ENVIRONMENT_GET_VARIABLE_UPDATE, addr updated) and updated:
    check_variables()


proc retro_load_game*(game: ptr retro_game_info): bool =
  var
    fmt = RETRO_PIXEL_FORMAT_XRGB8888
  if not environ_cb(RETRO_ENVIRONMENT_SET_PIXEL_FORMAT, addr fmt):
    log_cb(RETRO_LOG_INFO, "XRGB8888 is not supported.\n")
    return false

  check_variables()
  return true

proc retro_unload_game*() =
  discard

proc retro_get_region*(): cuint =
  RETRO_REGION_NTSC

proc retro_load_game_special*(game_type: cuint; info: ptr retro_game_info; num_info: csize_t): bool =
  if game_type != 0x200:
    false
  elif num_info != 2:
    false
  else:
    retro_load_game(nil)

proc retro_serialize_size*(): csize_t =
  2

proc retro_serialize*(data: pointer; size: csize_t): bool =
  if size < 2:
    return false

  var
    data = cast[ptr UncheckedArray[uint8]](data)
  data[0] = x_coord.uint8
  data[1] = y_coord.uint8
  return true

proc retro_unserialize*(data: pointer; size: csize_t): bool =
  if size < 2:
    return false

  var
    data = cast[ptr UncheckedArray[uint8]](data)
  x_coord = data[0].uint32
  y_coord = data[1].uint32
  return true

proc retro_get_memory_data*(id: cuint): pointer =
  return nil

proc retro_get_memory_size*(id: cuint): csize_t =
  return 0

proc retro_cheat_reset*() =
  discard

proc retro_cheat_set*(index: cuint; enabled: bool; code: cstring) =
  discard
