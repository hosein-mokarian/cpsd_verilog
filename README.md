# Chaotic Phase Space Differential (CPSD) Implementation in Verilog


The Chaotic Phase Space Differential (CPSD) algorithm has been developed to continuously detect critical cardiac conditions (i.e. VF, VT)based on the time-delayed phase space reconstruction method. Further, the CPSD algorithm can also distinguish other abnormal cardiovascular sign such as PVC according to the extracted feature from the ECG signal.

In training mode, the algorithm finds a steady ECG window of length W seconds as the reference. And in testing mode, it compares the current signal with the reference to obtain the index of variation. The signal s(t) in the window

	W(tcurrent) = {ti | t ∈ [tcurrent − W + d, tcurrent]}
		where d is the time delay used to form phase space vector.

 1. Construct the phase vectors

	The phase space vector v is obtained by the delayed signal pairs. 

		v(ti) = s(ti − d),s(ti), ti ∈ W(tcurrent)
	
 2. Quantize the phase vector
 
	Quantize each dimension of the vector into L levels based on M to get.
	
		v∗(ti). v∗(ti) = (s(ti − d) + M)L + M / 2M , (s(ti) + M)L + M / 2M
		 ti ∈ W(tcurrent)
		 where M = max(|s(ti)|), ti ∈ W(treference) is the maximum absolute value in the reference window.
	Note that signal in current window is saturated into [−M, M] after a valid reference has been found.

 3. Construct the phase space matrix (PSM)
 
	 A two-dimensional PSM, SM, can be constructed from the normalized ECG signal segment, v∗(n), with delay index, d. The number of visited-times on the SM with coordinate of (v∗(n), v∗(n + d)) is counted by Eq. 4 from 0 to N − d where N is the total number of samples in window W. 
 
		 SM[v∗(nx), v∗(nx + d)] = SM[v∗(nx), v∗(nx+d)]+1, for nx = 0 to N − d (4) where SM[ ] 

	represents the intensity matrix of accumulated visited number on the SM. Following the presentation of the basic method for constructing PSM, the constructed reference template, Reference Phase Space Matrix (RPSM), the experimental segments, and Experimental Phase Space Matrix (EPSM) are used to calculate the CPSD value in later section.

 4. Compute the difference phase space matrix

	Because the CPSD algorithm focuses on the spatial-temporal changes of PSM, we use the absolute values of the differential matrix, DPSM, between EPSM and RPSM to calculate the complexity value (CV) according to Eqs. 5 and 6. The complexity value (CV) of DPSM is defined as the number of all array elements that exceed zero.
	
		SDPSM[x, y] = |SEPSM[x, y] − SRPSM[x, y]|,
			 for x, y = 0 to N
		 CV = (CV + 1) if (SDPSM[x, y]! = 0) otherwise CV, 
			 for x, y = 0 to N
		
 5. Compute the CPSD value

	The first CV of each ECG segment is adopted as a normalization factor in determining the subsequent CV to obtain the final CPSD values, as calculated by Eq. 7, which minimize the possible intra- and inter-patient variations. Self-normalization of each individual’s normal ECG patterns enables the establishment of a normal range of baseline CPSD values. 
	
		CPSDn = CVn / CV1 , 
			where n ≥ 1

### Reference phase space matrix

In the above steps, the algorithm requires a reference phase space matrix that is suitable for each individual. The algorithm adaptively generates a reference phase space matrix during each trial instead of deriving it from databases. In the training stage, a candidate phase space matrix corresponding to signal in W(tcandidate) is constructed, and is then compared to a checking phase space matrix corresponding to signal in W(tcandidate+1). If the difference satisfies

	Dif f(PSMcandidate+1, PSMcandidate) < Thresholdvalid h

the candidate phase space matrix becomes a valid reference phase matrix, and remains its value throughout testing stage. If the candidate fails the test, the signal in the next window would serve as the candidate. The reference is updated in a period of 30 s to track the variation of the reference signal. Generally, the training stage takes 8–9 s upon started for finding a proper reference PSM. The reference signal collected and validated in realtime makes the algorithm adapted to each individual during each trial.

### Simple Numerical Example

A simplified example is given according to the above mentioned procedures. Assume an input sequence after digitized by ADC is given as follows:

	Sin = [9 16 28 33 25 17 10 19 26 35 27 16 9 18 24 32 25 18 8 23]

If the time delay parameter d is assigned as, for example, 5, the space vectors are generated as follows:

	v0 = (9, 17); v1 = (16, 10); v2 = (28, 19); v3 = (33, 26); 
	v4 = (25, 35); v5 = (17, 27); v6 = (10, 16); v7 = (19, 9); 
	v8 = (26, 18); v9 = (35, 24); v10 = (27, 32); v11 = (16, 25); 
	v12 = (9, 18); v13 = (18, 8); v14 = (24, 23);

