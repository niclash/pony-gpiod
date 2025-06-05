use @gpiod_line_config_new[Pointer[None] tag]()
use @gpiod_line_config_free[None](config:Pointer[None] tag)
use @gpiod_line_config_reset[None](config:Pointer[None] tag)
use @gpiod_line_config_add_line_settings[I32](config:Pointer[None] tag, offsets:Pointer[U32] tag, num_offsets:U32, settings:Pointer[None] tag)
use @gpiod_line_config_get_line_settings[Pointer[None] tag](config:Pointer[None] tag, offset:U32)
use @gpiod_line_config_set_output_values[I32](config:Pointer[None] tag, values:Pointer[I32] tag, num_values:U32)
use @gpiod_line_config_get_num_configured_offsets[U32](config:Pointer[None] tag)
use @gpiod_line_config_get_configured_offsets[U32](config:Pointer[None] tag, offsets:Pointer[U32] tag, max_offsets:U32)



class iso GpioLineConfig
  """
  Functions for manipulating line configuration objects.

  The line-config object contains the configuration for lines that can be
  used in two cases:
   - when making a line request
   - when reconfiguring a set of already requested lines.

  A new line-config object is empty. Using it in a request will lead to an
  error. In order to a line-config to become useful, it needs to be assigned
  at least one offset-to-settings mapping by calling
  ::gpiod_line_config_add_line_settings.

  When calling ::gpiod_chip_request_lines, the library will request all
  offsets that were assigned settings in the order that they were assigned.
  If any of the offsets was duplicated, the last one will take precedence.
  """
  let _ctx:Pointer[None] tag

  new create() ? =>
    _ctx = @gpiod_line_config_new()
    if _ctx.is_null() then error end

  fun _final() =>
    if not _ctx.is_null() then
      @gpiod_line_config_free(_ctx)
    end

  fun cpointer(): Pointer[None] tag =>
    _ctx

  fun reset() =>
    """
    Reset the line config object.

    Resets the entire configuration stored in the object. This is useful if
    the user wants to reuse the object without reallocating it.
    """
    @gpiod_line_config_reset(_ctx)

  fun add_line_settings(offsets:Array[USize], settings:GpioLineSettings):I32 =>
    """
    Add line settings for a set of offsets.

    @param offsets Array of offsets for which to apply the settings.
    @param num_offsets Number of offsets stored in the offsets array.
    @param settings Line settings to apply.
    @return 0 on success, -1 on failure.
    """
    let offs = Array[U32]
    for o in offsets.values() do
      offs.push(o.u32())
    end
    @gpiod_line_config_add_line_settings(_ctx, offs.cpointer(), offsets.size().u32(), settings.cpointer())

  fun iso get_line_settings(offset:USize):GpioLineSettings =>
    """
    Get line settings for offset.

    @param offset Offset for which to get line settings.
    @return New line settings object (must be freed by the caller) or NULL on error.
    """
    GpioLineSettings.from_ptr(@gpiod_line_config_get_line_settings(_ctx, offset.u32()))

  fun set_output_values(values:Array[GpioLineValue]):I32 =>
    """
    Set output values for a number of lines.

    This is a helper that allows users to set multiple (potentially different)
    output values at once while using the same line settings object. Instead of
    modifying the output value in the settings object and calling
    #add_line_settings() multiple times, we can specify the
    settings, add them for a set of offsets and then call this function to
    set the output values.

    Values set by this function override whatever values were specified in the
    regular line settings.

    Each value must be associated with the line identified by the corresponding
    entry in the offset array filled by
    GpioLineRequest.get_requested_offsets().

    @param values Buffer containing the output values.
    @return 0 on success, -1 on error.
    """
    let line_values = Array[I32]
    for v in values.values() do
      line_values.push(v())
    end
    @gpiod_line_config_set_output_values(_ctx, line_values.cpointer(), line_values.size().u32())

  fun get_num_configured_offsets():USize =>
    """
    Get the number of configured line offsets.

    @return Number of offsets for which line settings have been added.
    """
    USize.from[U32](@gpiod_line_config_get_num_configured_offsets(_ctx))

  fun get_configured_offsets(max_offsets:USize):Array[USize] ? =>
    """
    Get configured offsets.

    @param offsets Array to store offsets.
    @param max_offsets Number of offsets that can be stored in the offsets array.
    @return Number of offsets stored in the offsets array.

    If max_offsets is lower than the number of lines actually requested (this
    value can be retrieved using #get_num_configured_offsets()),
    then only up to max_lines offsets will be stored in offsets.
    """
    let data = Array[U32](max_offsets)
    let fetched:U32 = @gpiod_line_config_get_configured_offsets(_ctx, data.cpointer(), max_offsets.u32())
    let len = USize.from[U32](fetched)
    var result = Array[USize]
    var idx:USize = 0
    while idx < len do
      let v = data(idx)?
      result.push(USize.from[U32](v))
      idx = idx + 1
    end
    result
