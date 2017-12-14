# Wind-Visualization
Matt Bonazzoli and Lawson Busch

A particle visualization of wind vectors over the United States.

Number of Particles: 10000
Particle Lifetime: 200
Step Size: 0.1

If the step size is decreased the particles with appear to move slower, because the step size determines the distance traveled in the direction that the vector is pointing. Likewise, if the step size is increased the particles will appear to move faster, as this means we are traveling farther along the vector for each update.

**NOTE:** For our RK4 integration, we are assuming a linear function for our time input, and assume that the base input is t = 1. This implies that for each t, we will travel the distance of the vector, which is why we simply multiply by the constant, C, attached to T in the RK4 equations when calculating K1, K2, K3, and K4, since the constant should simply change the distance traveled in the vector direction by C times T.
