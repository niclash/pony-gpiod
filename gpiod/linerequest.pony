use @gpiod_line_request_get_chip_name[Pointer[U8] val](request:Pointer[None] tag)
use @gpiod_line_request_get_num_requested_lines[U32](request:Pointer[None] tag)
use @gpiod_line_request_get_value[I32](request:Pointer[None] tag, offset:U32)
use @gpiod_line_request_set_value[I32](request:Pointer[None] tag, offset:U32, value:I32)
use @gpiod_line_request_reconfigure_lines[I32](request:Pointer[None] tag, config:Pointer[None] tag)
use @gpiod_line_request_get_fd[I32](request:Pointer[None] tag)
use @gpiod_line_request_wait_edge_events[I32](request:Pointer[None] tag, timeout_ns:U64)
use @gpiod_line_request_read_edge_events[I32](request:Pointer[None] tag, buffer:Pointer[None] tag,max_events:U32)
use @gpiod_line_request_release[None](request:Pointer[None] tag)

use @gpiod_line_request_get_requested_offsets[U32](request:Pointer[None] tag, offsets:Pointer[U32] tag, max_offsets:U32)
use @gpiod_line_request_get_values_subset[U32](request:Pointer[None] tag, num_values:U32, offsets:Pointer[U32] tag, values:Pointer[I32] tag)
use @gpiod_line_request_get_values[U32](request:Pointer[None] tag, values:Pointer[I32] tag)
use @gpiod_line_request_set_values_subset[I32](request:Pointer[None] tag, num_values:U32, offsets:Pointer[U32] tag, values:Pointer[I32] tag)
use @gpiod_line_request_set_values[I32](request:Pointer[None] tag, values:Pointer[I32] tag)


