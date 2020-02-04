# Synthetic Smoke Generation

Matlab source code for the paper:

	A. Genovese, R. Donida Labati, V. Piuri, and F. Scotti, 
    "Virtual environment for synthetic smoke clouds generation", 
    in IEEE International Conference on Virtual Environments, Human-Computer Interfaces and Measurement Systems (VECIMS 2011), 
    Ottawa, Canada, September, 2011, pp. 1-6. ISSN: 1944-9429. 
    [DOI: 10.1109/VECIMS.2011.6053841]
    https://ieeexplore.ieee.org/document/6053841

Project page:
(with example videos)

https://homes.di.unimi.it/genovese/wild/wildfire.htm

Outline:<br/>
![Outline](https://homes.di.unimi.it/genovese/wild/imgs/Picture2small_2.png "Outline")

Citation:

    @INPROCEEDINGS{6053841,
        author={A. {Genovese} and R. {Donida Labati} and V. {Piuri} and F. {Scotti}},
        booktitle={2011 IEEE International Conference on Virtual Environments, Human-Computer Interfaces and Measurement Systems},
        title={Virtual environment for synthetic smoke clouds generation},
        year={2011},
        pages={1-6},
        keywords={image sequences;object detection;smoke;virtual reality;virtual environment;synthetic smoke clouds generation;synthetic wildfire smoke frame sequences;image-based wildfire smoke detection systems;cellular model;adverse environmental conditions;virtual smoke simulation;Mathematical model;Equations;Force;Computational modeling;Lattices;Navier-Stokes equations;Atmospheric modeling;Computer vision;smoke detection;lattice-boltzmann;simulation;virtual environment},
        doi={10.1109/VECIMS.2011.6053841},
        ISSN={1944-9429},
        month={Sep.},}

Main files:

    - launch_smokeSimulation_base.m: main file

Required files:

    - ./vis_base: Base videos on which smoke is simulated
    
The code implements some of the algorithms described in:

    V. N. Vasyukov and A. N. Podovinnikov, 
    "Simulating 2D images of smoke clouds for the purpose of fire detection algorithms adjustment," 
    2008 Third International Forum on Strategic Technologies, Novosibirsk-Tomsk, 2008, pp. 369-370.
    doi: 10.1109/IFOST.2008.4602977
