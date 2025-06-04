
primitive GpioLineValueError
  fun apply():I32 => -1

primitive GpioLineValueInactive
  fun apply():I32 => 0

primitive GpioLineValueActive
  fun apply():I32 => 1

type GpioLineValue is (GpioLineValueError | GpioLineValueInactive | GpioLineValueActive)

primitive GpioLineDirectionAsIs
  fun apply():I32 => 1
  
primitive GpioLineDirectionInput
  fun apply():I32 => 2

primitive GpioLineDirectionOutput
  fun apply():I32 => 3

type GpioLineDirection is (GpioLineDirectionAsIs | GpioLineDirectionInput | GpioLineDirectionOutput)

primitive GpioLineEdgeNone
  fun apply():I32 => 1

primitive GpioLineEdgeRising
  fun apply():I32 => 2

primitive GpioLineEdgeFalling
  fun apply():I32 => 3

primitive GpioLineEdgeBoth
  fun apply():I32 => 4

type GpioLineEdge is (GpioLineEdgeNone | GpioLineEdgeRising | GpioLineEdgeFalling | GpioLineEdgeBoth)

primitive GpioLineBiasAsIs
  fun apply():I32 => 1

primitive GpioLineBiasUnknown
  fun apply():I32 => 2

primitive GpioLineBiasDisabled
  fun apply():I32 => 3

primitive GpioLineBiasPullUp
  fun apply():I32 => 4

primitive GpioLineBiasPullDown
  fun apply():I32 => 5

type GpioLineBias is (GpioLineBiasAsIs | GpioLineBiasUnknown | GpioLineBiasDisabled | GpioLineBiasPullUp |GpioLineBiasPullDown)

primitive GpioLineDrivePushPull
  fun apply():I32 => 1

primitive GpioLineDriveOpenDrain
  fun apply():I32 => 2

primitive GpioLineDriveOpenSource
  fun apply():I32 => 3

type GpioLineDrive is (GpioLineDrivePushPull | GpioLineDriveOpenDrain | GpioLineDriveOpenSource)

primitive GpioLineClockMonotonic
  fun apply():I32 => 1

primitive GpioLineClockRealtime
  fun apply():I32 => 2

primitive GpioLineClockHte
  fun apply():I32 => 3

type GpioLineClock is (GpioLineClockMonotonic | GpioLineClockRealtime | GpioLineClockHte)