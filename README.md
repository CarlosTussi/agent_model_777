# Agent Based Model Flight Service Simulation

## What is it
- This model has for objective simulate a service delivery in an aircraft. More precisely, the goal is to generate a model to help determine how many cabin crew is necessary for a certain number of passengers in order to provide a satisfactory service for customers.
The results are suppose to help companies draw insights and adapt their service delivery procedues if necessary.

- Live Web Version [here](https://carlostussi.github.io/agent_model_777/)
- Modeling Commons' link [here](http://modelingcommons.org/browse/one_model/7646)
## How it Works

### Overview
The model simulates cabin crew moving along the aisle in the cabin and serving trays (with meals) to PAX. As the time passes,  PAX that have not yet been served become more impatient and possibily unhappy with the service. The PAX are only happy when they have eaten.

The simulation finishes when all the PAX are happy and fed.


For this simulation, the flight is in the following intial state:
  - The plane is in cruise altitude.
  - The PAX are in their assigned seats already.
  - The crew is divided between boths galleys and already ready to start the service.



## How to Use it
1) Open the [live web version](https://carlostussi.github.io/agent_model_777/).
    - Alternatively you can clone this repository and open the agentmodel777.nlogo file using [NetLogo](https://ccl.northwestern.edu/netlogo/)
2) Click **setup** button after selecting the parameters for the simulation.
3) Click **go** to run the simulation.

Parameter Selection

- **total-crew**: You can select the total number of cabin crew by adjusting the "total-crew" sliding bar.

- **total-pax:** You can select the total number of pax by adjusting the "total-pax" sliding bar.

- **patience-add-randomness:** You can select the added randomness value to the patience level.

- **patience-level:** You can determine the patience level by selecting an option from the drop down box "patience-level".


 *OBS: This model is still under construction and improvements and updates are made frequently.* 
