# Aircraft and payload design rationale

This page records the reasoning behind the current architecture. It is a design record, not evidence of flight performance, payload accuracy or final airworthiness.

## Payload-driven aircraft choice

The Tarot 650 Sport quadcopter was selected as a practical four-motor platform with space for a flight controller, power-monitor interface and a future particle-sensing payload. The 6S propulsion configuration and open centre-plate layout provide a maintainable starting point for integrating the mount, inlet and wiring. This is a payload-driven design rationale, not a measured claim about lift margin, endurance or vibration performance. Those quantities must be checked after the final payload is installed.

## Separate propulsion distribution and flight-controller interfaces

The high-current propulsion path and the flight-controller interfaces have different roles:

- the battery feeds the Holybro PM08-CAN and the Tarot integrated power-distribution board (PDB);
- the PDB distributes propulsion power to the four ESCs and motors;
- the PM08-CAN harness provides the confirmed CAN and power interfaces to the Pixhawk 6C; and
- the Pixhawk sends PWM motor-control signals through the recorded breakout to the ESC signal inputs.

This arrangement keeps propulsion distribution, battery monitoring and flight-control signalling explicit in the system record. The exact installed connector pinout and exported parameters are still an as-built evidence item; they should not be inferred from the diagram alone.

## Payload power and logging decisions

The final sensor and inlet have not yet been selected. Where the selected instrument requires a separate supply, the intended design approach is to provide a separate payload-power path rather than assume that the flight-controller supply can power every payload configuration. Voltage, current capacity, protection and grounding must be selected from the instrument datasheet and verified on the bench.

A separate payload logger is also conditional. First establish whether the selected sensor can provide the required data rate, units and timestamps through the planned logging path. Add an independent logger only if it is needed for storage capacity, timing, electrical isolation or a required measurement channel. No particular logger is claimed as installed in the current public record.

## Candidate sensors are not selected sensors

Sensor models mentioned in private notes or earlier planning are historical candidates unless the current BOM and project status identify one as selected. A candidate does not establish the final particle-size channels, PM values, power demand, mass, inlet geometry or calibration method. Those fields become reportable only after the instrument is chosen and bench-checked.

See the [BOM](bom.md), [wiring and integration record](wiring-and-integration.md), and [planned methodology](../research/methodology.md) for the current configuration and evidence gates.
