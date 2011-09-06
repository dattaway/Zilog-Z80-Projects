         ;LAB6 - MEMORY SEARCH
         ;
         ;AUTHOR: MIKE BRAZDA
         ;
         ;DESCRIPTION:  THIS PROGRAM WILL SEARCH MEMORY FOR A PATTERN THAT IS
         ;              STORED IN MEMORY.  A COPY OF THE PATTERN BEING SEARCHED
         ;              FOR IS HELD IN A MEMORY BUFFER. HL WILL POINT TO THE
         ;              BEGINNING OF MEMORY AREA TO SEARCH. BC WILL HOLD
         ;              THE NUMBER OF BYTES OF MEMORY TO SEARCH.  THE FLAGS,
         ;              ZERO OR CARRY, WILL BE SET OR CLEARED IF THE PATTERN
         ;              IS FOUND OR NOT FOUND.
         ;
         ;INPUT:    A PATTERN SHOULD BE STORED IN MEMORY, AT MEMORY
         ;          LOCATION 6700H - PATTERN IS LIMITED TO 32 BYTES. HL POINTS
         ;          TO THE BEGINNING OF THE MEMORY AREA TO SEARCH. BC SHOULD
         ;          HAVE THE NUMBER OF BYTES OF MEMORY TO SEARCH, AND
         ;          REGISTER D WILL HOLD THE LENGTH OF PATTERN TO SEARCH.
         ;
         ;OUTPUT:   THE CARRY FLAG IS SET IF THE PATTERN IS FOUND, OR RESET
         ;          IF THE PATTERN IS NOT FOUND. IF BC=0 THE Z FLAG IS SET.
         ;
         ;START: 6720H

         .ORG     $6700
PAT      .DS      $20            ;AREA FOR PATTERN TO LOOK FOR
         LD       A,B            ;CHECK IF SEARCH AREA COUNT = 0
         OR       C
         JR       Z,NFOUND

START    LD       IY,PAT         ;GET PTR. TO PATTERN
         LD       A,00H          ;CHECK FOR LENGTH OF PATTERN
         OR       D
         JR       Z,NFOUND1      ;END SEARCH IF PATTTERN LENGTH = 0
         LD       E,0            ;SET COUNT FOR # OF MATCHES TO 0

GETB     LD       A,(IY+0)       ;GET A BYTE FROM THE PATTERN
         CP       (HL)           ;CHECK IF BYTE MATCHES
         JR       Z,MATCH
         INC      HL             ;POINT TO NEXT BYTE TO SEARCH
         DEC      BC             ;DEC COUNT OF BYTES TO LOOK AT
         LD       A,B            ;CHECK IF BC=0
         OR       C
         JR       NZ,GETB

NFOUND1  LD       A,1            ;RESET Z FLAG IF D = 0
NFOUND   RST      20H

MATCH    DEC      D
         LD       A,D
         JR       Z,FOUND        ;END SEARCH IF PATTERN LENGTH = 0
         DEC      BC             ;CHECK IF BC=0
         LD       A,B
         OR       C
         JR       Z,NFOUND
         INC      IY             ;POINT TO NEXT BYTE IN PATTERN
         INC      HL             ;POINT TO NEXT BYTE TO SEARCH
         INC      E              ;ADD ONE TO # OF BYTES FOUND
         LD       A,(IY+0)       ;GET NEXT BYTE PROM PATTERN
         CP       (HL)           ;CHECK IF BYTES MATCH
         JR       Z,MATCH
         LD       A,L            ;SUB MAC FROM SERCH POINTER
         SUB      E
         JR       NC,SKIP
         DEC      H

SKIP     SUB      L              ;FIX UP POINTER TO NEXT BYTE
         LD       A,D            ;ADD MAC TO LPAT
         ADD      A,E
         LD       D,A
         JR       START

FOUND    LD       A,L            ;********************************
         SUB      E              ;
         LD       L,A            ;RETURN POINTER (HL) TO BEGINNING
         JR       NC,SKIP1       ;    OF PATTERN
         DEC      H              ;********************************

SKIP1    SCF                     ;SET CARRY FLAG SHOWING FOUND
         RST      20H

STOP     .END


        
 
         




































