class iso GpioLineRequest
  """
  Functions allowing interactions with requested lines.
  """
  let _ctx: Pointer[None] tag

  new iso create(ctx:Pointer[None] tag) =>
    _ctx = ctx

  fun _final() =>
    @gpiod_line_request_release(_ctx)

  fun get_chip_name():String ref =>
    """
    Get the name of the chip this request was made on.
    @return Name the GPIO chip device. The returned pointer is valid for the
    lifetime of the request object and must not be freed by the caller.
    """
    let result = @gpiod_line_request_get_chip_name(_ctx)
    String.copy_cstring(result)

  fun get_num_requested_lines(): USize =>
    """
    Get the number of lines in the request.
    @return Number of requested lines.
    """
    let result = @gpiod_line_request_get_num_requested_lines(_ctx)
    USize.from[U32](result)

  fun get_requested_offsets(max_offsets:USize):Array[U32] =>
    """
     Get the offsets of the lines in the request.

     @param offsets Array to store offsets.
     @param max_offsets Number of offsets that can be stored in the offsets array.
     @return Number of offsets stored in the offsets array.

     If max_offsets is lower than the number of lines actually requested (this
     value can be retrieved using #get_num_requested_lines,
     then only up to max_lines offsets will be stored in offsets.
    """
    let offsets = Array[U32](max_offsets)
    let fetched = @gpiod_line_request_get_requested_offsets(_ctx, offsets.cpointer(), max_offsets.u32())
    let len = USize.from[U32](fetched)
    let result = Array[U32](len)
    offsets.copy_to(result, 0, 0, len)
    result

  fun get_value(offset:USize): GpioLineValue =>
    """
    Get the value of a single requested line.

    @param offset The offset of the line of which the value should be read.
    """
    let result = @gpiod_line_request_get_value(_ctx, offset.u32())
    _line_value(result)

  fun get_values_subset(offsets:Array[U32]): Array[GpioLineValue] ? =>
    """
    Get the values of a subset of requested lines.
    @param num_values Number of lines for which to read values.
    @param offsets Array of offsets identifying the subset of requested lines
                   from which to read values.
    @param values Array in which the values will be stored. Must be sized
                  to hold \p num_values entries. Each value is associated with
                  the line identified by the corresponding entry in \p offsets.
    @return 0 on success, -1 on failure.
    """
    let len = offsets.size()
    let data = Array[I32](len)
    let fetched = @gpiod_line_request_get_values_subset(_ctx, len.u32(), offsets.cpointer(), data.cpointer())
    let size = USize.from[U32](fetched)
    let result = Array[GpioLineValue]
    var idx:USize = 0
    while idx < size do
      let v = data(idx)?
      result.push(_line_value(v))
      idx = idx + 1
    end
    result

  fun _line_value(cdata:I32):GpioLineValue =>
    match cdata
    | 1 => GpioLineValueError
    | 2 => GpioLineValueInactive
    | 3 => GpioLineValueActive
    else
      GpioLineValueError
    end

  fun get_values():Array[GpioLineValue] ? =>
    """
    Get the values of all requested lines.
    """
    let len = get_num_requested_lines()
    let data = Array[I32](len)
    let fetched = @gpiod_line_request_get_values(_ctx,data.cpointer())
    let size = USize.from[U32](fetched)
    let result = Array[GpioLineValue]
    var idx:USize = 0
    while idx < size do
      let v = data(idx)?
      result.push(_line_value(v))
      idx = idx + 1
    end
    result

  fun set_value(offset:USize,value:GpioLineValue):I32 =>
    """
    Set the value of a single requested line.

    @param offset The offset of the line for which the value should be set.
    @param value Value to set.
    @return 0 on success, -1 on failure.
    """
    @gpiod_line_request_set_value(_ctx,offset.u32(),value())

  fun set_values_subset(offsets':Array[USize],values:Array[GpioLineValue]):I32 =>
    """
    Set the values of a subset of requested lines.

    @param num_values Number of lines for which to set values.
    @param offsets Array of offsets, containing the number of entries specified
                   by \p num_values, identifying the requested lines for
                   which to set values.
    @param values Array of values to set, containing the number of entries
                  specified by num_values. Each value is associated with the
                  line identified by the corresponding entry in offsets.
    @return 0 on success, -1 on failure.
    """
    let set = Array[I32]
    for v in set.values() do
      set.push(v)
    end
    let offsets = Array[U32]
    for off in offsets'.values() do
      offsets.push(off.u32())
    end
    @gpiod_line_request_set_values_subset(_ctx, offsets.size().u32(), offsets.cpointer(), set.cpointer())

  fun set_values(values:Array[GpioLineValue]):I32 =>
    """
    Set the values of all lines associated with a request.

    @param values Array containing the values to set. Must be sized to
                  contain the number of lines filled by
                  #get_num_requested_lines().
                  Each value is associated with the line identified by the
                  corresponding entry in the offset array filled by
                  ::gpiod_line_request_get_requested_offsets.
    @return 0 on success, -1 on failure.
    """
    let set = Array[I32]
    for v in set.values() do
      set.push(v)
    end
    @gpiod_line_request_set_values(_ctx, set.cpointer())

  fun reconfigure_lines(config:GpioLineConfig):I32 =>
    """
    Update the configuration of lines associated with a line request.

    NOTE: The new line configuration completely replaces the old.

    NOTE: Any requested lines without overrides are configured to the requested defaults.

    NOTE: Any configured overrides for lines that have not been requested are silently ignored.

    @param config New line config to apply.
    @return 0 on success, -1 on failure.
    """
    @gpiod_line_request_reconfigure_lines(_ctx, config.cpointer())

  fun get_fd():I32 =>
    """
    Get the file descriptor associated with a line request.

    @param request GPIO line request.
    @return The file descriptor associated with the request.
            This function never fails.
            The returned file descriptor must not be closed by the caller.
    """
    @gpiod_line_request_get_fd(_ctx)

  fun wait_edge_events(timeout_ns:U64):I32 =>
    """
    Wait for edge events on any of the requested lines.

    Lines must have edge detection set for edge events to be emitted.
    By default edge detection is disabled.

    @param timeout_ns Wait time limit in nanoseconds. If set to 0, the function
                      returns immediately. If set to a negative number, the
                      function blocks indefinitely until an event becomes
                      available.
    @return 0 if wait timed out, -1 if an error occurred, 1 if an event is
            pending.
    """
    @gpiod_line_request_wait_edge_events(_ctx,timeout_ns)

  fun read_edge_events(max_events:USize):Array[GpioEdgeEventBuffer] =>
    """
    Read a number of edge events from a line request.

    @note This function will block if no event was queued for the line request.

    @note Any exising events in the buffer are overwritten. This is not an
          append operation.

    @param max_events Maximum number of events to read.
    """
    let buffer = Array[Pointer[None] tag](max_events)
    let success = @gpiod_line_request_read_edge_events(_ctx, buffer.cpointer(), max_events.u32())
    let result = Array[GpioEdgeEventBuffer]
    for e in buffer.values() do
      result.push(GpioEdgeEventBuffer(e))
    end
    result

