C
C     PROGRAM PostMT3DMS|PostMODFLOW
C *****************************************************************
C THIS PROGRAM READS THE UNFORMATTED CONCENTRATION OR HEAD FILE
C SAVED BY MT3DMS/MODFLOW, AND THE MODEL GRID CONFIGURATION FILE,
C TO CREATE DATA FILES APPROPRIATE FOR USE BY GOLDEN SOFTWARE'S
C CONTOURING GRAPHIC PACKAGE [SURFER] OR AMTEC'S 3D VISUALIZATION
C PACKAGE TECPLOT.
C *****************************************************************
C Version 4.50, last modified: 05-28-2003
C Written by C. Zheng
C
C--REDIMENSION THE STORAGE X ARRAY IF NECESSARY
      IMPLICIT  NONE
      INTEGER   IUCN,ICNF,IOUT
      PARAMETER (IUCN=10,ICNF=11,IOUT=12)
      INTEGER   NCOL,NROW,NLAY,LCDISR,LCDISC,LCDISL,LCHTOP,LCCNEW,
     &          LCBUFF,NT0,KS0,KP0,JJJ1,JJJ2,III1,III2,KKK1,KKK2,
     &          IFMT,IOERR,ISUM,ISUMX,L,ISTYLE
      REAL      TIME0,X,CINACT,C0,YTRANS,ZTRANS,CDRY,XOFF,YOFF,ZOFF
      LOGICAL   FOUND,ENDED
      CHARACTER FLNAME*80,ANS*1,ACCARG*20,FORMARG*20
      DIMENSION X(:)
      ALLOCATABLE :: X
      COMMON /DRYCEL/CDRY
      COMMON /OFFSET/XOFF,YOFF,ZOFF
C
C--WRITE AN IDENTIFIER TO SCREEN
      WRITE(*,101)
  101 FORMAT('+',
     & 'PM - Unformatted File Reader for MODFLOW/MT3DMS.',
     & ' Version 4.50. 05/28/2003.'/)
C
C--CDRY IS VALUE INDICATING DRY CELL WHICH IS SET IN MODFLOW
C--AS 1.E30
      CDRY=1.E30
C
C--OPEN INPUT FILES
    5 WRITE(*,10)
   10 FORMAT(1X,'Enter name of unformatted concentration or head file',
     &      /1X,'saved after running MT3DMS or MODFLOW: ')
      READ(*,'(A80)') FLNAME
      IF(FLNAME.EQ.' ') GOTO 5
    6 WRITE(*,7)
    7 FORMAT(1X,'Specify style of the unformatted file;',
     &      /1X,'enter 1 for [VF/LF95-style Unformatted];',
     &          ' 2 for [True Binary]: ')
      READ(*,*) ISTYLE
      IF(ISTYLE.NE.1.AND.ISTYLE.NE.2) THEN
        WRITE(*,8)
        GOTO 6
    8   FORMAT(1X,'Invalid file style specified. Enter 1 or 2 Only.')
      ENDIF
C
C--DEFINE STRUCTURE OF UNFORMATTED FILE
      IF(ISTYLE.EQ.1) THEN
        FORMARG='UNFORMATTED'
        ACCARG='SEQUENTIAL'
      ELSEIF(ISTYLE.EQ.2) THEN
        FORMARG='BINARY'
        ACCARG='SEQUENTIAL'
      ENDIF
C
      L=INDEX(FLNAME,' ')-1
      OPEN(IUCN,FILE=FLNAME(1:L),FORM=FORMARG,ACCESS=ACCARG,
     & STATUS='OLD')
C
   11 WRITE(*,12)
   12 FORMAT(1X,'Enter name of the model grid configuration file: ')
      READ(*,'(A80)') FLNAME
      IF(FLNAME.EQ.' ') GOTO 11
      L=INDEX(FLNAME,' ')-1
      OPEN(ICNF,FILE=FLNAME(1:L),FORM='FORMATTED',STATUS='OLD')
C
C--ALLOCATE SPACE IN THE X ARRAY FOR INDIVIDUAL WORKING ARRAYS
      CALL DEFINE(ICNF,ISUM,NCOL,NROW,NLAY,
     & LCDISR,LCDISC,LCDISL,LCHTOP,LCCNEW,LCBUFF)
      WRITE(*,1) NCOL,NROW,NLAY
    1 FORMAT(1X,'The model consists of',I5,' Columns',I5,' Rows, and',
     & I3,' Layers'/)