M equals to 35 which is the maximum absolute value of vector Sin. Select quantized level L = 6, space vectors are quantized as:

	v0q = (4, 4); v1q = (4, 4); v2q = (5, 5); v3q = (6, 5); 
	v4q = (5, 6); v5q = (4, 5); v6q = (4, 4); v7q = (5, 4); 
	v8q = (5, 5); v9q = (6, 5); v10q = (5, 6); v11q = (4, 5); 
	v12q = (4, 5); v13q = (5, 4); v14q = (5, 5);

The quantized vectors are the elements of phase space matrix. Plot of the occurrence count of quantized vectors in matrix could be illustrated in Fig. 2b. If RPSM and EPSM are got as Fig. 2a and b, the difference of the two matrix will be Fig. 2c. The resulting DPSM contains zero and non-zero terms. CV value is calculated as follows:

	CV = 6 (non − zero term number)

A reference DPSM value is selected according to Eq. 8 as CV1. Assuming here the CV1 from reference DPSM is 2, the final CPSD value is calculated as follows: 

	CPSDn = CVn CV1 = 6 / 2 = 3

### Overall Structure

Fig.1 shows the whole system. The ECG signals is sampled by a SAR ADC and then use Pan-Tompkins algorithm to detect QRS complexes. It helps to make segments of the ECG signal. The shift register is used to align input signals with *qrs* signal. The *space vectors* block shift the signal based on *d* value to make a delay and create a vector with current value and delayed value. The *Quantized* block calculates a normalize value of space vector. The normalization formula needs a maxium value of input signal which is provided by PEAKF. PEAKF is the maxium value of bandpass filter of Pan-Tompkins algorithm. The quantized signal is always between 0 and L. These blocks are always running to make normalized space vector. This vector is used to calculate CPSD value.
As it is said it is needed to have a reference PSM (RPSM). It is better to obtine it as a real time task. So, threre is two phases: training and test. The control unit block is responsible to manage the whole process. It goes to *START* state after reseting. In this state a timer is triggered to count 8s. Then it goes to *TRAINING* state.
The training phase is used to find a *RPSM*. The recieved quantized vector is counted based on its value and create Current PSM (CPSM) and calculates the difference of Previuos PSM and Current PSM. . At the end of the segment (*qrs = 1*), the CPSM is accepted as the RPSM if the *diff* is less than the *THRH*. This state takes 8 seconds. when the timer overflows, it goes to *TEST* state.
In the *TEST* state, it cosistantly calculates the difference of Experienced PSM (EPSM) and Reference PSM (RPSM) called *DPSM*. The amount pf non-zero membrs of *DPSM* is the nth complexity value (*CVn*). The first calculated of *CVn* in this state is considered as *CV1*. The *CPSD* valu is *CVn*/*CV1*.
A two level thresholding tecnique is used to detect normal, AF or VF sattes of ECG signals. The value of *THR1* and *THR12* are selected based on analyzing lots of EVG signals.

### Digital Impelemntation

The SAR ADC and Pan-Tompkins algorithm is not inplemented here. The *qrs* and *PEAKF* are generated by the testbench. All other blocks are implements in this verilog code. Fig.2 shows the digital impelemntation of calculating *CPSM*, *Previous CPSM*, *RPSM*, *EPSM* and *DPSM* as well as calculatinf *CV1*, *CVn* and *CPSD*.

A more detailed looking at to Fig.1 shows the procduare of *LERNING* and *TEST* state are very similar. Both of the calculate a DPSM from two PSMs. The only difference is that how ther analyze the DFSM. So, a same datapath with an EN signal can be used. The memA is as Previous PSM in the *LEARNING* state and as RPSM in the *Test* state. Also the memB is considered as CPSM in *LEARNING* state and EPSM in *TEST* state. The *EN* signal determines which analyzing block works: *Finding RPSM* or *Non-Zero Members*.
When a valid RPSM is found the shiftA of memA is asserted to shift the values of memB to memA. After that it memA is used as *RPSM*. All RAM blocks read data of input address (*A*) as a combinational circuit. The write transaction is done on rising edge of *clk*. The memB and DPSM are cleared when *qrs* is one. 

Calculating the non-zero memebrs or number of members of *DPSM* which are greater than *THRH* are a little bit challenging. They have to be calculated at the end of each segment (*qrs = 1*), but it degrades down the performance. So. a real-time method is used. In each *clk*, the state of *DPSM* and *DPSM_Next* is checked to find what the next change of DSPM's memebers is. It helps to have a prepared value at the end of the each segment.

This Imelemtation takes advantages of being real-time and reused memory resources to reduce cost and area as well as increase the speed of calculation.

### Chip Impelemtation

The Openlane2 is used to make a GDS file of the design. It is a free and open-source tools supported by efabless. fig.3 shows the final layout in Klayout.
