--------------------------------------------------------
MT3DMS README FILE
Release 4.00 for MODFLOW-88 and MODFLOW-96
August 2001
--------------------------------------------------------


--------
CONTENTS
--------
GENERAL INFORMATION
EXECUTABLE PROGRAM AND SYSTEM REQUIREMENTS
INSTALLATION AND RE-COMPILING
RUNNING THE SOFTWARE
INTERFACE WITH MODFLOW-88 and MODFLOW-96
LIST OF FILES


GENERAL INFORMATION
===================

MT3DMS is a new version of MT3D developed at the University of Alabama
for the US Army Corps of Engineers Waterways Experiment Station.
Detailed information on MT3DMS can be found in MT3DMS Documentation
and User's Guide (Zheng and Wang, 1998, Revised 1999), available at
http://hydro.geo.ua.edu/mt3d.  

Additional information specific to Version 4 of MT3DMS can be found
in U.S. Geological Survey Open-File Report 01-82 by Zheng and others (2001),
available at http://water.usgs.gov/software/ground_water.html

To report any program errors, please contact

Chunmiao Zheng
Department of Geological Sciences
The University of Alabama
202 Bevill Research Building
Tuscaloosa, AL 35487, USA
Phone: (205) 348-0579
E-mail: czheng@ua.edu
http://hydro.geo.ua.edu


EXECUTABLE PROGRAM AND SYSTEM REQUIREMENTS
==========================================

The executable program, MT3DMS4.EXE, was compiled with the Lahey
LF90 FORTRAN 90 compiler Version 4.00 to run on PCs with a 80486
or higher CPU in 32-bit protected mode using extended memory.
The main program, main400.for, contains FORTRAN 90 extensions
to allow dynamic array allocation.  The compiled program will allocate
the exact amount of memory that is required for a particular problem
at run-time.  If the memory required by the problem exceeds the total
amount of physical memory (RAM) that is available, MT3DMS4.EXE will 
automatically use hard-drive space as virtual memory.  But this slows 
computations dramatically. Thus it is best to have sufficient RAM to run
any particular model.  MT3DMS4.EXE runs under any recent version of
Microsoft Windows in a command-prompt window.


INSTALLATION AND RE-COMPILING
=============================

To install for the first time, create a subdirectory with a name 
such as MT3DMS and then copy files MT3DMS4.EXE and LF90.EER to 
the new subdirectory.  Make sure to modify your AUTOEXEC.BAT or 
AUTOEXEC.NT file to place the MT3DMS subdirectory in the PATH
statement.  File LF90.EER contains the Lahey compiler's run-time
error messages.  When a run-time error occurs, MT3DMS4.EXE will
first search the current working directory and then all directories
specified in the PATH statement to locate file LF90.EER before
it can print out the error message.

To re-compile MT3DMS with Lahey LF90 compiler Version 4.00 or later,
copy all source files to a temporary subdirectory and type 'AM'
to start the AUTOMAKE utility included with the compiler.

Except for a few FORTRAN 90 extensions, MT3DMS was written in standard
ANSI FORTRAN 77 language and thus can also be compiled by most FORTRAN 77
compilers such as Lahey F77L3.

MT3DMS uses unformatted files for both input and output.  Unformatted files
generally have a structure that is compiler specific.  The structure of
unformatted files used by MT3DMS is specified in the Include file named
'filespec.inc'.  The executable program MT3DMS4.EXE included in this 
distribution package was compiled with standard FORTRAN file specifiers 
for unformatted files, i.e.,

FORM='unformatted' and ACCESS='sequential'

and thus it is intended for use with MODFLOW and other companion 
post-processing programs compiled by the same compiler with the same 
file specifiers.  Another executable program compiled with nonstandard 
file specifiers can be downloaded separately.


RUNNING THE SOFTWARE
====================

To run MT3DMS 4.0 using the name-file method, enter the command

mt3dms4 [name-file]

where the command-line argument [name-file] is the name of the MT3DMS name-file
as described in Zheng and others (2001).  If no command-line argument is given,
the user is prompted to enter the name of the name-file.  If the file name ends
in ".nam", it can be specified without including ".nam".  For example,
if the name-file is named “project.nam”, the simulation can be run by
entering:

mt3dms4 project

If the user hits the Enter key when prompted to enter the name of the name-file,
MT3DMS will proceed to prompt the user for the various input/output file names,
as in all versions prior to 4.0.  It is still possible to put all these file
names in a response file and run MT3DMS 4.0 by entering

mt3dms4 < response.fil

where response.fil is the name of the response file.  Note that the first line
of the response file needs to be left blank.


INTERFACE WITH MODFLOW-88 AND MODFLOW-96
========================================

Two versions of USGS MODFLOW with the Link-MT3D interface are
included with this distribution package: MODFLOW3.ZIP for
the original MODFLOW-88 and MODFLW96.ZIP for the more recent
MODFLOW-96.

The Link-MT3D interface for MODFLOW-88 is implemented as an add-on
package (referred to as the LKMT package) and consists of two files,
LKMT3.INC and LKMT3.FOR where 3 denotes version 3).

The file LKMT3.INC is a FORTRAN `include' file which contains
FORTRAN statements to invoke the LKMT3 package.  It should
be added to the MODFLOW main program immediately before the
call to the module `BAS1OT'.  This is done by adding an
`include' statement as shown below:

--------------------------
C
C--SAVE UNFORMATTED FLOW-TRANSPORT LINK FILE FOR USE BY MT3DMS
      INCLUDE 'LKMT3.INC'
C
C--PRINT AND OR SAVE HEADS AND DRAWDOWNS. PRINT OVERALL BUDGET.
      CALL BAS1OT(...)
C
--------------------------

The file LKMT3.FOR is the FORTRAN source file for the LKMT3
Package.  It must be compiled and linked with other packages
for MODFLOW.

The Link-MT3D interface for MODFLOW-96 is implemented in a
similar fashion.  Refer to the README file included with
MODFLOW-96 files.


LIST OF FILES
=============

  readme.txt: latest information file (this file)
 upgrade.txt: bug fixes, enhancements, and version history
 upgrade.htm: upgrade.txt in HTML format
 mt3dms4.exe: MT3DMS executable for PCs with 80486 or higher CPUs
    lf90.eer: Lahey LF90 compiler run-time error message file
 mt3dms4.for: source file for MT3DMS v4 main program
 mt_btn4.for: source file for MT3DMS v4 Basic Transport (BTN) package
 mt_adv4.for: source file for MT3DMS v4 Advection (ADV) package
 mt_dsp4.for: source file for MT3DMS v4 Dispersion (DSP) package
 mt_ssm4.for: source file for MT3DMS v4 Sink & Source Mixing (SSM) package
 mt_rct4.for: source file for MT3DMS v4 Chemical Reaction (RCT) package
 mt_gcg4.for: source file for MT3DMS v4 GCG Solve (GCG) package
 mt_fmi4.for: source file for MT3DMS v4 Flow Model Interface (FMI) package
 mt_utl4.for: source file for MT3DMS v4 Utility (UTL) package
    lf90.fig: Lahey compiler options
automake.fig: configuration for the Automake utility
