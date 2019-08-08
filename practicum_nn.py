#Building the neural network

# Import necessary libraries
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
from keras.constraints import maxnorm
from keras.callbacks import ModelCheckpoint
from keras.models import model_from_json
from keras import optimizers
import numpy as np
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt

# set random seed for reproducibility
np.random.seed(53)

# load dataset
dataset = np.loadtxt("data_for_nn.csv", delimiter=",", skiprows=1)

# split into input (X) and output (Y) variables
X = dataset[:,1:7] #input features
Y = dataset[:,7:10] #output targets
# split again into train and test sets
X_train, X_test, Y_train, Y_test = train_test_split(X,Y,shuffle=False)

print('begin...')

# create sequential model
model1 = Sequential()
#add a hidden layer with 12 neurons that takes 6 input values
#and uses a RELU activation function
model1.add(Dense(18,input_dim=6,kernel_initializer='normal',activation='relu'))
#add second hidden layer with 9 neruons using RELU function
model1.add(Dense(9,kernel_initializer='normal',activation='relu'))
#output layer with 3 neurons
model1.add(Dense(3,kernel_initializer='normal',activation='sigmoid'))

# Compile model
#set learning rate
learning_rate=0.01
#define optimizer using "adam" with set learning rate
adam = optimizers.Adam(lr=learning_rate)

print('compile...')

#compile using Binary Cross-entropy loss function and adam optimizer
#output accuracy metric
model1.compile(loss='binary_crossentropy',optimizer=adam,metrics=['accuracy'])

# Save model to disk ############
# Save model structure as json
print('===================')
print('Saving model to disk')
print('===================')
model_json1 = model1.to_json()
with open('model.json', 'w') as json_file:
    json_file.write(model_json1)
#################################    
    
# Set up checkpointing

filepath = 'weights.best.hdh5'
checkpoint = ModelCheckpoint(filepath,monitor='val_acc',verbose=0,save_best_only=True,mode='max')
callbacks_list = [checkpoint]

print('fit...')

history1=model1.fit(X_train,Y_train,validation_split=0.333,epochs=5000,verbose=0,callbacks=callbacks_list)

# Evaluate the model
scores1 = model1.evaluate(X_train, Y_train)
Y_predict1 = model1.predict(X_test)

print("\n%s: %.2f%%" % (model1.metrics_names[1], scores1[1]*100))

# leave early
# create confusion matrix details
inactive=Y_test[:,0]
inactive_pred=Y_predict1[:,0]
rounded = [round(i) for i in inactive_pred]
y_pred = np.array(rounded,dtype='int64')
print('Confusion Matrix')
print('================')
CM = confusion_matrix(inactive, y_pred)
print('True negatives: ',CM[0,0])
print('False negatives: ',CM[1,0])
print('False positives: ',CM[0,1])
print('True positives: ',CM[1,1])

#plot predictions for "left early"
#reformat predicted values to a list, subtract from 
#observed Y, and calculate squared difference to 
#show accuracy of each prediction
y1 = [i for i in inactive_pred]
diff=inactive-y1
sqdiff = [i**2 for i in diff]
#combine squared difference, predicted Y, and observed Y 
#to a single array to plot more efficiently
sqdiff = np.asarray(sqdiff)
y1 = np.asarray(y1)
data1 = np.vstack((inactive,y1,sqdiff))

#create scatter plots for observed vs predicted values,
#with squared differences determining color and marker size

#set figure size
plt.figure(figsize=(10,3)) 
#scatterplot for observed vs predicted values
#with color defined by squared difference
#and size defined by squared difference subtracted from 1
#so that the more accurate markers are larger
plt.scatter(data1[1], data1[0], c = data1[2], s=((1-data1[2])*1000), marker="|") 
plt.title("Observed vs Predicted Values - Left Early",fontsize=16)
plt.ylabel("Observed Value",fontsize=14)
plt.xlabel("Predicted Value",fontsize=14)
#add text to display current learning rate
plt.text(0.2,0.5,'Epochs = 5000; Learning Rate = %s' % learning_rate, fontsize=14)
#set the color palette
plt.set_cmap('jet_r') # "_r to reverse the order"
#add color bar
cbar=plt.colorbar()
#label the color bar definition of our new accuracy calculation
cbar.set_label('Squared Error ((Y - Y predicted)**2)') 
#set y axis to only show 0 and 1 for observed values
plt.yticks(range(0,2,1), fontsize=14)
plt.xticks(fontsize=14)
#add axes to remove top and right
lines = plt.axes()
lines.spines["top"].set_visible(False)     
lines.spines["right"].set_visible(False)
plt.sca(lines) #adds axes to current figure

plt.show()

# graduate
# create confusion matrix details
graduated=Y_test[:,2]
grad_pred=Y_predict1[:,2]
rounded = [round(i) for i in grad_pred]
y_pred = np.array(rounded,dtype='int64')
print('Confusion Matrix')
print('================')
CM = confusion_matrix(graduated, y_pred)
print('True negatives: ',CM[0,0])
print('False negatives: ',CM[1,0])
print('False positives: ',CM[0,1])
print('True positives: ',CM[1,1])

#plot predictions for "graduated"
#reformat predicted values to a list, subtract from 
#observed Y, and calculate squared difference to 
#show accuracy of each prediction
y1 = [i for i in grad_pred]
diff=graduated-y1
sqdiff = [i**2 for i in diff]
#combine squared difference, predicted Y, and observed Y 
#to a single array to plot more efficiently
sqdiff = np.asarray(sqdiff)
y1 = np.asarray(y1)
data1 = np.vstack((graduated,y1,sqdiff))

#create scatter plots for observed vs predicted values,
#with squared differences determining color and marker size

#set figure size
plt.figure(figsize=(10,3)) 
#scatterplot for observed vs predicted values
#with color defined by squared difference
#and size defined by squared difference subtracted from 1
#so that the more accurate markers are larger
plt.scatter(data1[1], data1[0], c = data1[2], s=((1-data1[2])*1000), marker="|") 
plt.title("Observed vs Predicted Values - Graduated",fontsize=16)
plt.ylabel("Observed Value",fontsize=14)
plt.xlabel("Predicted Value",fontsize=14)
#add text to display current learning rate
plt.text(0.2,0.5,'Epochs = 5000; Learning Rate = %s' % learning_rate, fontsize=14)
#set the color palette
plt.set_cmap('jet_r') # "_r to reverse the order"
#add color bar
cbar=plt.colorbar()
#label the color bar definition of our new accuracy calculation
cbar.set_label('Squared Error ((Y - Y predicted)**2)') 
#set y axis to only show 0 and 1 for observed values
plt.yticks(range(0,2,1), fontsize=14)
plt.xticks(fontsize=14)
#add axes to remove top and right
lines = plt.axes()
lines.spines["top"].set_visible(False)     
lines.spines["right"].set_visible(False)
plt.sca(lines) #adds axes to current figure

plt.show()