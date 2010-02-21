MT3DMS Utilities
By Chunmiao Zheng
Department of Geological Sciences
University of Alabama

May 28, 2003

TABLE OF CONTENTS
I.

PostMT3DMS

2

II

SaveLast

9

III. Unformatted File Converters
IV. Using Model Viewer

10
12

1

I. PostMT3DMS (PM)
INTRODUCTION
PM is a utility program that can be used to extract the calculated heads/concentrations
from the unformatted (binary) head/concentration files saved by MODFLOW/MT3DMS
within a user-specified window along a model layer or cross section (2D), or within a
user-specified volume (3D) at a particular time. The heads/concentrations within the
specified window or volume are saved in such formats that they can be used by any
available graphical packages to generate 2- or 3-D contour maps and other types of
graphics. The source code in Fortran 90 was compiled to run in the command prompt
mode under various Microsoft Windows operating systems.
Executable codes:
pm.exe
Source code:
pm.for
Example input files: mt3d001.ucn
mt3d.cnf
pm.ini [response file]
To use PM, two input files are required. The first is the unformatted head/concentration
file saved by MODFLOW/MT3DMS after appropriate output control options have been
set. PM has been compiled by Lahey LF95 Fortran compiler to accept a structured
unformatted file saved in the style of LF95 and Compaq/HP Visual Fortran or a nonstructured true binary file compatible with different compilers. The second is a text file
which contains information on the spatial configuration of the model grid, referred to as
the model configuration file. For output, PM generates data files either in the POINT
format where the spatial coordinates of a nodal point are saved along with the data value
at the nodal point, or in the ARRAY format that is directly readable by Golden
Software’s 2D contouring package Surfer©. In addition, the data files saved in the
POINT format can include an optional header which is compatible with Amtec
Engineering’s 2D and 3D visualization package Tecplot©.
INPUT INSTRUCTIONS
Unformatted Head/Concentration File
The unformatted (binary) head (also drawdown) file saved by MODFLOW is of the
following structure and contents:
For each time step saved:
For each layer of the three-dimensional head array:
Record 1: KSTP,KPER,PERTIM,TOTIM,TEXT,NCOL,NROW,ILAY
Record 2: ((HNEW(J,I,ILAY),J=1,NCOL),I=1, NROW)

2

where
KSTP
KPER
PERTIM
TOTIM
TEXT
NCOL
NROW
ILAY
HNEW

is the time step at which the head is saved;
is the stress period at which the head is saved;
is the elapsed time within the current stress period;
is the total elapsed time from the beginning of simulation;
is a character string (character*16) set equal to “HEAD”;
is the total number of columns;
is the total number of rows;
is the layer for which the head is saved; and
is the calculated head.

For MT3DMS, one unformatted (binary) concentration file is saved for each chemical
species, with the default name MT3Dnnn.UCN where nnn is the species index number
as in MT3D001.UCN, MT3D002.UCN, and so on. The structure and contents of
unformatted concentration files are as follows:
For each transport step saved:
For each layer of the three-dimensional concentration array:
Record 1: NTRANS,KSTP,KPER,TOTIM,TEXT,NCOL,NROW,ILAY
Record 2: ((CNEW(J,I,ILAY),J=1,NCOL),I=1,NROW)
where
NTRANS
KSTP
KPER
TOTIM
TEXT
NCOL
NROW
ILAY
CNEW

is the transport step at which the concentration is saved;
is the time step at which the concentration is saved;
is the stress period at which the concentration is saved;
is the total elapsed time since the beginning of simulation;
is a character string (character*16) set equal to “CONCENTRATION”;
is the total number of columns;
is the total number of rows;
is the layer for which the concentration is saved; and
is the calculated concentration.

Depending on which FORTRAN compiler was used to compile the MODFLOW and
MT3DMS executables, the style of the unformatted (binary) head/concentration files may
be different. PM supports either ‘unformatted’ or so-called ‘true binary’ style. See
Section III for more information.

3