C
C--DYNAMICALLY ALLOCATE MEMORY
      ISUMX=ISUM-1
      ALLOCATE (X(ISUMX),STAT=IOERR)
      IF(IOERR.NE.0) THEN
        WRITE(*,*) 'STOP.  NOT ENOUGH MEMORY'
        STOP
      ENDIF
C
C--READ SPATIAL DISCRETIZATION INFORMATION
      CALL GETCNF(ICNF,NCOL,NROW,NLAY,X(LCDISR),X(LCDISC),X(LCDISL),
     & X(LCHTOP),X(LCBUFF),CINACT,YTRANS,ZTRANS)
C
C--OFFSET COORDINATE ORIGIN IF REQUESTED
      WRITE(*,310)
  310 FORMAT(1X,'Do you wish to offset the coordinate origin (y/n)? ')
      READ(*,'(A)') ANS
      IF(ANS.EQ.'y'.OR.ANS.EQ.'Y') THEN
  315   WRITE(*,320)
  320   FORMAT(1X,'Enter offsets for x, y and z axes: ')
        READ(*,FMT=*,ERR=330,IOSTAT=IOERR) XOFF,YOFF,ZOFF
  330   IF(IOERR.GT.0) THEN
          WRITE(*,113)
          GOTO 315
        ENDIF
      ELSE
        XOFF=0
        YOFF=0
        ZOFF=0
      ENDIF
C
C--DEFINE TOTAL ELAPSED TIME OR STEP NUMBER
C--AT WHICH CONTOUR MAP IS NEEDED
  114 WRITE(*,14)
      READ(*,FMT=*,ERR=116,IOSTAT=IOERR) TIME0
  116 IF(IOERR.GT.0) THEN
        WRITE(*,113)
        GOTO 114
  113   FORMAT(1X,'Invalid input.  Please try again.')
      ELSEIF(TIME0.EQ.0) THEN
  115   WRITE(*,16)
        READ(*,FMT=*,ERR=118,IOSTAT=IOERR) NT0,KS0,KP0
  118   IF(IOERR.GT.0.OR.KS0.LE.0.OR.KP0.LE.0) THEN
          WRITE(*,113)
          GOTO 115
        ENDIF
      ENDIF
   14 FORMAT(1X,'Specify total elapsed time at which',
     & ' contour map is needed',
     & /1X,'(enter 0 to specify step numbers ',
     & 'or -1 for the final step): ')
   16 FORMAT(1X,'Specify number of Transport Step,',
     & ' Time Step, and Stress Period (Transport Step',
     & /1X,'is not used and can be given any number',
     & ' for MODFLOW file): ')
C
C--LOAD CONCENTRATIONS OR HEADS AT THE DESIRED STEP
      CALL GETUCN(IUCN,NCOL,NROW,NLAY,
     & TIME0,NT0,KS0,KP0,ENDED,FOUND,X(LCCNEW))
      IF(.NOT.FOUND.AND.ENDED) THEN
        WRITE(*,17)
        READ(*,'(A1)') ANS
        IF(ANS.EQ.'Y'.OR.ANS.EQ.'y') THEN
          REWIND(IUCN)
          GOTO 114
        ELSE
          GOTO 100
        ENDIF
      ENDIF
   17 FORMAT(/1X,'Cannot find the specified total elapsed time',
     & ' or step number.'/1X,'Try again (Y/N)? ')
