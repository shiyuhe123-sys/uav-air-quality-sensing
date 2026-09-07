# Wiring and integration record

This document is a high-level public record of the current aircraft integration. It is not a flight procedure and does not replace the manufacturer manuals, an exported parameter set or a final pre-flight inspection.

## Current architecture

The recorded aircraft combines:

- a Tarot 650 Sport frame and centre plate used for high-current power distribution;
- four DYS D4215 650KV motors and four Hobbywing XRotor Pro 50 A 4–6S OPTO ESCs;
- a Holybro Pixhawk 6C flight controller;
- a Holybro M10 GPS/compass;
- an ExpressLRS receiver;
- a PWM breakout used to route the four motor-control signals; and
- a PM08D power-monitor unit whose final reported integration uses DroneCAN.

The physical aircraft is reported as assembled and wired. It has not yet completed a test flight, and the public repository does not claim that the wiring is flight-validated.

## High-level power path

The recorded high-current architecture is represented at this level as:

```text
6S battery → power-monitor/power-module architecture → Tarot centre-plate PDB
           → four ESCs → four motors
```

The Tarot centre plate is treated as a power-distribution board; it is not itself a substitute for a regulated power-monitor interface. The earlier wiring record correctly warned that the photographed PM08D should not be treated as a direct analogue sensor on a Pixhawk 6C POWER port. The latest project record says that the installed unit was configured successfully through DroneCAN. This public record does not invent the exact CAN port, cable assembly or parameter values; those details require an exported as-built configuration.

## Flight-controller interfaces

The recorded integration connects the Pixhawk to:

- the GPS/compass for navigation and compass data;
- the ExpressLRS receiver for manual/control input;
- the PWM breakout for the four ESC signal and ground pairs; and
- the power-monitor architecture for battery/power information.

The project record reports GPS/compass calibration, radio calibration and pre-arm configuration checks as complete. Exact port-level and parameter-level evidence is not included in this documentation-only release. Do not infer a connector or parameter from a similar-looking cable; use the eventual as-built export for a definitive wiring record.

## Recorded Quad X motor mapping

The current recorded mapping is:

| ArduPilot output | Physical position | Tarot plate label | Recorded rotation viewed from above |
|---:|---|---|---|
| 1 | Front-right | M1 | CCW |
| 2 | Rear-left | M3 | CCW |
| 3 | Front-left | M2 | CW |
| 4 | Rear-right | M4 | CW |

Motor assignment and direction are reported as checked with the propellers removed. This mapping is an integration record, not evidence of a successful airborne test.

## Evidence boundary

The following are not yet public or not yet established:

- final exported power-monitor and flight-controller parameters;
- final payload mount, inlet geometry, mass and centre of gravity;
- installed 12×4.5 propeller current and thermal behaviour;
- vibration, failsafe, hover and endurance behaviour;
- a completed flight test; and
- synchronized sensor data.

The public repository therefore documents the recorded configuration and unresolved evidence rather than presenting a completed airworthiness or measurement-validation claim.