Model Configuration File
An input file is needed to provide PM with information on the spatial configuration of the
model grid. This input file, referred to as the model configuration file, is saved
automatically by MT3DMS. If PM is used to process the unformatted head or drawdown
file saved by MODFLOW before MT3DMS is used, the user needs to create the model
configuration file manually using a text editor. The structure and contents of the model
configuration file are shown below:
Record 1:
Record 2:
Record 3:
Record 4:
Record 5:
Record 6:

NLAY, NROW, NCOL
(DELR(J), J=1,NCOL)
(DELC(I),I=1,NROW)
((HTOP(J,I),J=1,NCOL),I=1,NROW)
(((DZ(J,I,K), J=1,NCOL),I=1,NROW),K=1,NLAY)
CINACT, CDRY

where
NLAY
DELR
DELC
HTOP
DZ
CINACT
CDRY

is the total number of layers;
is the width of columns (along the rows or x axis);
is the width of rows (along the columns or y axis);
is a 2D array defining the top elevation of the first model layer;
is a 3D array defining the thickness of each model cell;
is the value used in the model for indicating inactive cells;
is the value used in the model for indicating cells gone dry.

The values in the model configuration file are arranged in list-directed (or free) format.
Therefore, each record should begin at a new line and a record can occupy as many lines
as needed. Either blank space or comma can be used to separate values within a record.
In addition, input by free format permits the use of a repeat count in the form, n*d, where
n is an unsigned-non-zero integer constant, and the input n*d causes n consecutive values
of d to be entered. HTOP is a 2D array and its values should be arranged in the order of
column first, sweeping from column 1 to column NCOL along the first row; then
continuing onto row 2, row 3, ..., until row NROW. DZ is a 3D array and its values for
each layer should be arranged similarly to those for HTOP, starting from the first layer,
then continuing onto layer 2, layer 3, ..., until layer NLAY. Note that if one is only
interested in creating data files for certain layers in plan view, then HTOP and DZ are
never used, and thus may be entered as some dummy numbers with the use of repeat
counts.
RUNNING PM
PM can be run in either interactive or batch mode. To run it interactively, simply type
the name of the executable file at the command prompt:
C:\MT3DMS4\Bin\pm

4

where C:\MT3DMS4\Bin is the name of the subdirectory where the PM executable
program resides. Alternatively, under folder view click on the program name to run. The
program will prompt the user for the various input items and the user responds to the
input requests directly from the keyboard. To run PM in batch mode, write all responses
in the order required by PM to a text file and then re-direct PM to get responses from the
response file instead of keyboard by issuing a command such as
C:\MT3DMS4\Bin\pm < pm.ini
where pm.ini is the name of a text file containing all responses to PM which the user
would otherwise type in from the keyboard.
The user can select the concentrations, heads, or drawdowns at a desired time by
specifying either a) the numbers of transport step, time step and stress period, or b) the
total elapsed time, whichever is more convenient. (Note that transport step is used for
MT3DMS only, not for MODFLOW.) The value of -1 may be entered to obtain the
results at the final step stored in the unformatted file. The user can also define a 2D
window or 3D volume within which the graphical data files are desired by specifying the
starting and ending column (J), row (I) and layer (K) indices of the window.
For example, to generate a data file for a cross sectional contour map along the 5th
column, from row 20 to row 40 and from layer 1 to 10, enter the starting (J, I, K) indices
as 5, 20, 1, and the ending (J, I, K) indices as 5, 40, 10. Similarly, to generate a data file
for a cross sectional contour map along the 5th row, from column 20 to column 40 and
from layer 1 to 10, enter the starting (J, I, K) indices as 20, 5, 1, and the ending indices as
40, 5, 10. Moreover, to generate a data file for a contour map on the 5th layer, from
column 20 to column 40 and from row 1 to row 10, enter the starting (J, I, K) indices as
20, 1, 5 and at the lower right corner as 40, 10, 5. Finally, to generate a 3D data file
within a volume defined from column 1 to column 40, from row 1 to row 20, and from
layer 1 to layer 5, enter the starting (J, I, K) indices as 1, 1, 1, and the ending indices as
40, 20, 5. It is also possible to generate a data file for a contour map on the water table,
i.e., the cells in the uppermost active layers instead of a specific layer, say, from column
20 to column 40 and from row 1 to row 10, enter the starting (J, I, K) indices as 20, 1, 0
and the ending indices as 40, 10, 0.
It should be pointed out that in MT3DMS/MODFLOW, the origin of the internal
coordinate system (Om) is set at the upper, top, left corner of the cell in the first column,
first row and first layer, i.e., cell (1, 1, 1) and the positive x, y and z coordinates are in the
directions of increasing column, row, and layer indices, respectively (Figure 1). However,
in the output files generated by PM, the origin (O) is transformed to the lower, bottom,
left corner of cell in the first column, last row and last layer, i.e., cell (1, NROW, NLAY)
(Figure 1), as is customary in most graphical packages. As a result, the y and z axes used
in MT3DMS/MODFLOW are reversed by PM whereas the x axis remains the same.
Therefore, if the contour map is on a layer or water table (i.e., the x-y plane), the
horizontal axis of the map is along the direction of increasing column (J) indices, and the
vertical axis is along the direction of decreasing row (I) indices. If the contour map is on
a cross section along a row (i.e., the x-z plane), the horizontal axis of the map is along the
5

