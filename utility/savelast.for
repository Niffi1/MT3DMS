C
      PROGRAM SAVELAST
C ***********************************************************
C THIS PROGRAM EXTRACTS THE CONCENTRATION IN THE LAST STEP
C FROM THE UNFORMATTED CONCENTRATION FILE [MT3Dnnn.UCN],
C AND SAVES IT IN A SEPARATE UNFORMATTED FILE AS STARTING
C CONCENTRATION FOR A CONTINUATION RUN.
C ***********************************************************
C Version 4.50. last modified: 05-28-2003
C Written by C. Zheng
C
C--REDIMENSION THE STORAGE X ARRAY IF NECESSARY
      PARAMETER (IUCN=10,IOUT=11)
      INTEGER   ISTYLE
      CHARACTER FLNAME*80,TEXT*16,FORMARG*20,ACCARG*20
      DIMENSION X(:)
      ALLOCATABLE :: X
C
      write(*,1)
    1 format(1x,'Savelast - extract final concentrations',
     & ' from a UCN file for a restart run.'/)
C
C--OPEN INPUT FILES
      WRITE(*,10)
   10 FORMAT(1X,'Enter name of unformatted concentration file',
     & ' (default is MT3D001.UCN): ')
      READ(*,'(A80)') FLNAME
      IF(FLNAME.EQ.' ') FLNAME='MT3D001.UCN'
C
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
      OPEN(IUCN,FILE=FLNAME,FORM=FORMARG,ACCESS=ACCARG)
C
      WRITE(*,12)
   12 FORMAT(1X,'Enter name of the output file',
     & ' (default is RESTART.UCN): ')
      READ(*,'(A80)') FLNAME
      IF(FLNAME.EQ.' ') FLNAME='RESTART.UCN'
      OPEN(IOUT,FILE=FLNAME,FORM=FORMARG,ACCESS=ACCARG)
C
C--GET NO. OF COLUMNS, ROWS AND LAYERS
      WRITE(*,14)
   14 FORMAT(1X,'Enter number of columns, rows and layers: ')
      READ(*,*) NCOL,NROW,NLAY
      NCR=NCOL*NROW
      NODES=NCOL*NROW*NLAY
C
      ALLOCATE (X(NODES),STAT=IOERR)
      IF(IOERR.NE.0) THEN
        WRITE(*,*) 'STOP.  NOT ENOUGH MEMORY'
        STOP
      ENDIF
C
C--CONTINUE READING UNTIL THE LAST STEP IS REACHED
   50 READ(IUCN,err=100,iostat=ioerr)
     &  NTRANS,KSTP,KPER,TIME2,TEXT,NC,NR,ILAY
C
      if(ioerr.ne.0) goto 100
C
      K=ILAY
      IF(NC.NE.NCOL.OR.NR.NE.NROW.OR.ILAY.GT.NLAY) THEN
        WRITE(*,56)
   56   FORMAT(/1X,'Error: either style of unformatted file',
     &         ' or number of columns, rows, layers',
     &         /1X,'       has been specified incorrectly.')
         STOP
      ENDIF
C
C--READ CONCENTRATION RECORD ONE LAYER AT A TIME
      READ(IUCN) ((X( (K-1)*NCR+(I-1)*NCOL+J ),J=1,NCOL),I=1,NROW)
C
      GOTO 50
C
C--WRITE TO OUTPUT FILE
  100 DO 110 K=1,NLAY
        ILAY=K
        WRITE(IOUT) NTRANS,KSTP,KPER,TIME2,TEXT,NC,NR,ILAY
        WRITE(IOUT) ((X( (K-1)*NCR+(I-1)*NCOL+J ),J=1,NCOL),I=1,NROW)
  110 CONTINUE
C
      DEALLOCATE (X)
C
      STOP
      END
