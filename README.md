# Functional-Verification-of-I2C-Multiple-Bus-Controller
This project (which is a part of the course ECE 745 at NC State University) deals with the functional verification of I2C Multiple Bus Controller. A class-based test bench architecture is built using System Verilog. The Design Under Test (DUT) is an open source RTL code of the I2C multiple bus controller which is based on the I2C protocol. The specification of the design can be found here.

The files related to this project are mainly split into several packages which includes the verification packages and the project benches and/or test packages. Further the verification package is split into various interface packages that are required for this project. The verification test plan is attached, which describes how the features of this design are to be tested and verified.

NOTE: The test architecture for this project is mainly implemented based on NCSU Base Package, which is similar to the UVM package. All the components defined are extended from this base package. (Due to copyright issues, the ncsu_base_pkg is not included in this repository). 