Column (J)

xm

y

m

Ro
ws

(I)

Om

z

Cell(1,1,1)

y

zm

Layer (K)

Cell(1,NROW,NLAY)

O

x

Figure 1. Transformation from the model internal coordinate system
to the coordinate system used by the PM program for plotting purposes.

direction of increasing column (J) indices, and the vertical axis is along the direction of
decreasing layer (K) indices. If the contour map is on a cross section along a column
(i.e., the y-z plane), the horizontal axis of the map is along the direction of decreasing (I)
indices, and the vertical axis is along the direction of decreasing layer (K) indices. All
the necessary transformations are done by PM automatically. As an option, PM also
allows the user to add an offset in the x, y and z directions to the map’s origin for the
convenience of posting data points on the map.
OUTPUT FILES
For output, PM writes data files in one of the two formats, referred to as the ARRAY
format (with the file extension .GRD) and the POINT format (with the file
extension .DAT). The ARRAY format as listed below follows the convention used by
Golden Software's Surfer© graphical contouring package. It saves the concentrations,
heads, or drawdowns within a user-defined window of regular model mesh spacing to the
output file, directly usable for generating contour maps by Surfer©. Note that if
concentrations, heads, or drawdowns in an irregular portion of the model mesh is written
to a “.GRD” file, no interpolation is performed and the contour map is thus deformed.
The POINT format as listed below saves concentration, head, or drawdown at each nodal
point along with the nodal coordinates within the user-defined 2D window or 3D volume

6

to the output file. This format is useful for generating data files of irregular model mesh
spacing to be used by interpolation routines included in any standard contouring packages.
It is also useful for generating plots of concentrations, heads, or drawdowns versus
distances along a column, row or layer at a selected time. An optional header can be
added to a “.DAT” file so that the file can be used directly by Amtec Engineering’s 2D
and 3D visualization package Tecplot©. The ARRAY and POINT formats are listed
below for reference:
1. ARRAY(Surfer© GRD) File Format (free format):
DSAA

NX, NY, XMIN, XMAX, YMIN, YMAX, CMIN, CMAX
CWIN(NX,NY)
where

is the character keyword required by Surfer©.
is the number of nodal points in the horizontal direction of the window;
is the number of nodal points in the vertical direction of the window;
is the minimum nodal coordinate in the horizontal direction of the
window;
XMAX is the maximum nodal coordinate in the horizontal direction of the
window;
YMIN is the minimum nodal coordinate in the vertical direction of the window;
YMAX is the maximum nodal coordinate in the vertical direction of the window;
CMIN is the minimum concentration value within the window;
CMAX is the maximum concentration value within the window; and
CWIN is a 2D array containing all the calculated concentrations or heads within
the window.
DSAA
NX
NY
XMIN

2. POINT (DAT) File Format without Header (free format):
For each active cell inside the specified 2D window or 3D volume:
X, Y, Z, CXYZ
where
X
Y
Z
CXYZ

