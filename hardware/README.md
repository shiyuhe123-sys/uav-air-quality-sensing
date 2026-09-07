# Hardware

This folder contains the public, reconciled record of the aircraft integration. It describes the configuration supported by the current project records and identifies details that still require an exported as-built configuration or physical test evidence.

The current platform is a Tarot 650 Sport quadcopter with a Pixhawk 6C, GPS/compass, ExpressLRS receiver, four-motor propulsion system and a planned particle-sensing payload. The aircraft has not yet completed a physical test flight, and the final sensor mount is still pending.

See:

- [recorded bill of materials](bom.md);
- [wiring and integration record](wiring-and-integration.md);
- [project status](../docs/project-status.md).

The PM08D power-monitor history requires careful wording. Earlier wiring guidance treated it as unsuitable for direct analogue connection to the Pixhawk 6C POWER port. The latest project record reports that the installed setup was configured successfully through DroneCAN. The exact CAN port, cable and exported parameters are not included here, so the repository does not present them as independently verified as-built details.

No photographs are included in this stage because the available source images contain location metadata and do not provide complete public evidence for the installed quantities.
