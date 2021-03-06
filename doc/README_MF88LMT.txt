README FILE FOR MODFLOW-88 WITH LINK-MT3D INTERFACE
Chunmiao Zheng (czheng@ua.edu)
Last update: 05/25/2003
-------CONTENTS
-------GENERAL INFORMATION
MODIFICATIONS TO THE ORIGINAL MODFLOW-88
SYSTEM REQUIREMENTS
A NOTE ON THE UNFORMATTED FLOW-TRANSPORT LINK FILE
INSTALLATION AND RECOMPILING
LIST OF FILES
GENERAL INFORMATION
===================
MODFLOW-88/mt is a modified version of the USGS modular three-dimensional
finite-difference ground-water flow model MODFLOW-88 with the Link-MT3D
Package version 3.0.
For more information on MODFLOW-88 or to download the documentation for
MODFLOW-88, visit the USGS groundwater software website for MODFLOW-88 at
http://water.usgs.gov/nrp/gwsoftware/modflow.html. For additional
information on how to incorporate the Link-MT3D Package into MODFLOW-88,
and how to activate the Link-MT3D Package to save the flow-transport link
file, refer to the MT3DMS Documentation (Zheng and Wang, 1999, p. 101-2).
MODIFICATIONS TO THE ORIGINAL MODFLOW-88
========================================
In addition to full compatibility with the standard USGS version
(McDonald and Harbaugh, 1988), this version of MODFLOW-88 has the following
enhancements:
1) The Link-MT3D Package Version 3.0 is included for interfacing with MT3DMS.
This package is implemented in IUNIT (22) (see MT3DMS Documentation
and User's Guide for more information).
2) The original Block-Centered-Flow (BCF1) package is replaced by the BCF2
package (McDonald et al., 1991, USGS Open-File Report 91-536). The BCF2
package has a rewet option which makes it possible to convert no-flow cells
to variable-head cells. The BCF2 package implemented in MODFLOW-88/mt
accepts the input file prepared for the BCF1 package. When the rewet option
is not activated in BCF2, the value for HDRY (value indicating dry cells) is
set to 1.E30 by default, thus retaining full compatibility with BCF1.
3) The Preconditioned-Conjugate-Gradient 2 (PCG2) package (Hill, 1990, USGS
Open-File Report 90-4048) is included as an additional solver for MODFLOW.
This package is implemented on IUNIT (15).
4) The Streamflow-Routing (STR1) package (Prudic, 1989, USGS Open-File

1

Report 88-729) is included for simulation of stream-aquifer relations.
The latest version of the LinkMT3D package is compatible with the STR1
package and will save the streamflow term properly for use by MT3DMS.
This package is implemented on IUNIT (14).
5) The Horizontal Flow Barrier (HFB1) package (Hsieh, 1993) is included
for simulation of low-permeability barriers such as a slurry wall.
This package is implemented on IUNIT (16).
6) The Time-Varying Constant-Head Boundary (CHD1) package is included
(Leake and Prudic, 1988). It is implemented on IUNIT (20).
7) The array readers (U2DINT and U2DREL) in the original MODFLOW are implemented
with new options to enter 2D integer and real arrays using convenient
block, zone, or free formats, thus making them compatible with the MT3DMS
array readers IARRAY and RARRAY (see MT3DMS Documentation and User's Guide
for more information).
SYSTEM REQUIREMENTS
===================
The executable program, mf88.exe, was compiled with the Lahey FORTRAN 95
compiler LF95 Version 5.7 to run on PCs with Pentium higher CPUs.
The executable program was compiled with dynamic memory allocation and
will allocate the exact amount of memory that is required for a particular
problem at run-time. If the memory required by the problem exceeds the
total amount of physical memory that is available, mf88.exe will print
out a message "NOT ENOUGH MEMORY" and then aborts. mf88.exe runs
under Microsoft Windows /9x/2000/NT/XP in the command prompt mode.
A NOTE ON THE UNFORMATTED FLOW-TRANSPORT LINK FILE
==================================================
Note that the MODFLOW-MT3D link file saved by the MODFLOW-88/mt is unformatted
(binary characters). Different FORTRAN compilers or even different versions of
the same compiler may use different file structures and styles for the
unformatted binary files. For this reason, the MT3D/MT3DMS code compiled by a
particular compiler may not be able to read the unformatted flow-transport link
file saved by a MODFLOW code that was compiled with a different compiler or
compiler version, and vice versa.
This version of MODFLOW-88 was compiled by Lahey Fortran 95 compiler (LF95)
The style of unformatted files generated by LF95-compiled programs is
compatible with that of Visual Fortran (VF) from Compaq/HP, but not compatible
with that of Lahey Fortran 90 compiler (LF90) used for compiling
MT3D/MT3DMS prior to Version 4.5. Thus, it may be necessary to re-run an
existing flow model using this version of MODFLOW-88 to create the flowtransport link file for use by MT3DMS 4.5. Also, several utility programs
included with the MT3DMS 4.5 distribution files may be used to convert an
unformatted flow-transport link file from the LF90-style to LF95/VF-style,
and vice versa. For more information, refer to the ReadMe file for MT3DMS 4.5
utilities (Utilities.PDF).

2

INSTALLATION AND RECOMPILING
============================
The executable code for this version of MODFLOW-88 is name ‘mf88.exe’, and
is part of the MT3DMS 4.5 distribution files. If the source code is
recompiled, copy the recompiled executable file to the subdirectory where
the MT3D/MT3DMS executable files are located.
To use MODFLOW-88/mt independently, create a subdirectory with a name such as
MF88LMT\bin and copy the file mf88.exe to the new subdirectory. To make the
MODFLOW program accessible from any directory, the subdirectory containing the
executable should be included in the PATH environment variable. For example,
you could add a line similar to the following to the AUTOEXEC.BAT file:
PATH=%PATH%;C:\MF88LMT\bin
Make sure to substitute the appropriate drive letter and pathname if not C:\
as shown above. Reboot your system after modifying AUTOEXEC.BAT.
On Windows 2000/NT/XP systems, from the Start menu, find and select
Control Panel. Then edit the PATH Environment Variable to include
“C:\MF88LMT\bin". Initiate and use a new MS-DOS Command Prompt window after
making this change.
To re-compile this version MODFLOW-88 with Lahey LF95, copy all source files to
a temporary subdirectory and type 'AM' to start the AUTOMAKE utility. The
compiler options that should be used for recompiling are contained in the file
Automake.fig.
LIST OF FILES
=============
This version is distributed with the following files:
README_MF88LMT.txt: latest readme file (this file)
mf88.exe: executable program for Pentium or higher PCs
lkmt3.for: source file for the LKMT3 Package
lkmt3.inc: source "include file" used by MAIN to invoke LKMT3 Package
main.for: source file for Modflow-88/mt MAIN program
bas1.for: source file for MODFLOW BAS1 package
bcf2.for: source file for MODFLOW BCF2 package
drn1.for: source file for MODFLOW DRN1 package
evt1.for: source file for MODFLOW EVT1 package
rch1.for: source file for MODFLOW RCH1 package
riv1.for: source file for MODFLOW RIV1 package
sip1.for: source file for MODFLOW SIP1 package
sor1.for: source file for MODFLOW SOR1 package
wel1.for: source file for MODFLOW WEL1 package
utl1.for: source file for MODFLOW UTL1 package
ghb1.for: source file for MODFLOW GHB1 package
str1.for: source file for MODFLOW STR1 package
hfb1.for: source file for MODFLOW HFB1 package
pcg2.for: source file for MODFLOW PCG2 package
automake.fig: LF95 configuration for the Automake utility

3

