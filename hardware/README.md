# Hardware

This folder contains the public, reconciled record of the aircraft integration. It describes the configuration supported by the current project records and identifies details that still require an exported as-built configuration or physical test evidence.

The current platform is a Tarot 650 Sport quadcopter with a Pixhawk 6C, GPS/compass, ExpressLRS receiver, four-motor propulsion system and a planned particle-sensing payload. The aircraft has not yet completed a physical test flight, and the final sensor mount is still pending.

See:

- [recorded bill of materials](bom.md);
- [wiring and integration record](wiring-and-integration.md);
- [aircraft and payload design rationale](design-rationale.md);
- [project status](../docs/project-status.md).

The current power module is the Holybro PM08-CAN, specified for 2–14S operation and 200 A continuous current by the manufacturer. The current as-built description says its six-pin Power & CAN interface branches to two Pixhawk 6C interfaces: one CAN port and one power port. Exact Pixhawk port numbers, cable pinout and exported parameters are not included here, so the repository does not present those details as independently verified.

The [wiring record](wiring-and-integration.md) shows the high-current propulsion path separately from the CAN, power and PWM signal paths. It is a documentation diagram, not a substitute for the manufacturer manuals or a pre-energisation inspection.

No photographs are included in this stage because the available source images contain location metadata and do not provide complete public evidence for the installed quantities.
