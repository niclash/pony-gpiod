
use @gpiod_is_gpiochip_device[Bool](path:Pointer[U8] tag)
use @gpiod_api_version[Pointer[U8] val]()

primitive Gpio
  """
  Various libgpiod-related functions.
  """
  fun isGpioChipDevice(path:String) =>
    """
     Check if the file pointed to by path is a GPIO chip character device.
     @param path Path to check.
     @return True if the file exists and is either a GPIO chip character device
             or a symbolic link to one.
    """
    @gpiod_is_gpiochip_device(path.cstring())

  fun api_version(): String ref =>
    """
    Get the API version of the library as a human-readable string.
    @return A valid pointer to a human-readable string containing the library
            version. The pointer is valid for the lifetime of the program and
            must not be freed by the caller.
    """
    String.copy_cstring(@gpiod_api_version())
