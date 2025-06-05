
use @gpiod_edge_event_copy[Pointer[None] tag](event:Pointer[None] tag)
use @gpiod_edge_event_get_event_type[I32](event:Pointer[None] tag)
use @gpiod_edge_event_get_timestamp_ns[U64](event:Pointer[None] tag)
use @gpiod_edge_event_get_line_offset[U32](event:Pointer[None] tag)
use @gpiod_edge_event_get_global_seqno[U64](event:Pointer[None] tag)
use @gpiod_edge_event_get_line_seqno[U64](event:Pointer[None] tag)
use @gpiod_edge_event_free[None](event:Pointer[None] tag)

use @gpiod_edge_event_buffer_new[Pointer[None] tag](capacity:U32)
use @gpiod_edge_event_buffer_get_capacity[U32](buffer:Pointer[None] tag)
use @gpiod_edge_event_buffer_free[None](buffer:Pointer[None] tag)
use @gpiod_edge_event_buffer_get_event[Pointer[None] tag](buffer:Pointer[None] tag, index:U32)
use @gpiod_edge_event_buffer_get_num_events[U32](buffer:Pointer[None] tag)


primitive GpioEdgeEventRisingEdge
  fun apply():I32 => 1

primitive GpioEdgeEventFallingEdge
  fun apply():I32 => 2

type GpioEdgeEventType is (GpioEdgeEventRisingEdge | GpioEdgeEventFallingEdge)

class val GpioEdgeEvent
  """
  Functions and data types for handling edge events.

  An edge event object contains information about a single line edge event.
  It contains the event type, timestamp and the offset of the line on which
  the event occurred as well as two sequence numbers (global for all lines
  in the associated request and local for this line only).

  Edge events are stored into an edge-event buffer object to improve
  performance and to limit the number of memory allocations when a large
  number of events are being read.
  """
  let _ctx:Pointer[None] tag

  new iso create(ctx:Pointer[None] tag) =>
    _ctx = ctx

  fun _final() =>
    @gpiod_edge_event_free(_ctx)

  fun iso copy():GpioEdgeEvent ? =>
    """
    Copy the edge event object.

    @return Copy of the edge event or NULL on error. The returned object must
            be freed by the caller using ::gpiod_edge_event_free.
    """
    let result = @gpiod_edge_event_copy(_ctx)
    if result.is_null() then error end
    GpioEdgeEvent(result)

  fun get_event_type(event:Pointer[None] tag): GpioEdgeEventType =>
    """
     Get the event type.
     @param event GPIO edge event.
     @return The event type (::GPIOD_EDGE_EVENT_RISING_EDGE or
             ::GPIOD_EDGE_EVENT_FALLING_EDGE).
    """
    _event_type(@gpiod_edge_event_get_event_type(_ctx))

  fun _event_type(cdata:I32):GpioEdgeEventType =>
    match cdata
    | 1 => GpioEdgeEventRisingEdge
    | 2 => GpioEdgeEventFallingEdge
    else
      GpioEdgeEventRisingEdge
    end

  fun get_timestamp_ns(event:Pointer[None] tag): U64 =>
    """
    Get the timestamp of the event.
    @return Timestamp in nanoseconds.
    NOTE: The source clock for the timestamp depends on the event_clock setting for the line.
    """
    @gpiod_edge_event_get_timestamp_ns(_ctx)

  fun get_line_offset():U32 =>
    """
    Get the offset of the line which triggered the event.
    """
    @gpiod_edge_event_get_line_offset(_ctx)

  fun get_global_seqno():U64 =>
    """
    Get the global sequence number of the event.
    @return Sequence number of the event in the series of events for all lines in the associated line request.
    """
    @gpiod_edge_event_get_global_seqno(_ctx)

  fun get_line_seqno():U64 =>
    """
    Get the event sequence number specific to the line.
    @return Sequence number of the event in the series of events only for this
            line within the lifetime of the associated line request.
    """
    @gpiod_edge_event_get_line_seqno(_ctx)

  fun iso buffer_new(capacity:USize):GpioEdgeEventBuffer ? =>
    """
    Create a new edge event buffer.
    @param capacity Number of events the buffer can store (min = 1, max = 1024).
    @return New edge event buffer or NULL on error.
    @note If capacity equals 0, it will be set to a default value of 64. If
          capacity is larger than 1024, it will be limited to 1024.
    @note The user space buffer is independent of the kernel buffer
          (::gpiod_request_config_set_event_buffer_size). As the user space
          buffer is filled from the kernel buffer, there is no benefit making
          the user space buffer larger than the kernel buffer.
          The default kernel buffer size for each request is (16 * num_lines).
    """
    let result = @gpiod_edge_event_buffer_new(capacity.u32())
    if result.is_null() then error end
    GpioEdgeEventBuffer(result)


class iso GpioEdgeEventBuffer
  let _ctx:Pointer[None] tag

  new iso create(ctx:Pointer[None] tag) =>
    _ctx = ctx

  fun _final() =>
    @gpiod_edge_event_buffer_free(_ctx)

  fun get_capacity():USize =>
    """
    Get the capacity (the max number of events that can be stored) of the event buffer.
    @return The capacity of the buffer.
    """
    USize.from[U32](@gpiod_edge_event_buffer_get_capacity(_ctx))

  fun iso get_event(index:USize):GpioEdgeEvent ? =>
    """
    Get an event stored in the buffer.

    @param index Index of the event in the buffer.
    @return Pointer to an event stored in the buffer. The lifetime of the
            event is tied to the buffer object. Users must not free the event
            returned by this function.
    @warning Thread-safety:
             Since events are tied to the buffer instance, different threads
             may not operate on the buffer and any associated events at the same
             time. Events can be copied using ::gpiod_edge_event_copy in order
             to create a standalone objects - which each may safely be used from
             a different thread concurrently.
    """
    let result = @gpiod_edge_event_buffer_get_event(_ctx, index.u32())
    if result.is_null() then error end
    GpioEdgeEvent(result)

  fun get_num_events(): USize =>
    """
    Get the number of events a buffer has stored.

    @param buffer Edge event buffer.
    @return Number of events stored in the buffer.
    """
    USize.from[U32](@gpiod_edge_event_buffer_get_num_events(_ctx))