C
C--SPECIFY THE J,I,K INDICES AT CORNERS OF THE CONTOUR MAP
  199 WRITE(*,18)
      READ (*,FMT=*,ERR=200,IOSTAT=IOERR) JJJ1,III1,KKK1
      if(jjj1.eq.-1) jjj1=1
      if(iii1.eq.-1) iii1=1
      if(kkk1.eq.-1) kkk1=1
  200 IF(IOERR.GT.0) THEN
        WRITE(*,113)
        GOTO 199
      ELSEIF(JJJ1.LT.1.OR.JJJ1.GT.NCOL
     &   .OR.III1.LT.1.OR.III1.GT.NROW
     &   .OR.KKK1.LT.0.OR.KKK1.GT.NLAY) THEN
        WRITE(*,202)
        GOTO 199
      ENDIF
  205 WRITE(*,20)
      READ (*,FMT=*,ERR=210,IOSTAT=IOERR) JJJ2,III2,KKK2
      if(jjj2.eq.-1) jjj2=ncol
      if(iii2.eq.-1) iii2=nrow
      if(kkk2.eq.-1) kkk2=nlay
  210 IF(IOERR.GT.0) THEN
        WRITE(*,113)
        GOTO 205
      ELSEIF(JJJ2.LT.1.OR.JJJ2.GT.NCOL
     &   .OR.III2.LT.1.OR.III2.GT.NROW
     &   .OR.KKK2.LT.0.OR.KKK2.GT.NLAY) THEN
        WRITE(*,202)
        GOTO 205
      ELSEIF(JJJ1.GT.JJJ2.OR.III1.GT.III2.OR.KKK1.GT.KKK2) THEN
        WRITE(*,201)
        GOTO 199
      ENDIF
   18 FORMAT(/1X,'Specify starting column (J1), row (I1),',
     & ' layer (K1) indices of the contour map'
     & /1X,'(enter K1=0 to specify water table): ')
   20 FORMAT(1X,'Specify ending column (J2), row (I2),',
     & ' layer (K2) indices of the contour map'
     & /1X,'(enter K2=0 to specify water table): ')
  201 FORMAT(1X,'Starting indices must be < or = ending indices.',
     & '  Please try again.')
  202 FORMAT(1X,'Specified Column, Row or Layer number out of bound.',
     & '  Please try again.')
C
C--OPEN OUTPUT DATA FILE
  217 WRITE(*,22)
      READ(*,'(A80)') FLNAME
      IF(FLNAME.EQ.' ') GOTO 217
      L=INDEX(FLNAME,' ')-1
      OPEN(IOUT,FILE=FLNAME(1:L),FORM='FORMATTED')
   22 FORMAT(1X,'Enter name of output data file',
     & ' for generating contour map: ')
C
C--SPECIFY THE FORMAT OF OUTPUT DATA FILE
  122 WRITE(*,24)
      READ(*,*,ERR=123) IFMT
      IF(IFMT.EQ.3) THEN
        WRITE(*,5000) CINACT
        READ(*,'(A1)') ANS
        IF(ANS.EQ.'Y'.OR.ANS.EQ.'y') THEN
          WRITE(*,5020)
          READ(*,*) C0
        ENDIF
      ENDIF
      IF(IFMT.EQ.1.OR.IFMT.EQ.2.OR.IFMT.EQ.3) GOTO 126
  123 WRITE(*,25)
      GOTO 122
 5000 FORMAT(1X,'Current value indicating inactive/dry cells=',G15.7,
     & /1X,' Replace it with a different value (y/n)? ')
 5020 FORMAT(1X,'Enter a new value to indicate inactive/dry cells: ')
   24 FORMAT(1X,'Select a format for the data file; Enter',
     &  /1X,' 1 for Surfer GRD foramt (regular grid assumed);',
     &  /1X,' 2 for DAT format without header',
     &          ' (inactive cells skipped);',
     &  /1X,' 3 for DAT format with Tecplot header: ')
   25 FORMAT(1X,'Input value must be either 1, 2 or 3.',
     & '  Please try again.')
C
C--WRITE CONCENTRATIONS TO OUTPUT DATA FILE
  126 IF(IFMT.EQ.1) THEN
        CALL TOPO(IOUT,NCOL,NROW,NLAY,JJJ1,JJJ2,III1,III2,KKK1,KKK2,
     &   X(LCDISR),X(LCDISC),X(LCDISL),X(LCCNEW),X(LCBUFF),CINACT,
     &   YTRANS,ZTRANS)
      ELSE
        CALL GRID(IOUT,NCOL,NROW,NLAY,JJJ1,JJJ2,III1,III2,KKK1,KKK2,
     &   X(LCDISR),X(LCDISC),X(LCDISL),X(LCCNEW),X(LCBUFF),CINACT,
     &   YTRANS,ZTRANS,IFMT,C0)
      ENDIF
C
C--CREATE ANOTHER DATA FILE FOR CONTOUR MAP?
      WRITE(*,30)
   30 FORMAT(1X,'Create another data file for contour map (Y/N)? ')
      READ(*,'(A1)') ANS
      IF(ANS.NE.'Y'.AND.ANS.NE.'y') GOTO 100
