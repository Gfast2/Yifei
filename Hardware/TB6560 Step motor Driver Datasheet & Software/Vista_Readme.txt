In order to run Mach3 under Vista, you first need to perform a couple of extra steps:

1) First, run the install as per normal.

2) Download memoryoverride.reg, and then double-click it - it modifies
the registry to allow Mach3's driver to run.

3) Now you need to go to the C:\Mach3 folder (or wherever you installed Mach3), and right-click DriverTest.exe, select
"Run as Adminstrator". It should tell you to reboot. Do so, or you will crash. No question about it.

4) Now you should be able to run Mach3. Try the DriverTest.exe again, and it should run.

Note:
   You may get errors reported when running DriverTest (in fact it may not run at all the first time), then
Vista will ask you if you wish to run it in compatability mode. Do so, and it will run...