is the nodal coordinate in the x axis (along the rows);
is the nodal coordinate in the y axis (along the columns);
is the nodal coordinate in the z axis (along the layers); and
is the calculated concentration or head at the nodal point defined by
coordinates (X,Y,Z).

Note that for data files defined in a 2D window, one of the coordinates will be constant.
In using an interpolation routine for gridding purposes, make sure to specify appropriate
columns. For example, to create a contour map in a x-z cross section, the y column
should either be deleted or skipped.
3. POINT (DAT) File Format with Header (free format):

7

This file format is identical to type 2 except the addition of a Tecplot©-compatible header
consisting of the following information:
VARIABLES=“X” “Y” “Z” “DATA”
ZONE I=NX J=NY K=NZ F=POINT
where

VARIABLES, ZONE, I, J, K, F, POINT are keywords used by Tecplot©;
NX is the number of columns within the user-specified 2D window or 3D volume;
NY is the number of rows within the user-specified 2D window or 3D volume;
NZ is the number of layers within the user-specified 2D window or 3D volume;
X, Y, Z and DATA are character labels for the four data columns saved in the file.

8

II. SaveLast
If it is necessary to continue a simulation from the end of a preceding run, the
concentrations from the final step of the preceding run can be used as the starting
concentrations for the continuation run. The dissolved-phased concentrations for species
#nnn, are saved in the default unformatted concentration file, MT3Dnnn.UCN, and the
sorbed- or immobile phase concentrations for species #nnn, are saved in a corresponding
file, MT3DnnnS.UCN. Either file is directly readable by the array reader RARRAY. If
there is more than one step of concentration saved in MT3Dnnn.UCN and/or
MT3DnnnS.UCN, then SaveLast can be used to extract the concentrations of the final
transport step and save them in separate unformatted files for a restart run. To run
SaveLast, simply type SaveLast at the command prompt and enter the names of input and
output files from the monitor screen. SaveLast has been compiled by Lahey LF95
Fortran compiler to accept a structured unformatted file saved in the style of LF95 and
Compaq/HP Visual Fortran or a non-structured true binary file compatible with different
compilers.

9

III. Unformatted File Converters
INTRODUCTION
Unformatted (binary) files used by MODFLOW, MT3DMS, and other related programs
often have different, incompatible styles depending on which FORTRAN compilers have
been used to compile these programs. This section contains a brief description of several
file converters that can be used to convert an unformatted (binary) file from one style to
another. All programs documented in this section were compiled to run in the command
prompt mode under various Microsoft Windows operating systems.
PROGRAM DESCRIPTION
LF90to951
This program converts an unformatted file (head, concentration, or flow-transport link
file) in the style used by the Lahey LF90 FORTRAN compiler to that used by the Lahey
LF95 compiler. The LF95 style is also compatible with that of Compaq/HP Visual
FORTRAN (formerly Digital Visual FORTRAN). To run LF90to95, click on the
program name under folder view, or enter the following command from the command
prompt:
C:\MT3DMS4\Bin\LF90to95

LF90-inputfile

LF95-outputfile

where C:\MT3DMS4\Bin indicates the name of the subdirectory where the LF90to95
program is located, LF90-inputfile is the LF90-style unformatted input file, and
LF95-outputfile is the LF95-style unformatted output file after the conversion. If
the input/output file names are not provided in the command line, the program will
prompt the user for the file names.
LF95to90
This program performs the reverse function of LF90to95. It converts an unformatted
file in the style used by the Lahey LF95 FORTRAN compiler (or Compaq Visual
FORTRAN) to that used by the Lahey LF90 compiler. To run LF95to90, click on the
program name under folder view, or enter the following command from the command
prompt:
C:\MT3DMS4\Bin\LF95to90

LF95-inputfile

LF90-outputfile

where LF95-inputfile is the LF95(VF)-style unformatted input file, and LF90outputfile is the LF90-style unformatted output file after the conversion. If the

1

LF90to95 and LF90to95 are based on the utility programs, sequnf.f90 and unfseq.f90,
distributed as part of the Lahey LF95 FORTRAN compiler.

10