C
C--REDEFINE TOTAL ELASPED TIME OR STEP NUMBER?
      WRITE(*,32)
   32 FORMAT(1X,'Change total elapsed time or step number (Y/N)? ')
      READ(*,'(A1)') ANS
      IF(ANS.EQ.'Y'.OR.ANS.EQ.'y') THEN
   40   WRITE(*,14)
        READ(*,FMT=*,ERR=42,IOSTAT=IOERR) TIME0
   42   IF(IOERR.GT.0) THEN
          WRITE(*,113)
          GOTO 40
        ELSEIF(TIME0.EQ.0) THEN
   44     WRITE(*,16)
          READ(*,FMT=*,ERR=46,IOSTAT=IOERR) NT0,KS0,KP0
   46     IF(IOERR.GT.0.OR.KS0.LE.0.OR.KP0.LE.0) THEN
            WRITE(*,113)
            GOTO 44
          ENDIF
        ENDIF
  124   CALL GETUCN(IUCN,NCOL,NROW,NLAY,
     &   TIME0,NT0,KS0,KP0,ENDED,FOUND,X(LCCNEW))
        IF(.NOT.FOUND.AND.ENDED) THEN
          WRITE(*,26)
          READ(*,'(A1)') ANS
          IF(ANS.EQ.'Y'.OR.ANS.EQ.'y') THEN
            REWIND(IUCN)
            GOTO 124
          ELSE
            GOTO 100
          ENDIF
        ENDIF
      ENDIF
   26 FORMAT(1X,'End of the unformatted file reached.  ',
     & ' Re-search from the beginning (Y/N)? ')
C
C--REDEFINE LOCATION OF CONTOUR MAP?
      WRITE(*,34)
   34 FORMAT(1X,'Change corner indices of the contour map (Y/N)? ')
      READ(*,'(A1)') ANS
      IF(ANS.EQ.'Y'.OR.ANS.EQ.'y') THEN
        GOTO 199
      ELSE
        GOTO 217
      ENDIF
C
  100 CONTINUE
      STOP
      END
C
C
      SUBROUTINE DEFINE(ICNF,ISUM,NCOL,NROW,NLAY,LCDISR,LCDISC,LCDISL,
     & LCHTOP,LCCNEW,LCBUFF)
C*********************************************************************
C THIS SUBROUTINE READS COLUMN, ROW AND LAYER NUMBERS FROM THE MODEL
C GRID CONFIGURATION AND ALLOCATES SPACE FOR ARRAYS USED IN PROGRAM.
C ********************************************************************
C
      IMPLICIT  NONE
      INTEGER   ICNF,ISUM,NCOL,NROW,NLAY,
     &          LCDISR,LCDISC,LCDISL,LCHTOP,LCCNEW,LCBUFF
C
C--READ NO. OF LAYERS, ROWS, COLUMNS, AND STRESS PERIODS
      READ(ICNF,*) NLAY,NROW,NCOL
C
C--INITIALIZE ARRAY POINTER FOR ALLOCATING MEMORY
      ISUM=1
C
C--ALLOCATE SPACE FOR ARRAYS
      LCDISR=ISUM
      ISUM=ISUM+NCOL
      LCDISC=ISUM
      ISUM=ISUM+NROW
      LCDISL=ISUM
      ISUM=ISUM+NCOL*NROW*NLAY
      LCCNEW=ISUM
      ISUM=ISUM+NCOL*NROW*NLAY
      LCHTOP=ISUM
      ISUM=ISUM+NCOL*NROW
      LCBUFF=ISUM
      ISUM=ISUM+NCOL*NROW*NLAY
C
C--NORMAL RETURN
      RETURN
      END
C
C
      SUBROUTINE GETCNF(ICNF,NCOL,NROW,NLAY,DISR,DISC,DISL,HTOP,BUFF,
     & CINACT,YTRANS,ZTRANS)
C *********************************************************************
C THIS SUBROUTINE READS SPATIAL DISCRETIZATION INFORMATION, AND THE
C VALVE INDICATING INACTIVE CELLS FROM THE MODEL GRID CONFIGURATION.
C**********************************************************************
C
      IMPLICIT  NONE
      INTEGER   ICNF,NCOL,NROW,NLAY,J,I,K,IERR
      REAL      DISR,DISC,DISL,HTOP,BUFF,CINACT,HORIGN,
     &          YTRANS,ZTRANS,CDRY,CTMP
      DIMENSION DISR(NCOL),DISC(NROW),DISL(NCOL,NROW,NLAY),
     &          HTOP(NCOL,NROW),BUFF(NCOL,NROW,NLAY)
      COMMON /DRYCEL/CDRY
