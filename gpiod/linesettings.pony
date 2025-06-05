use @gpiod_line_settings_new[Pointer[None] tag]()
use @gpiod_line_settings_free[None](settings:Pointer[None] tag)
use @gpiod_line_settings_reset[None](settings:Pointer[None] tag)
use @gpiod_line_settings_copy[Pointer[None] tag](settings:Pointer[None] tag)
use @gpiod_line_settings_set_direction[I32](settings:Pointer[None] tag,direction:I32)
use @gpiod_line_settings_get_direction[I32](settings:Pointer[None] tag)
use @gpiod_line_settings_set_edge_detection[I32](settings:Pointer[None] tag,edge:I32)
use @gpiod_line_settings_get_edge_detection[I32](settings:Pointer[None] tag)
use @gpiod_line_settings_set_bias[I32](settings:Pointer[None] tag,bias:I32)
use @gpiod_line_settings_get_bias[I32](settings:Pointer[None] tag)
use @gpiod_line_settings_set_drive[I32](settings:Pointer[None] tag,drive:I32)
use @gpiod_line_settings_get_drive[I32](settings:Pointer[None] tag)
use @gpiod_line_settings_set_active_low[I32](settings:Pointer[None] tag,active_low:Bool)
use @gpiod_line_settings_get_active_low[Bool](settings:Pointer[None] tag)
use @gpiod_line_settings_set_debounce_period_us[None](settings:Pointer[None] tag,period:U64)
use @gpiod_line_settings_get_debounce_period_us[U64](settings:Pointer[None] tag)
use @gpiod_line_settings_set_event_clock[I32](settings:Pointer[None] tag,event_clock:I32)
use @gpiod_line_settings_get_event_clock[I32](settings:Pointer[None] tag)
use @gpiod_line_settings_set_output_value[I32](settings:Pointer[None] tag,value:I32)
use @gpiod_line_settings_get_output_value[I32](settings:Pointer[None] tag)



