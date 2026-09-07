# Reproducibility

Stage 1 establishes documentation policy only. Executable material will be added and checked during the Simulink packaging stage.

That stage should record:

- MATLAB release and operating system used for the verified run;
- required MATLAB products and any unavailable optional products;
- the canonical model and parameter file;
- exact commands or scripts used to run demonstrations and validation;
- deterministic seeds and acceptance criteria;
- the source of any physical parameter introduced later;
- paths to small, human-readable derived results.

Existing private project records identify MATLAB/Simulink R2024b as the development environment, but this must be verified when the public package is prepared. Existing records also state that the 3-D animation uses core MATLAB graphics rather than Simulink 3D Animation or UAV Toolbox.

Generated `.mat` files are excluded by default because the committed scripts should reproduce them. If a binary result becomes necessary, it should be reviewed, documented and added deliberately.