C
C--READ CELL WIDTH ALONG ROWS (OR THE X AXIS)
C--AND CALCULATE NODAL COORDINATES RELATIVE TO ORIGIN
      READ(ICNF,*) (BUFF(J,1,1),J=1,NCOL)
      DISR(1)=BUFF(1,1,1)/2.
      DO 70 J=2,NCOL
        DISR(J)=DISR(J-1)+(BUFF(J-1,1,1)+BUFF(J,1,1))/2.
   70 CONTINUE
C
C--READ CELL WIDTH ALONG COLUMNS
C--AND CALCULATE NODAL COORDINATES RELATIVE TO ORIGIN
      READ(ICNF,*) (BUFF(1,I,1),I=1,NROW)
      DISC(1)=BUFF(1,1,1)/2.
      DO 80 I=2,NROW
        DISC(I)=DISC(I-1)+(BUFF(1,I-1,1)+BUFF(1,I,1))/2.
   80 CONTINUE
      YTRANS=DISC(NROW)+BUFF(1,NROW,1)/2.
C
C--READ TOP ELEVATION OF 1st MODEL LAYER
      READ(ICNF,*) ((HTOP(J,I),J=1,NCOL),I=1,NROW)
      HORIGN=HTOP(1,1)
      ZTRANS=HORIGN
C
C--READ CELL THICKNESS
C--AND CALCULATE NODAL COORDINATES RELATIVE TO ORIGIN
      READ(ICNF,*) (((BUFF(J,I,K),J=1,NCOL),I=1,NROW),K=1,NLAY)
      DO 90 I=1,NROW
        DO 95 J=1,NCOL
          DISL(J,I,1)=BUFF(J,I,1)/2.+(HORIGN-HTOP(J,I))
          DO 100 K=2,NLAY
            DISL(J,I,K)=DISL(J,I,K-1)+(BUFF(J,I,K-1)+BUFF(J,I,K))/2.
  100     CONTINUE
   95   CONTINUE
   90 CONTINUE
C
C--READ THE VALVE INDICATING INACTIVE OR DRY CONCENTRATION CELLS
      READ(ICNF,*,ERR=200,END=200,IOSTAT=IERR) CINACT,CDRY
  200 IF(IERR.NE.0) CDRY=CINACT
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE GETUCN(IUCN,NCOL,NROW,NLAY,TIME0,NT0,KS0,KP0,ENDED,
     & FOUND,CNEW)
C ********************************************************************
C THIS SUBROUTINE READS THE UNFORMATTED CONCENTRATION OR HEAD FILE
C SAVED BY MT3D OR MODFLOW, AND LOADS THE CONCENTRATIONS/HEADS
C AT THE DESIRED STEP INTO ARRAY [CNEW].
C ********************************************************************
C
      IMPLICIT  NONE
      INTEGER   IUCN,NCOL,NROW,NLAY,NT0,KS0,KP0,J,I,K,
     &          NTRANS,KSTP,KPER,NC,NR,ILAY,ITMP1,ITMP2,ITMP3,IOERR
      REAL      CNEW,TIME2,TIME0
      LOGICAL   FOUND,ENDED
      CHARACTER TEXT*16
      DIMENSION CNEW(NCOL,NROW,NLAY)
C
C--INITIALIZE
      ENDED=.FALSE.
      FOUND=.FALSE.
C
C--READ UNFORMATTED CONCENTRATION FILE
    1 WRITE(*,11)
   11 FORMAT(1X,'Reading Unformatted File......')
   12 DO 10 K=1,NLAY
C
C--READ AND PRINT HEADER
        READ(IUCN,err=100,iostat=ioerr)
     &     ITMP1,ITMP2,ITMP3,TIME2,TEXT,NC,NR,ILAY
        if(ioerr.ne.0) goto 100
        NTRANS=ITMP1
        KSTP=ITMP2
        KPER=ITMP3
        IF(TEXT(1:13).NE.'CONCENTRATION'.AND.
     &         TEXT(1:13).NE.'concentration') THEN
          KSTP=ITMP1
          KPER=ITMP2
          NT0=-1
          NTRANS=-1
        ENDIF
        IF(K.EQ.1.AND.NTRANS.GT.0) WRITE(*,2) NTRANS,KSTP,KPER,TIME2
        IF(K.EQ.1.AND.NTRANS.LT.0) WRITE(*,3) TEXT,KSTP,KPER,TIME2
    2   FORMAT(1X,'Transport Step',I5,' Time Step',I3,
     &   ' Stress Period',I3,' Total Elapsed Time',G11.4)
    3   FORMAT(1X,A16,': Time Step',I3,
     &   ' Stress Period',I3,' Total Elapsed Time',G11.4)