class iso GpioLineSettings
  """
  Functions for manipulating line settings objects.

  Line settings object contains a set of line properties that can be used
  when requesting lines or reconfiguring an existing request.

  Mutators in general can only fail if the new property value is invalid. The
  return values can be safely ignored - the object remains valid even after
  a mutator fails and simply uses the sane default appropriate for given
  property.
  """
  let _ctx:Pointer[None] tag

  new iso create() =>
    _ctx = @gpiod_line_settings_new()

  new iso from_ptr(ctx:Pointer[None] tag) =>
    _ctx = ctx

  fun final() =>
    @gpiod_line_settings_free(_ctx)

  fun cpointer():Pointer[None] tag =>
    _ctx

  fun reset() =>
    """
    Reset the line settings object to its default values.
    """
    @gpiod_line_settings_reset(_ctx)

  fun iso copy(): GpioLineSettings ? =>
    """
    Copy the line settings object.
    """
    let result = @gpiod_line_settings_copy(_ctx)
    if not result.is_null() then
      error
    end
    GpioLineSettings.from_ptr(result)

  fun set_direction(direction:GpioLineDirection):I32 =>
    """
    Set direction.

    @param direction New direction.
    @return 0 on success, -1 on error.
    """
    @gpiod_line_settings_set_direction(_ctx, direction())

  fun get_direction():GpioLineDirection =>
    """
    Get direction.
    """
    _direction(@gpiod_line_settings_get_direction(_ctx))

  fun _direction(cdata:I32):GpioLineDirection =>
    match cdata
    | 1 => GpioLineDirectionAsIs
    | 2 => GpioLineDirectionInput
    | 3 => GpioLineDirectionOutput
    else
      GpioLineDirectionAsIs
    end

  fun set_edge_detection(edge:GpioLineEdge):I32 =>
    """
    Set edge detection.

    @param edge New edge detection setting.
    @return 0 on success, -1 on failure.
    """
    @gpiod_line_settings_set_edge_detection(_ctx, edge())

  fun get_edge_detection(): GpioLineEdge =>
    """
    Get edge detection.
    """
    _line_edge(@gpiod_line_settings_get_edge_detection(_ctx))

  fun _line_edge(cdata:I32):GpioLineEdge =>
    match cdata
    | 1 => GpioLineEdgeNone
    | 2 => GpioLineEdgeRising
    | 3 => GpioLineEdgeFalling
    | 4 => GpioLineEdgeBoth
    else
      GpioLineEdgeNone
    end

  fun set_bias(bias:GpioLineBias):I32 =>
    """
    Set bias.
    @param bias New bias.
    @return 0 on success, -1 on failure.
    """
    @gpiod_line_settings_set_bias(_ctx,bias())

  fun get_bias():GpioLineBias =>
    """
    Get bias.

    @return Current bias setting.
    """
    _bias(@gpiod_line_settings_get_bias(_ctx))

  fun _bias(cdata:I32):GpioLineBias =>
    match cdata
    | 1 => GpioLineBiasAsIs
    | 2 => GpioLineBiasUnknown
    | 3 => GpioLineBiasDisabled
    | 4 => GpioLineBiasPullUp
    | 5 => GpioLineBiasPullDown
    else
      GpioLineBiasAsIs
    end

  fun set_drive(drive:GpioLineDrive):I32 =>
    """
    Set drive.

    @param drive New drive setting.
    @return 0 on success, -1 on failure.
    """
    @gpiod_line_settings_set_drive(_ctx, drive())

  fun gpiod_line_settings_get_drive():GpioLineDrive =>
    """
    Get drive.
    """
    _drive(@gpiod_line_settings_get_drive(_ctx))

  fun _drive(cdata:I32):GpioLineDrive =>
    match cdata
    | 1 => GpioLineDrivePushPull
    | 2 => GpioLineDriveOpenDrain
    | 3 => GpioLineDriveOpenSource
    else
      GpioLineDrivePushPull
    end

  fun set_active_low(active_low:Bool) =>
    """
    Set active-low setting.

    @param active_low New active-low setting.
    """
    @gpiod_line_settings_set_active_low(_ctx, active_low)

  fun get_active_low():Bool =>
    """
    Get active-low setting.

    @return True if active-low is enabled, false otherwise.
    """
    @gpiod_line_settings_get_active_low(_ctx)

  fun set_debounce_period_us(period:U64) =>
    """
    Set debounce period.

    @param period New debounce period in microseconds.
    """
    @gpiod_line_settings_set_debounce_period_us(_ctx, period)

  fun get_debounce_period_us():U64 =>
    """
    Get debounce period.

    @return Current debounce period in microseconds.
    """
    @gpiod_line_settings_get_debounce_period_us(_ctx)

  fun set_event_clock(event_clock:GpioLineClock):I32 =>
    """
    Set event clock.

    @param event_clock New event clock.
    @return 0 on success, -1 on failure.
    """
    @gpiod_line_settings_set_event_clock(_ctx,event_clock())

  fun get_event_clock():GpioLineClock =>
    """
    Get event clock setting.

    @return Current event clock setting.
    """
    _line_clock(@gpiod_line_settings_get_event_clock(_ctx))

  fun _line_clock(cdata:I32):GpioLineClock =>
    match cdata
    | 1 => GpioLineClockMonotonic
    | 2 => GpioLineClockRealtime
    | 3 => GpioLineClockHte
    else
      GpioLineClockMonotonic
    end

  fun set_output_value(value:GpioLineValue):I32 =>
    """
    Set the output value.

    @param value New output value.
    @return 0 on success, -1 on failure.
    """
    @gpiod_line_settings_set_output_value(_ctx,value())

  fun get_output_value():GpioLineValue =>
    """
    Get the output value.
    """
    _line_value(@gpiod_line_settings_get_output_value(_ctx))

  fun _line_value(cdata:I32):GpioLineValue =>
    match cdata
    | 1 => GpioLineValueError
    | 2 => GpioLineValueInactive
    | 3 => GpioLineValueActive
    else
      GpioLineValueError
    end

