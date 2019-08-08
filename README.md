# DSSA_Practicum
DSSA 5302 Data Practicum project

William Albert
Summer 2019

This my final project for the Master of Science in Data Science and Stategic Analytics program at Stockton University. My goal was to use an artificial neural network to identify students who were likely to leave the University before graduating.

### Data
The initial sample was all students who were invited to attend new student orientation in Summer of 2015; both first-time freshmen and transfers.  This would ensure that new students would have had a full four years to graduate by the time of analysis.  The final sample contained 1,295 students.

Data was cleaned and reformatted using R and the Tidyverse library.  Neural network was constructed using Keras and Tensorflow in Python 3.

#### Six input variables were used:
- Highest grade earned, Fall 2015
- Lowest grade earned, Fall 2015
- Highest grade earned, Spring 2016
- Lowest grade earned, Spring 2016
- Number of "W" grades (withdrawals), both terms combined
- Number of transfer credits

#### And three output variables (all binary):
- Whether or not a student had graduated in four years
- Whether or not a student was still considered active
- Whether or not a student left the university before graduating

Prior to running the neural network, data were adjusted to range from 0 to 1.  Grade variables were divided by 4 (maximum value; A), number of withdrawals was divided by total courses taken in both terms, and transfer credits was divided by 96, the maximum allowed.

#### Neural Network
A sequential neural network was set up in Python using Keras:
- Input layer for six variables
- hidden layer with 18 neurons; RELU activation
- hidden layer with 9 neurons; RELU activation
- output layer with 3 neurons for output variables

The model used a Binary Crossentropy loss function, with a learning rate of 0.01, and was run for 5000 epochs.

Results were mixed but not as desired.