C
C--MAKE SURE PROPER FILE IS READ
        IF(NC.NE.NCOL.OR.NR.NE.NROW) THEN
          WRITE(*,5)
    5     FORMAT(/1X,'NCOL or NROW in unformatted file ',
     &     'and model grid configuration file NOT same.')
          STOP
        ELSEIF(ILAY.NE.K) THEN
          WRITE(*,6) K
    6     FORMAT(/1X,'Layer',I3,' NOT found in unformatted file.')
          STOP
        ENDIF
C
C--READ CONCENTRATION RECORD ONE LAYER AT A TIME
        READ(IUCN) ((CNEW(J,I,K),J=1,NCOL),I=1,NROW)
C
   10 CONTINUE
C
C--FIND DESIRED STEP AT WHICH CONTOUR MAP IS NEEDED?
C--IF NOT GO TO NEXT STEP
      IF(TIME0.GT.0.AND.ABS(TIME0-TIME2).LT.1.E-5*TIME0) THEN
        FOUND=.TRUE.
        GOTO 200
      ELSEIF(TIME0.EQ.0.AND.
     & NT0.EQ.NTRANS.AND.KS0.EQ.KSTP.AND.KP0.EQ.KPER) THEN
        FOUND=.TRUE.
        GOTO 200
      ENDIF
      GOTO 12
C
  100 ENDED=.TRUE.
      IF(TIME0.LT.0) FOUND=.TRUE.
C
C--RETURN
  200 RETURN
      END
C
C
      SUBROUTINE TOPO(IOUT,NCOL,NROW,NLAY,JJJ1,JJJ2,III1,III2,KKK1,KKK2,
     & DISR,DISC,DISL,CNEW,BUFF,CINACT,YTRANS,ZTRANS)
C **********************************************************************
C THIS SUBROUTINE WRITES THE CONCENTRATIONS/HEADS TO BE CONTOURED
C TO AN OUTPUT FILE IN THE FORMAT WHICH CAN BE READ DIRECLY
C BY GOLDEN SOFEWARE'S CONTOURING PROGRAM [TOPO].
C **********************************************************************
C
      IMPLICIT  NONE
      INTEGER   IOUT,NCOL,NROW,NLAY,JJJ1,JJJ2,III1,III2,KKK1,KKK2,
     &          J,I,K,NX,NY,LAYER
      REAL      CNEW,DISR,DISC,DISL,CINACT,CBLANK,XMIN,XMAX,YMIN,YMAX,
     &          CMIN,CMAX,BUFF,YTRANS,ZTRANS,CDRY,XOFF,YOFF,ZOFF
      CHARACTER DSPM*4
      DIMENSION CNEW(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY),
     &          DISR(NCOL),DISC(NROW),DISL(NCOL,NROW,NLAY)
      PARAMETER (DSPM='DSAA',CBLANK=1.701411E+038)
      COMMON /DRYCEL/CDRY
      COMMON /OFFSET/XOFF,YOFF,ZOFF
C
C--LOAD PORTION OF CONCENTRATION/HEAD ARRAY INTO BUFFER AS DETERMINED
C--BY WHETHER CONTOUR MAP IS ON WATER TABLE, MODEL LAYER,
C--CROSS SECTION ALONG A ROW, OR CROSS SECTION ALONG A COLUMN
C
C--1. IF ON WATER TABLE
      IF(KKK1*KKK2.EQ.0) THEN
        DO 200 I=III1,III2
          DO 202 J=JJJ1,JJJ2
            DO 204 K=1,NLAY
              IF(K.LT.NLAY .AND. (CNEW(J,I,K).EQ.CINACT .OR.
     &           CNEW(J,I,K).EQ.CDRY) ) GOTO 204
              BUFF(J,I,1)=CNEW(J,I,K)
              GOTO 202
  204       CONTINUE
  202     CONTINUE
  200   CONTINUE
C
C--2. IF ON MODEL LAYER
      ELSEIF(KKK1.EQ.KKK2) THEN
        DO 205 I=III1,III2
          DO 206 J=JJJ1,JJJ2
            BUFF(J,I,KKK1)=CNEW(J,I,KKK1)
  206     CONTINUE
  205   CONTINUE
C
C--3. IF ON CROSS SECTION ALONG A ROW
      ELSEIF(III1.EQ.III2) THEN
        DO 208 K=KKK1,KKK2
          DO 210 J=JJJ1,JJJ2
            BUFF(J,III1,K)=CNEW(J,III1,K)
  210     CONTINUE
  208   CONTINUE
