# Threads Freezers
## Overview
Gates are the Synchronization VIs, similar to [Semaphores](http://zone.ni.com/reference/en-XX/help/371361M-01/glang/semaphore_vis/). They act as a control point which allows or prohibits the data to go through it, depending on the gate state. Gates can act as “thread freezers”, which stop specified processes in a controllable way (similar to [Thread.Freeze method](https://msdn.microsoft.com/en-us/library/envdte.thread.freeze.aspx)).
## Case Study
LabVIEW makes development of multithreading application very simple because of its automated and transparent for programmer, threads management. Therefore diving into the world of multiprocess applications comes relatively fast for G developers.  Sample CLA exam with the ATM machine is used as a multithreading application exemplar for this case study.

<p align="center">
<img width="600" height="300" src="https://github.com/bienieck/ThreadsFreezers_Presentation/blob/master/Graphics/readme/atm.png">
</p>
<p align="center">
    <em>CLA exam with the ATM machine</em>
</p>

This application consists of a couple of threads such as the user input interface called “user console” which can be used, e.g. for entering users PIN, and the output interface “display console” for displaying machine status. Application contains also hardware input in a form of simulated “sensor Interface” and database containing e.g. user funds information. The heart of the application is the “ATM Controller” which bonds all the threads. The last but not least thread is Error Handler. Each process performs its dedicated functions in parallel with other threads. All processes communicate with each other using some kind of queue communication. 

When any of these components generates an error during its work, it is sent through the queue to the Error Handler. Error handling can be performed in many ways, depending on the requirements. 

ATM example specifications says
> - The ATM has centralized error handling with different categories of errors. 
> - Console Error - Provides a warning to the user. The user is notified of the error and the ATM continues operations without interruption. 
> - Display Console Error - Displays a notification dialog to the user. When the user clicks OK, the error clears and the ATM continues the last operation or process step. 
> - User Console Error - Displays a notification dialog to the user with the choice to clear or continue with the error. 
> - Sensor Interface IO Error - The Controller executes a Terminate State. 
> - Error Log - The error handling system maintains a log file.

Having this in mind, a theoretical case can be considered (not necessarily related with the ATM machine): during work of an application an error was generated and sent to the error handler. The process which generates the error is still running. At this time user is asked what to do with the error, but before he made up his mind, “infected” by error thread negatively influenced the application causing trouble. The situation is presented below.

<p align="center">
<img width="400" height="500" src="https://github.com/bienieck/ThreadsFreezers_Presentation/blob/master/Graphics/readme/homer.png">
</p>

This situation can suggest the need for some mechanism of stopping the threads from execution, which is simply the need for a thread freezer.

This mechanism can be achieved with the use of a gate concept. This concept consists of two components: the gate and the gate controller. Gate is the control point located at the beginning of a while loop (thread) and allows the data to go through it only when it’s open. In other words, loop iterating is locked as long as the gate is closed. Gate Controller is a mechanism to globally open or close the gates located in different independent threads in a controllable way.

Gates can be implemented in many ways. Some of the solutions can be found below.
- Using a global register, such as Functional Global Variable, which stores the information about the gate (open or close). In this implementation the gate will be composed with while loop inside which a functional global variable will be polling checked as long the gate is closed.
- Using global register as above but where polling is replaced with user events.
- Using Semaphores. Gate will be composed with consecutively called Acquire Semaphore.vi and Release Semaphore.vi. Closing gate will be achieved with acquisition of semaphores and opening with releasing semaphores.
- Using queues. This can be achieved in at least two ways. First, analogous to the semaphores method (actually, a semaphore is a queue), the gate will be composed with consecutively called dequeue elements and enqueue elements. This operation will be performed when the queue is not empty so before the gate can be used a proper queue initialization is needed. Closing the gate will be performed by clearing the queue, and opening by filling the queue back again. Second queue method will work inversely. Gate will consecutively call an enqueue element and then dequeue it. In both versions the queue must have a defined size (not infinite). 

All the above implementations can work but, unfortunately, they have same flaws, such as using polling (some may not consider this an issue, but polling is bad, mmkay) or risk of deadlocks (all the above queue based solutions use two atomic operations as a gate, which may cause problems in nondeterministic systems).

<p align="center">
<img src="https://github.com/bienieck/ThreadsFreezers_Presentation/blob/master/Graphics/62844239.jpg">
</p>

This article suggests usage of gates based on queues, but with the use of one atomic operation as a gate – **Preview Queue Element** primitive VI – which does not interfere with the queue content. Suggested implementation should not cause any unforeseen problems, regardless whether used in deterministic or nondeterministic environments and generally can be considered safe to use. Additionally, its API is prepared to fit the basic LabVIEW synchronization VIs, so it should be fairly easy to start work with for everyone who used in example Semaphore VIs.

<p align="center">
<img src="https://github.com/bienieck/ThreadsFreezers_Presentation/blob/master/Graphics/readme/api.png">
</p>
<p align="center">
    <em>Gates API</em>
</p>

## Description

### Obtain Gate Reference.vi
<p align="center">
<img src="https://github.com/bienieck/ThreadsFreezers_Presentation/blob/master/Graphics/readme/Obtain%20Gate%20Reference.png">
</p>
Obtainig the gate reference is in fact obtainig the queue reference. For the queue reference and its element <i>datalog file reference</i> with unique enum typedef is used. This  is done for safety reasons and it is intended to make it more difficult for the user to modyfie the queue. For similar reason the named queues fixed gate prefix is added. The obtained queue needs to be of a fixed size for the gate to work and size 1 is least resource-hungry. If a new queue is created it is immediately filled which is equivalent to making the gate open.

### Check Gate.vi
<p align="center">
<img src="https://github.com/bienieck/ThreadsFreezers_Presentation/blob/master/Graphics/readme/Check%20Gate.png">
</p>
This VI uses <i>Preview Queue Element</i> to verify the gate state. If the gate queue is filled then <i>Preview Queue Element</i> can return information about it, but when the queue is empty then Preview Queue Element waits until it is filled back. This way the gate is closed as long as the queue is empty and checking closed gate in any thread will result in freezing this thread. The VIs on error clusters are used only for translating the queue errors to gate errors so in case of any trouble the user knows if the issue is in some raw queue or in the gates.

### Open Gates.vi
<p align="center">
<img src="https://github.com/bienieck/ThreadsFreezers_Presentation/blob/master/Graphics/readme/Open%20Gates.png">
</p>
Opening the gate is performed by filling the queue. <i>Open Gates</i> uses <i>Lossy Enqueue Element</i> to ensure deadlock proof operating. This way there is no problem with opening already open gate. 

### Close Gates.vi 
<p align="center">
<img src="https://github.com/bienieck/ThreadsFreezers_Presentation/blob/master/Graphics/readme/Close%20Gates.png">
</p>
Closing the gate is performed with quick and deadlock proof <i>Flush Queue</i>. Empty queue serves as closed gate.

### Release Gate Reference.vi
<p align="center">
<img src="https://github.com/bienieck/ThreadsFreezers_Presentation/blob/master/Graphics/readme/Release%20Gate%20Reference.png">
</p>
Releasing the gate reference is no different from releasing queues except the previously added queue name prefix is removed.

### Get Gate Status.vi
<p align="center">
<img src="https://github.com/bienieck/ThreadsFreezers_Presentation/blob/master/Graphics/readme/Get%20Gate%20Status.png">
</p>
Verifying the gate status comes to returning gate queue name (without the gate prefix) and number of control points waiting for the gate to be open.

### Not A Gate.vi
<p align="center">
<img src="https://github.com/bienieck/ThreadsFreezers_Presentation/blob/master/Graphics/readme/Not%20A%20Gate.png">
</p>
Returns the information if the gate reference is valid.

## Steps to Implement the Code
See attached example for instructions.

## Requirements
- LabVIEW 2013
