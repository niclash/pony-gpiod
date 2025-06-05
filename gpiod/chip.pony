
use "lib:gpiod"
use @gpiod_chip_open[Pointer[None] tag](path:Pointer[U8 val] tag)
use @gpiod_chip_close[None](chip:Pointer[None] tag)
use @gpiod_chip_get_info[Pointer[None] tag](chip:Pointer[None] tag)
use @gpiod_chip_get_path[Pointer[U8 val] val](chip:Pointer[None] tag)
use @gpiod_chip_get_lineinfo[Pointer[None] val](chip:Pointer[None] tag, offset:U32)
use @gpiod_chip_watch_lineinfo[Pointer[None] val](chip:Pointer[None] tag, offset:U32)
use @gpiod_chip_unwatch_lineinfo[I32 val](chip:Pointer[None] tag, offset:U32)
use @gpiod_chip_get_fd[I32 val](chip:Pointer[None] tag)
use @gpiod_chip_wait_info_event[I32 val](chip:Pointer[None] tag, timeout:I64)
use @gpiod_chip_read_info_event[Pointer[None] val](chip:Pointer[None] tag)
use @gpiod_chip_get_line_offset_from_name[I32 val](chip:Pointer[None] tag, name:Pointer[U8 val] tag)
use @gpiod_chip_request_lines[Pointer[None]](chip:Pointer[None] tag, req_cfg:Pointer[None], line_cfg:Pointer[None] )

class val GpioChip
  """
  Functions and data structures for GPIO chip operations.

  A GPIO chip object is associated with an open file descriptor to the GPIO character device.
  It exposes basic information about the chip and allows callers to retrieve information about each line,
  watch lines for state changes and make line requests.

  https://libgpiod.readthedocs.io/en/latest/core_chips.html
  """
  let _ctx:Pointer[None] tag

  new create(path:String)? =>
    """
    Open a chip by path.

    @param path – Path to the gpiochip device file.
    @returns GPIO chip object or NULL if an error occurred. The returned object must be closed by the caller using gpiod_chip_close.
    """
    let result = @gpiod_chip_open(path.cstring())
    if result.is_null() then error end
    _ctx = result

  fun _final() =>
  """
  Close the chip and release all associated resources.

  This is called upon garbage collection of this class instance.
  """
    @gpiod_chip_close(_ctx)

  fun get_info():ChipInfo val ? =>
    """
    Get information about the chip.
    """
    let result = @gpiod_chip_get_info(_ctx)
    if result.is_null() then error end
    ChipInfo(result)

  fun get_path():String val =>
    """
    Get the path used to open the chip.
    """
    let result = @gpiod_chip_get_path(_ctx)
    recover val String.copy_cstring(result) end

  fun get_lineinfo(offset:U32):GpioLineInfo val ? =>
    """
    Get a snapshot of information about a line.
    """
    let result = @gpiod_chip_get_lineinfo(_ctx, offset)
    if result.is_null() then error end
    recover val GpioLineInfo(result) end

  fun watch_lineinfo(offset:U32):GpioLineInfo val ? =>
    """
    Get a snapshot of the status of a line and start watching it for future changes.

    NOTE: Line status does not include the line value. To monitor the line value the line must be requested as
    an input with edge detection set.

    @param offset The offset of the GPIO line.
    """
    let result = @gpiod_chip_watch_lineinfo(_ctx, offset)
    if result.is_null() then error end
    recover val GpioLineInfo(result) end

  fun unwatch_lineinfo(offset:U32):I32 =>
    """
    Stop watching a line for status changes.

    @returns 0 on success, -1 on failure.
    """
    @gpiod_chip_unwatch_lineinfo(_ctx, offset)

  fun get_fd():I32 val =>
    """
    Get the file descriptor associated with the chip.

    This function never fails. The returned file descriptor must not be closed by the caller.
    """
    @gpiod_chip_get_fd(_ctx)

  fun wait_info_event(timeout_ns:I64):I32 val =>
    """
    Wait for line status change events on any of the watched lines on the chip.

    @param timeout_ns – Wait time limit in nanoseconds. If set to 0, the function returns immediately.
    If set to a negative number, the function blocks indefinitely until an event becomes available.

    @returns 0 if wait timed out, -1 if an error occurred, 1 if an event is pending.
    """
    @gpiod_chip_wait_info_event(_ctx, timeout_ns)

  fun read_info_event():GpioInfoEvent val ? =>
    """
    Read a single line status change event from the chip.

    NOTE: If no events are pending, this function will block.
    """
    let result = @gpiod_chip_read_info_event(_ctx)
    if result.is_null() then error end
    recover val GpioInfoEvent(result) end

  fun get_line_offset_from_name(name:String):I32 val ? =>
    """
    Map a line’s name to its offset within the chip.

    NOTE: If a line with given name is not exposed by the chip, the function throws an error

    @param name Name of the GPIO line to map.
    @returns Offset of the line within the chip or -1 on error.
    """
    let result = @gpiod_chip_get_line_offset_from_name(_ctx, name.cstring())
    if result == -1 then error end
    result

  fun request_lines(req_cfg:GpioRequestConfig, line_cfg:GpioLineConfig):GpioLineRequest val ? =>
    """
    Request a set of lines for exclusive usage.

    @param req_cfg Request config object. Can be NULL for default settings.

    @param line_cfg Line config object.

    @returns New line request object.
    """
    let result = @gpiod_chip_request_lines(_ctx, req_cfg.cpointer(), line_cfg.cpointer())
    if result.is_null() then error end
    recover val GpioLineRequest(result) end