C
C--3. IF ON CROSS SECTION ALONG A COLUMN
      ELSEIF(JJJ1.EQ.JJJ2) THEN
        DO 212 K=KKK1,KKK2
          DO 214 I=III1,III2
            BUFF(JJJ1,I,K)=CNEW(JJJ1,I,K)
  214     CONTINUE
  212   CONTINUE
      ENDIF
C
C--DETERMINE NX,NY,XMIN,YMIN,XMAX,YMAX,CMIN,CMAX
C--AND ALSO ASSIGN [CBLANK] TO INACTIVE CELLS
      CMIN=1.E30
      CMAX=-1.E30
      IF(KKK1.EQ.KKK2) THEN
        NX=JJJ2-JJJ1+1
        NY=III2-III1+1
        XMIN=DISR(JJJ1) + XOFF
        XMAX=DISR(JJJ2) + XOFF
        YMIN=YTRANS-DISC(III2) + YOFF
        YMAX=YTRANS-DISC(III1) + YOFF
        IF(KKK1*KKK2.EQ.0) THEN
          LAYER=1
        ELSE
          LAYER=KKK1
        ENDIF
        DO 10 I=III1,III2
          DO 12 J=JJJ1,JJJ2
            IF(BUFF(J,I,LAYER).EQ.CINACT .OR.
     &         BUFF(J,I,LAYER).EQ.CDRY) THEN
              BUFF(J,I,LAYER)=CBLANK
            ELSE
              CMIN=MIN(CMIN,BUFF(J,I,LAYER))
              CMAX=MAX(CMAX,BUFF(J,I,LAYER))
            ENDIF
   12     CONTINUE
   10   CONTINUE
      ELSEIF(III1.EQ.III2) THEN
        NX=JJJ2-JJJ1+1
        NY=KKK2-KKK1+1
        XMIN=DISR(JJJ1) + XOFF
        XMAX=DISR(JJJ2) + XOFF
        YMIN=ZTRANS-DISL(JJJ1,III1,KKK2) + ZOFF
        YMAX=ZTRANS-DISL(JJJ2,III1,KKK1) + ZOFF
        DO 20 K=KKK1,KKK2
          DO 22 J=JJJ1,JJJ2
            IF(BUFF(J,III1,K).EQ.CINACT. OR.
     &         BUFF(J,III1,K).EQ.CDRY) THEN
              BUFF(J,III1,K)=CBLANK
            ELSE
              CMIN=MIN(CMIN,BUFF(J,III1,K))
              CMAX=MAX(CMAX,BUFF(J,III1,K))
            ENDIF
   22     CONTINUE
   20   CONTINUE
      ELSEIF(JJJ1.EQ.JJJ2) THEN
        NX=III2-III1+1
        NY=KKK2-KKK1+1
        XMIN=YTRANS-DISC(III2) + YOFF
        XMAX=YTRANS-DISC(III1) + YOFF
        YMIN=ZTRANS-DISL(JJJ1,III2,KKK2) + ZOFF
        YMAX=ZTRANS-DISL(JJJ1,III1,KKK1) + ZOFF
        DO 30 K=KKK1,KKK2
          DO 32 I=III1,III2
            IF(BUFF(JJJ1,I,K).EQ.CINACT .OR.
     &         BUFF(JJJ1,I,K).EQ.CDRY) THEN
              BUFF(JJJ1,I,K)=CBLANK
            ELSE
              CMIN=MIN(CMIN,BUFF(JJJ1,I,K))
              CMAX=MAX(CMAX,BUFF(JJJ1,I,K))
            ENDIF
   32     CONTINUE
   30   CONTINUE
      ENDIF
C
C--WRITE HEADER TO OUTPUT FILE
      WRITE(IOUT,'(A4)') DSPM
      WRITE(IOUT,*) NX,NY,XMIN,XMAX,YMIN,
     & YMAX,CMIN,CMAX
