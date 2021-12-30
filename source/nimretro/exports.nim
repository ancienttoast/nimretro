{.push cdecl, exportc, dynlib.}

proc retro_set_environment*(cb: retro_environment_t)
  ##  Sets callbacks. retro_set_environment() is guaranteed to be called
  ##  before retro_init().
  ##
  ##  The rest of the set_* functions are guaranteed to have been called
  ##  before the first call to retro_run() is made.
proc retro_set_video_refresh*(cb: retro_video_refresh_t)
proc retro_set_audio_sample*(cb: retro_audio_sample_t)
proc retro_set_audio_sample_batch*(cb: retro_audio_sample_batch_t)
proc retro_set_input_poll*(cb: retro_input_poll_t)
proc retro_set_input_state*(cb: retro_input_state_t)

proc retro_init*()
  ##  Library global initialization/deinitialization.
proc retro_deinit*()

proc retro_api_version*(): cuint
  ##  Must return RETRO_API_VERSION. Used to validate ABI compatibility
  ##  when the API is revised.

proc retro_get_system_info*(info: ptr retro_system_info)
  ##  Gets statically known system info. Pointers provided in *info
  ##  must be statically allocated.
  ##  Can be called at any time, even before retro_init().

proc retro_get_system_av_info*(info: ptr retro_system_av_info)
  ##  Gets information about system audio/video timings and geometry.
  ##  Can be called only after retro_load_game() has successfully completed.
  ##  NOTE: The implementation of this function might not initialize every
  ##  variable if needed.
  ##  E.g. geom.aspect_ratio might not be initialized if core doesn't
  ##  desire a particular aspect ratio.

proc retro_set_controller_port_device*(port: cuint; device: cuint)
  ##  Sets device to be used for player 'port'.
  ##  By default, RETRO_DEVICE_JOYPAD is assumed to be plugged into all
  ##  available ports.
  ##  Setting a particular device type is not a guarantee that libretro cores
  ##  will only poll input based on that particular device type. It is only a
  ##  hint to the libretro core when a core cannot automatically detect the
  ##  appropriate input device type on its own. It is also relevant when a
  ##  core can change its behavior depending on device type.
  ##
  ##  As part of the core's implementation of retro_set_controller_port_device,
  ##  the core should call RETRO_ENVIRONMENT_SET_INPUT_DESCRIPTORS to notify the
  ##  frontend if the descriptions for any controls have changed as a
  ##  result of changing the device type.

proc retro_reset*()
  ##  Resets the current game.

proc retro_run*()
  ##  Runs the game for one video frame.
  ##  During retro_run(), input_poll callback must be called at least once.
  ##
  ##  If a frame is not rendered for reasons where a game "dropped" a frame,
  ##  this still counts as a frame, and retro_run() should explicitly dupe
  ##  a frame if GET_CAN_DUPE returns true.
  ##  In this case, the video callback can take a NULL argument for data.

proc retro_serialize_size*(): csize_t
  ##  Returns the amount of data the implementation requires to serialize
  ##  internal state (save states).
  ##  Between calls to retro_load_game() and retro_unload_game(), the
  ##  returned size is never allowed to be larger than a previous returned
  ##  value, to ensure that the frontend can allocate a save state buffer once.

proc retro_serialize*(data: pointer; size: csize_t): bool
  ##  Serializes internal state. If failed, or size is lower than
  ##  retro_serialize_size(), it should return false, true otherwise.
proc retro_unserialize*(data: pointer; size: csize_t): bool
proc retro_cheat_reset*()
proc retro_cheat_set*(index: cuint; enabled: bool; code: cstring)

proc retro_load_game*(game: ptr retro_game_info): bool
  ##  Loads a game.
  ##  Return true to indicate successful loading and false to indicate load failure.

proc retro_load_game_special*(game_type: cuint; info: ptr retro_game_info;
                             num_info: csize_t): bool
  ##  Loads a "special" kind of game. Should not be used,
  ##  except in extreme cases.

proc retro_unload_game*()
  ##  Unloads the currently loaded game. Called before retro_deinit(void).

proc retro_get_region*(): cuint
  ##  Gets region of game.

proc retro_get_memory_data*(id: cuint): pointer
  ##  Gets region of memory.
proc retro_get_memory_size*(id: cuint): csize_t

{.pop.}
