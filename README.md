# vcore3-ratos-config

This is my personal Klipper config for my 400mm Rat Rig V-Core 3.

Current config:

* INDX toolhead
* BTT Octopus v1.1
* INDX eddy sensor

I'm using *parts of* the modular Klipper config in [RatOS](https://os.ratrig.com), and the `config` submodule points to that repository.  I've chosen not to include `config/macros.cfg` in preference to my own, for more control and readability.


https://canbus.esoterical.online/

## INDX toolhead LEDs

| Condition                            | Color/pattern                                                 |
|:-------------------------------------|:--------------------------------------------------------------|
| Heating, more than 1°C below target  | Red, breathing every 2 seconds                                |
| At target or above it                | Solid red                                                     |
| Heater off, nozzle ≥50°C             | Red, breathing every 4 seconds                                |
| Heater off, below 50°C after heating | Blue, breathing every 4 seconds, for approximately 60 seconds |
| Subsequently cold/idle               | Solid green                                                   |

They are exposed as one RGB group, with no separate left/right selection:

```gcode
  # Override automatic status with green
  INDX_LED_FORCE_COLOR RED=0 GREEN=255 BLUE=0

  # Turn them off through an override
  INDX_LED_FORCE_COLOR RED=0 GREEN=0 BLUE=0

  # Restore automatic status
  INDX_LED_FORCE_COLOR CLEAR=1
```

RGB values are 0–255, unlike ordinary Klipper SET_LED values.
