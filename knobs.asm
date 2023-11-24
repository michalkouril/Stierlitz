 ;; /*************************************************************************
 ;; *                     This file is part of Stierlitz:                    *
 ;; *               https://github.com/asciilifeform/Stierlitz               *
 ;; *************************************************************************/

 ;; /*************************************************************************
 ;; *                (c) Copyright 2012 Stanislav Datskovskiy                *
 ;; *                         http://www.loper-os.org                        *
 ;; **************************************************************************
 ;; *                                                                        *
 ;; *  This program is free software: you can redistribute it and/or modify  *
 ;; *  it under the terms of the GNU General Public License as published by  *
 ;; *  the Free Software Foundation, either version 3 of the License, or     *
 ;; *  (at your option) any later version.                                   *
 ;; *                                                                        *
 ;; *  This program is distributed in the hope that it will be useful,       *
 ;; *  but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 ;; *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 ;; *  GNU General Public License for more details.                          *
 ;; *                                                                        *
 ;; *  You should have received a copy of the GNU General Public License     *
 ;; *  along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 ;; *                                                                        *
 ;; *************************************************************************/

;*****************************************************************************
;; Knobs
;*****************************************************************************

;*****************************************************************************
;; The Payload (Virtual File)
;*****************************************************************************
;; QTASM is Retarded...:
;*****************************************************************************

;;;;;;;;;;;;; 1024 meg
;; FILE_SIZE_LW		equ	0x0000
;; FILE_SIZE_UW		equ	0x4000
;; FILE_SIZE_IN_BLKS_LW	equ	0x0000
;; FILE_SIZE_IN_BLKS_UW	equ	0x0020
;; FAKE_FILE_CLUSTERS	equ	32768

;;;;;;;;;;;;; 256 meg
;; FILE_SIZE_LW		equ	0x0000
;; FILE_SIZE_UW		equ	0x1000
;; FILE_SIZE_IN_BLKS_LW	equ	0x0000
;; FILE_SIZE_IN_BLKS_UW	equ	0x0008
;; FAKE_FILE_CLUSTERS	equ	8192

;;;;;;;;;;;;; 1 meg
;; FILE_SIZE_LW		equ	0x0000
;; FILE_SIZE_UW		equ	0x0010
;; FILE_SIZE_IN_BLKS_LW	equ	0x0800
;; FILE_SIZE_IN_BLKS_UW	equ	0x0000
;; FAKE_FILE_CLUSTERS	equ	32

;;;;;;;;;;;;; 128K
;; FILE_SIZE_LW		equ	0x0000
;; FILE_SIZE_UW		equ	0x0002
;; FILE_SIZE_IN_BLKS_LW	equ	0x0100
;; FILE_SIZE_IN_BLKS_UW	equ	0x0000
;; FAKE_FILE_CLUSTERS	equ	4

;;;;;;;;;;;; BPI 8.9 meg (9232444)
FILE_SIZE_LW		equ	0xE03C
FILE_SIZE_UW		equ	0x008C
FILE_SIZE_IN_BLKS_LW	equ	0x4671
FILE_SIZE_IN_BLKS_UW	equ	0x0000
FAKE_FILE_CLUSTERS	equ	282

;;;;;;;;;;;; I2C 16 k (16384)
FILE2_SIZE_LW		equ	0x4000
FILE2_SIZE_UW		equ	0x0000
FILE2_SIZE_IN_BLKS_LW	equ	0x0020
FILE2_SIZE_IN_BLKS_UW	equ	0x0000
FAKE_FILE2_CLUSTERS	equ	1
FILE2_CLUSTER_START_LW  equ     (3+FAKE_FILE_CLUSTERS)

;;;;;;;;;;;; CY16 512 (512)
FILE3_SIZE_LW		equ	0x0200
FILE3_SIZE_UW		equ	0x0000
FILE3_SIZE_IN_BLKS_LW	equ	0x0001
FILE3_SIZE_IN_BLKS_UW	equ	0x0000
FAKE_FILE3_CLUSTERS	equ	1
FILE3_CLUSTER_START_LW  equ     (3+FAKE_FILE_CLUSTERS+FAKE_FILE2_CLUSTERS)

;;;;;;;;;;;; ICAP 512 (512)
FILE4_SIZE_LW		equ	0x0200
FILE4_SIZE_UW		equ	0x0000
FILE4_SIZE_IN_BLKS_LW	equ	0x0001
FILE4_SIZE_IN_BLKS_UW	equ	0x0000
FAKE_FILE4_CLUSTERS	equ	1
FILE4_CLUSTER_START_LW  equ     (3+FAKE_FILE_CLUSTERS+FAKE_FILE2_CLUSTERS+FAKE_FILE4_CLUSTERS)

;*****************************************************************************


;*****************************************************************************
;; Other: no need to change these much
;*****************************************************************************
FW_REV      		equ 	0x1       ; Firmware revision
VENDOR_ID   		equ 	0x08EC    ; "M-Systems Flash Disk"
PRODUCT_ID  		equ 	0x0020    ; "TravelDrive"

MAXBLOCK		equ	4194303 ; Index of last block (NOT block count!)

;; Because QTASM is braindead:
MAXBLOCK_3		equ	0x00
MAXBLOCK_2		equ	0x3F
MAXBLOCK_1		equ	0xFF
MAXBLOCK_0		equ	0xFF
;*****************************************************************************


;*****************************************************************************
;; Really shouldn't change this
;*****************************************************************************
USB_VER			equ     0x0110 ; 0x0110 for USB 1.1; 0x0200 for USB 2.0
;; Endpoints:
EP_IN			equ	0x01 ; 0x81 (ep1)
EP_OUT			equ	0x02 ; 0x02 (ep2)

EP_IN_ADDR		equ	0x81
EP_OUT_ADDR		equ	0x02
USB_PACKET_SIZE		equ     0x0040 ; 64 bytes
EP_IN_BINTERVAL		equ	0x00
EP_OUT_BINTERVAL	equ	0x00
;*****************************************************************************
