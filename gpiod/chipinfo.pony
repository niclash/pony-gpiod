
use @gpiod_chip_info_free[None](info:Pointer[None] tag)
use @gpiod_chip_info_get_name[Pointer[U8 val] box](info:Pointer[None] tag)
use @gpiod_chip_info_get_label[Pointer[U8 val] box](info:Pointer[None] tag)
use @gpiod_chip_info_get_num_lines[USize](info:Pointer[None] tag)

class val ChipInfo
  """
  Functions for retrieving kernel information about chips.

  Line info object contains an immutable snapshot of a chip’s status.

  The chip info contains all the publicly available information about a chip.
  """
  let _ctx: Pointer[None] tag

  new val create(ctx:Pointer[None] tag) =>
    _ctx = ctx

  fun _final() =>
    @gpiod_chip_info_free(_ctx)

  fun info_get_name(): String ref =>
    """
    Get the name of the chip as represented in the kernel.
    """
    String.copy_cstring(@gpiod_chip_info_get_name(_ctx))

  fun gpiod_chip_info_get_label(): String ref =>
    """
    Get the label of the chip as represented in the kernel.
    """
    String.copy_cstring(@gpiod_chip_info_get_label(_ctx))

  fun gpiod_chip_info_get_num_lines(): USize =>
    """
    Get the number of lines exposed by the chip.
    """
    @gpiod_chip_info_get_num_lines(_ctx)
