# HolmarcOML-Gantry-MATLABControl
MATLAB Code to control the GTNDT 500, a 3-Axis gantry, manufactured by Holmarc Opto-Mechatronics Ltd.  

*May be used to control other gantry models with code modifications. This has not been tested or verified*  

This software is not officially licensed from Holmarc Opto-Mechatronics Ltd.  
Please cite properly if used for published work.

### Code contains **2 main functions**.  
*gantryspeed* function sets the gantry movement speed settings.  
*gantrymove* function moves the gantry based on input parameters.  
Additional information on input and output parameters have been described in detail in the respective program files.  

Other functions have been written to enable ease of communication.  

### How to use them
Add the m files to the path to allow MATLAB to access the functions in your program.  
Alternatively copy them to the top of your program file.   

### Notes
Acceleration and Decelaration functionality is limited. Edits and suggestions are welcome.   
The gantry does not provide current live location. Movement instruction to exceed gantry limits will lead to the gantry to crash into the limiter switch.  
It is possible to track gantry live location using a counter variable. This functionality has not been added. Edits and suggestions are welcome.   
In case of no response from the gantry, generally the gantry is waiting for a response from the user from a previous instruction. Turn the gantry on and off again to fix this.   
