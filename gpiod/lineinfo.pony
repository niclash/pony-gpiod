
use @gpiod_line_info_free[None](info:Pointer[None] tag)
use @gpiod_line_info_copy[Pointer[None] tag](info:Pointer[None] tag)
use @gpiod_line_info_get_offset[U32](info:Pointer[None] tag)
use @gpiod_line_info_get_name[Pointer[U8 val] val](info:Pointer[None] tag)
use @gpiod_line_info_is_used[Bool](info:Pointer[None] tag)
use @gpiod_line_info_get_consumer[Pointer[U8 val] box](info:Pointer[None] tag)
use @gpiod_line_info_get_direction[I32](info:Pointer[None] tag)
use @gpiod_line_info_get_edge_detection[I32](info:Pointer[None] tag)
use @gpiod_line_info_get_bias[I32](info:Pointer[None] tag)
use @gpiod_line_info_get_drive[I32](info:Pointer[None] tag)
use @gpiod_line_info_is_active_low[Bool](info:Pointer[None] tag)
use @gpiod_line_info_is_debounced[Bool](info:Pointer[None] tag)
use @gpiod_line_info_get_debounce_period_us[U64](info:Pointer[None] tag)
use @gpiod_line_info_get_event_clock[I32](info:Pointer[None] tag)

class iso GpioLineInfo
  """
  Functions for retrieving kernel information about both requested and free
  lines.

  Line info object contains an immutable snapshot of a line status.

  The line info contains all the publicly available information about a
  line, which does not include the line value. The line must be requested
  to access the line value.
  """
  let _ctx:Pointer[None] tag

  new iso create(ctx:Pointer[None] tag) =>
    _ctx = ctx

  fun _final() =>
    @gpiod_line_info_free(_ctx)

  fun iso copy(): GpioLineInfo =>
    """
     Copy a line info object.
    """
    GpioLineInfo(@gpiod_line_info_copy(_ctx))

  fun get_offset():U32 =>
    """
      Get the offset of the line.

      The offset uniquely identifies the line on the chip. The combination of the
      chip and offset uniquely identifies the line within the system.
    """
    @gpiod_line_info_get_offset(_ctx)

  fun get_name(): String ref =>
    """
      Get the name of the line.

      @returns Name of the GPIO line as it is represented in the kernel, or "<unnamed>" if the line is unnamed.
    """
    let result:Pointer[U8 val] box = @gpiod_line_info_get_name(_ctx)
    if result.is_null() then "<unnamed>" end
    String.copy_cstring(result)

  fun is_used():Bool =>
    """
    Check if the line is in use.

    @return True if the line is in use, false otherwise.

    The exact reason a line is busy cannot be determined from user space.
    It may have been requested by another process or hogged by the kernel.
    It only matters that the line is used and can not be requested until
    released by the existing consumer.
    """
    @gpiod_line_info_is_used(_ctx)

  fun get_direction(): GpioLineDirection =>
    """
      Get the direction setting of the line.
      @returns Returns ::GPIOD_LINE_DIRECTION_INPUT or ::GPIOD_LINE_DIRECTION_OUTPUT.
    """
    _line_direction(@gpiod_line_info_get_direction(_ctx))

  fun _line_direction(cdata:I32):GpioLineDirection =>
    match cdata
    | 1 => GpioLineDirectionAsIs
    | 2 => GpioLineDirectionInput
    | 3 => GpioLineDirectionOutput
    else
      GpioLineDirectionAsIs
    end

  fun get_edge_detection():GpioLineEdge =>
    """
    Get the edge detection setting of the line.
    @return Returns ::GPIOD_LINE_EDGE_NONE, ::GPIOD_LINE_EDGE_RISING, ::GPIOD_LINE_EDGE_FALLING or ::GPIOD_LINE_EDGE_BOTH.
    """
    _edge_detection(@gpiod_line_info_get_edge_detection(_ctx))

  fun _edge_detection(cdata:I32):GpioLineEdge =>
    match cdata
    | 1 => GpioLineEdgeNone
    | 2 => GpioLineEdgeRising
    | 3 => GpioLineEdgeFalling
    | 4 => GpioLineEdgeBoth
    else
      GpioLineEdgeNone
    end

  fun get_bias():GpioLineBias =>
    """
    Get the bias setting of the line.
    """
    _bias(@gpiod_line_info_get_bias(_ctx))

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


  fun get_drive():GpioLineDrive =>
    """
      Get the drive setting of the line.
    """
    _drive(@gpiod_line_info_get_drive(_ctx))

  fun _drive(cdata:I32):GpioLineDrive =>
    match cdata
    | 1 => GpioLineDrivePushPull
    | 2 => GpioLineDriveOpenDrain
    | 3 => GpioLineDriveOpenSource
    else
      GpioLineDrivePushPull
    end

  fun is_active_low():Bool =>
    """
    Check if the logical value of the line is inverted compared to the physical.
    @return True if the line is "active-low", false otherwise.
    """
    @gpiod_line_info_is_active_low(_ctx)

  fun is_debounced():Bool =>
    """
    Check if the line is debounced (either by hardware or by the kernel
          software debouncer).
    @return True if the line is debounced, false otherwise.
    """
    @gpiod_line_info_is_debounced(_ctx)

  fun debounce_period_us():U64 =>
    """
      Get the debounce period of the line, in microseconds.
      @return Debounce period in microseconds.
              0 if the line is not debounced.
    """
    @gpiod_line_info_get_debounce_period_us(_ctx)

  fun get_event_clock():GpioLineClock =>
    """
    Get the event clock setting used for edge event timestamps for the line.
    """
    _line_clock(@gpiod_line_info_get_event_clock(_ctx))

  fun _line_clock(cdata:I32):GpioLineClock =>
    match cdata
    | 1 => GpioLineClockMonotonic
    | 2 => GpioLineClockRealtime
    | 3 => GpioLineClockHte
    else
      GpioLineClockMonotonic
    end
