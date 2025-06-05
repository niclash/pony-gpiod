
use @gpiod_request_config_new[Pointer[None] tag]()
use @gpiod_request_config_free[None](cfg:Pointer[None] tag)
use @gpiod_request_config_set_consumer[None](cfg:Pointer[None] tag, consumer:Pointer[U8 val] tag)
use @gpiod_request_config_get_consumer[Pointer[U8 val] box](cfg:Pointer[None] tag)
use @gpiod_request_config_set_event_buffer_size[None](cfg:Pointer[None] tag, event_buffer_size:I32)
use @gpiod_request_config_get_event_buffer_size[I32](cfg:Pointer[None] tag)

class iso GpioRequestConfig
  """
  Functions for manipulating request configuration objects.

  Request config objects are used to pass a set of options to the kernel at the time of the line request.
  The mutators don’t return error values. If the values are invalid, in general they are silently adjusted
  to acceptable ranges.

  https://libgpiod.readthedocs.io/en/latest/core_request_config.html
  """
  let _ctx:Pointer[None] tag

  new create() ? =>
    let result = @gpiod_request_config_new()
    if result.is_null() then error end
    _ctx = result

  fun _final() =>
    @gpiod_request_config_free(_ctx)

  fun set_consumer(consumer:String) =>
    """
    Set the consumer name for the request.

    NOTE: If the consumer string is too long, it will be truncated to the max accepted length.
    """
    @gpiod_request_config_set_consumer(_ctx, consumer.cstring())

  fun get_consumer():String ref =>
    """
    Get the consumer name configured in the request config.
    """
    let result = @gpiod_request_config_get_consumer(_ctx)
    String.copy_cstring(result)

  fun set_event_buffer_size(size:USize) =>
    """
    Set the size of the kernel event buffer for the request.

    NOTE: The kernel may adjust the value if it’s too high. If set to 0, the default value will be used.

    NOTE: The kernel buffer is distinct from and independent of the user space buffer (gpiod_edge_event_buffer_new).
    """
    @gpiod_request_config_set_event_buffer_size(_ctx,size.i32())

  fun get_event_buffer_size():USize =>
    """
    Get the edge event buffer size for the request config.
    """
    USize.from[I32](@gpiod_request_config_get_event_buffer_size(_ctx))

  fun cpointer(): Pointer[None] tag =>
    _ctx