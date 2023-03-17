## Stimuli

- **ovals_coherent_trig.m**

	Stimulus presentation script with capture trigger
  
- **ovals_coherent.m** 

	Use this script to check the appearance of the random dot stimulus in ovals_coherent_trig.m 
  
- **loomstim_trig.m**
	
	Stimulus presentation script with capture trigger
  
- **loomstim.m**
 	
	Use this script to check the appearance of the looming stimulus in loomstim_trig.m
  
- **triggertest.m** 
	
	Use this script for troubleshooting if you encounter issues with the trigger not initiating capture in ThorImage


## Analysis

- **readstimframes_manual.m**

	Match frame timings with given stimulus timings
  
- **plotframetimes_manual.m**

	Plot given stim timings onto suite2p response trace

- **readstimframes_ribbit.m**
	
	Match frame timings with stimulus timings (compatible with data files generated by loomstim_trig.m and ovals_coherent_trig.m after 2023.3.6)
	

## Utilities

### Screen calibration

Obtain on screen coordinates for use in stimulus scripts

- **rectcoords.m**

	Run the script to display a rectangle on the screen. Use arrow keys to move the rectangle. Press C to display coordinates of the top left and bottom right corner in command line. Press ESC to exit the script.
	
- **corners.m**

	Displays a rectangle.
	
	Set xlim and ylim in the code to adjust the size/position of the rectangle.

