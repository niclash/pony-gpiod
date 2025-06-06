use @gpiod_info_event_free[None](event:Pointer[None] tag)
use @gpiod_info_event_get_event_type[I32](event:Pointer[None] tag)
use @gpiod_info_event_get_timestamp_ns[U64](event:Pointer[None] tag)
use @gpiod_info_event_get_line_info[Pointer[None] tag](event:Pointer[None] tag)


primitive GpioInfoEventLineRequested
primitive GpioInfoEventLineReleased
primitive GpioInfoEventLineConfigCchanged

type GpioInfoEventType is (GpioInfoEventLineRequested | GpioInfoEventLineReleased | GpioInfoEventLineConfigCchanged)

class val GpioInfoEvent
  """
  Accessors for the info event objects allowing to monitor changes in GPIO
  line status.

  Callers are notified about changes in a line's status due to GPIO uAPI
  calls. Each info event contains information about the event itself
  (timestamp, type) as well as a snapshot of line's status in the form
  of a line-info object.
  """
  let _ctx:Pointer[None] tag

  new val create(ctx:Pointer[None] tag) =>
    _ctx = ctx

  fun _final() =>
    @gpiod_info_event_free(_ctx)

  fun get_event_type():GpioInfoEventType val =>
    """
    Get the event type of the status change event.
    @return One of GpiodInfoEventLineRequested, GpiodInfoEventLineReleased or GpiodInfoEventLineConfigChanged.
    """
    _gpio_info_event_type(@gpiod_info_event_get_event_type(_ctx))

  fun _gpio_info_event_type(cdata:I32):GpioInfoEventType =>
    match cdata
    | 1 => GpioInfoEventLineRequested
    | 2 => GpioInfoEventLineReleased
    | 3 => GpioInfoEventLineConfigCchanged
    else
      GpioInfoEventLineConfigCchanged
    end

  fun get_timestamp_ns():U64 =>
    """
    Get the timestamp of the event.
    @param event Line status watch event.
    @return Timestamp in nanoseconds, read from the monotonic clock.
    """
    @gpiod_info_event_get_timestamp_ns(_ctx)

  fun get_line_info():GpioLineInfo val ? =>
    """
    Get the snapshot of line-info associated with the event.

    @return Returns a pointer to the line-info object associated with the event.
            The object lifetime is tied to the event object, so the pointer must
            be not be freed by the caller.
    @warning Thread-safety:
             Since the line-info object is tied to the event, different threads
             may not operate on the event and line-info at the same time. The
             line-info can be copied using GpioLineInfo.copy() in order to
             create a standalone object - which then may safely be used from a
             different thread concurrently.
    """
    let result = @gpiod_info_event_get_line_info(_ctx)
    if result.is_null() then error end
    GpioLineInfo(result)