C
C--WRITE ARRAY VALUES TO OUTPUT FILE
      IF(KKK1.EQ.KKK2) THEN
        IF(KKK1*KKK2.EQ.0) THEN
          LAYER=1
        ELSE
          LAYER=KKK1
        ENDIF
        DO 40 I=III2,III1,-1
          WRITE(IOUT,*) (BUFF(J,I,LAYER), J=JJJ1,JJJ2)
   40   CONTINUE
      ELSEIF(III1.EQ.III2) THEN
        DO 50 K=KKK2,KKK1,-1
          WRITE(IOUT,*) (BUFF(J,III1,K), J=JJJ1,JJJ2)
   50   CONTINUE
      ELSEIF(JJJ1.EQ.JJJ2) THEN
        DO 60 K=KKK2,KKK1,-1
          WRITE(IOUT,*) (BUFF(JJJ1,I,K), I=III2,III1,-1)
   60   CONTINUE
      ENDIF
C
C--RETURN
      CLOSE (IOUT)
      RETURN
      END
C
C
      SUBROUTINE GRID(IOUT,NCOL,NROW,NLAY,JJJ1,JJJ2,III1,III2,KKK1,KKK2,
     & DISR,DISC,DISL,CNEW,BUFF,CINACT,YTRANS,ZTRANS,IFMT,C0)
C **********************************************************************
C THIS SUBROUTINE WRITES THE CONCENTRATIONS/HEADS ALONG WITH THE NODAL
C COORDINATES TO A DATA FILE IN THE FORMAT WHICH CAN BE READ BY
C GOLDEN SOFTWARE'S SURFER OR AMTEC'S TECPLOT.
C **********************************************************************
C
      IMPLICIT  NONE
      INTEGER   IOUT,NCOL,NROW,NLAY,JJJ1,JJJ2,III1,III2,KKK1,KKK2,J,I,K,
     &          LAYER,IFMT,NX,NY,NZ
      REAL      CNEW,DISR,DISC,DISL,CINACT,C0,YTRANS,ZTRANS,BUFF,CDRY,
     &          XOFF,YOFF,ZOFF,WTBL
      DIMENSION CNEW(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY),
     &          DISR(NCOL),DISC(NROW),DISL(NCOL,NROW,NLAY)
      COMMON /DRYCEL/CDRY
      COMMON /OFFSET/XOFF,YOFF,ZOFF
C
C--GET CONC. OR HEAD ON WATER TABLE
      IF(KKK1*KKK1.EQ.0) THEN
        DO I=III1,III2
          DO J=JJJ1,JJJ2
            DO K=1,NLAY
              IF(K.LT.NLAY .AND. (CNEW(J,I,K).EQ.CINACT .OR.
     &         CNEW(J,I,K).EQ.CDRY) ) CYCLE
              BUFF(J,I,1)=CNEW(J,I,K)
              EXIT
            ENDDO
          ENDDO
        ENDDO
      ENDIF
C
C--PRINT TECPLOT HEADER IF IFMT=3
      IF(IFMT.EQ.3) THEN
        NX=JJJ2-JJJ1+1
        NY=III2-III1+1
        NZ=KKK2-KKK1+1
        WRITE(IOUT,*) 'VARIABLES="X", "Y", "Z", "DATA" '
        WRITE(IOUT,*) 'ZONE I=',NX,' J=',NY,' K=',NZ,' F=POINT'
      ENDIF
C
C--PRINT OUT ONE POINT AT A TIME
      IF(KKK1*KKK2.EQ.0) THEN
        WTBL=0.
        DO I=III1,III2
          DO J=JJJ1,JJJ2
            IF(BUFF(J,I,1).EQ.CINACT .OR.
     &       BUFF(J,I,1).EQ.CDRY) CYCLE
            WRITE(IOUT,*) DISR(J)+XOFF,YTRANS-DISC(I)+YOFF,WTBL,
     &       BUFF(J,I,1)
          ENDDO
        ENDDO
      ELSE
        DO K=KKK1,KKK2
          DO I=III1,III2
            DO J=JJJ1,JJJ2
              IF(IFMT.EQ.2. AND. ( abs(CNEW(J,I,K)-CINACT).LT.1.e-5 .OR.
     &         abs(CNEW(J,I,K)-CDRY).lt.1.e-5 ) ) CYCLE
              IF(IFMT.EQ.3. AND. ( abs(CNEW(J,I,K)-CINACT).LT.1.e-5 .OR.
     &         abs(CNEW(J,I,K)-CDRY).lt.1.e-5 ) ) cnew(j,i,k)=c0
              WRITE(IOUT,*) DISR(J)+XOFF,YTRANS-DISC(I)+YOFF,
     &         ZTRANS-DISL(J,I,K)+ZOFF,CNEW(J,I,K)
            ENDDO
          ENDDO
        ENDDO
      ENDIF
C
      CLOSE (IOUT)
      RETURN
      END