input/output file names are not provided in the command line, the program will prompt
the user for the file names.
UNFtoBIN
This program converts an unformatted file (head or concentration) in the style used by the
Lahey LF95 FORTRAN compiler (and Compaq Visual FORTRAN) to the ‘True
Binary’-style that is exchangeable among various compilers, including LF90, LF95 and
VF. To run UNFtoBIN, click on the program name under folder view, or enter the
following command from the command prompt:
C:\MT3DMS4\Bin\UNFtoBIN

LF95-inputfile

TrueBinary-outputfile

where LF95-inputfile is the LF95(VF)-style unformatted input file, and
TrueBinary-outputfile is the ‘true binary’-style output file after the conversion.
If the input/output file names are not provided in the command line, the program will
prompt the user for the file names.
BINtoUNF
This program performs the reverse function of UNFtoBIN. This program converts a
‘true binary’-style unformatted file to the LF95(VF)-style unformatted file. To run
BINtoUNF, click on the program name under folder view, or enter the following
command from the command prompt:
C:\MT3DMS4\Bin\BINtoUNF

TrueBinary-inputfile

LF95-outputfile

where TrueBinary-inputfile is the ‘true binary’-style input file and LF95outputfile is the LF95(VF)-style unformatted output file after the conversion. If the
input/output file names are not provided in the command line, the program will prompt
the user for the file names.

11

IV. Using Model Viewer
The U.S. Geological Survey’s visualization software package, known as Model Viewer
(Hsieh and Winston, 20022) can be used to visualize and animate simulation results
obtained with several flow and transport models, including MODFLOW, MT3DMS,
MOC3D, and SUTRA. The software and user guide can be downloaded from the USGS
ground-water software site:
http://water.usgs.gov/nrp/gwsoftware/modelviewer/ModelViewer.html
Zheng et al. (20003) provide brief instructions on how to use Model Viewer with
MT3DMS. When set up to display results from MT3DMS, Model Viewer obtains data
from two output files from MT3DMS, the model configuration (CNF) file and the
unformatted concentration (UCN) file. (In addition, the flow-transport link file saved by
MODFLOW for MT3DMS can be read to display velocity vectors and model features.)
The UCN and CNF files are saved by MT3DMS when the output control option for
saving concentrations to unformatted files (SAVUCN) is set to T (for True) in the input
file of the MT3DMS Basic Transport (BTN) Package. By default, MT3DMS names the
model configuration file ‘MT3D.CNF’ and the unformatted concentration files
‘MT3Dnnn.UCN’ where nnn is the species index number such as 001 for species 1 and
002 for species 2. Because the UCN files for different species are structurally identical,
the simulation results can be visualized one species at a time by selecting
MT3D001.UCN, MT3D002.UCN, and so on in Model Viewer.
Depending on which Fortran compiler was used to compile the MT3DMS executable, the
structure of the unformatted (binary) concentration file may be different. It is thus
necessary to specify a correct data structure for the UCN file to be read properly by
Model Viewer. Four types of the unformatted file structure supported by Model Viewer
are:
(1)
(2)
(3)
(4)

Binary (unstructured, non-formatted),
Unformatted (Visual Fortran and Lahey Fortran LF95),
Unformatted (Lahey Fortran LF90), and
Big Endian - Unix

The standard executable code ‘mt3dms4s.exe’ included with the MT3DMS distribution
files supports the second option, while the second executable ‘mt3dms4b.exe’ supports
the first option. The unformatted file converters described previously can be used to
convert unformatted head/concentration files from one style to another.

2

Hsieh, P.A., and Winston, R.B., 2002, User’s Guide To Model Viewer, A Program For ThreeDimensional Visualization of Ground-water Model Results: U.S. Geological Survey Open-File Report 02106, 18 p.
3
Zheng, C., Hill, M.C. and Hsieh P.A., 2001, MODFLOW-2000, The U.S. Geological Survey Modular
Ground-Water Model-User Guide to the LMT6 Package, The Linkage with MT3DMS for Multi-Species
Mass Transport: U.S. Geological Survey Open-File Report 01-82, 44 p.

12

