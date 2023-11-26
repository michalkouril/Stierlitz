 /*************************************************************************
 *                     This file is part of Stierlitz:                    *
 *               https://github.com/asciilifeform/Stierlitz               *
 *************************************************************************/

/*************************************************************************
 *                (c) Copyright 2012 Stanislav Datskovskiy                *
 *                         http://www.loper-os.org                        *
 **************************************************************************
 *                                                                        *
 *  This program is free software: you can redistribute it and/or modify  *
 *  it under the terms of the GNU General Public License as published by  *
 *  the Free Software Foundation, either version 3 of the License, or     *
 *  (at your option) any later version.                                   *
 *                                                                        *
 *  This program is distributed in the hope that it will be useful,       *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *  GNU General Public License for more details.                          *
 *                                                                        *
 *  You should have received a copy of the GNU General Public License     *
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 *                                                                        *
 *************************************************************************/

/*
   2023-11-16 Michal Kouril <xmkouril@gmail.com>
     * ML605 support
     * BPI (read)
     * ICAP (reboot)
 */

`include "stierlitz.v"
`include "infer-sram.v"


module stierlitz_demo_top
  (sys_clk_n,          /* 200MHz main clock line */
   sys_clk_p,          /* 200MHz main clock line */
   sys_rst_pin,      /* Master reset */
   /************* Cypress CY7C67300 *************/
   sace_usb_a,       /* CY HPI Address bus (two bits) */
   sace_usb_d,       /* CY HPI Data bus */
   sace_usb_oen,     /* CY HPI nRD */
   sace_usb_wen,     /* CY HPI nWR */
   usb_csn,          /* CY HPI nCS */
   usb_hpi_reset_n,  /* CY HPI nRESET */
   usb_hpi_int,      /* CY HPI INT */
   /*********************************************/
   CBUTTON,          /* Center Button */
   EBUTTON,          /* East Button */
   WBUTTON,
   NBUTTON,
   SBUTTON,

   CLED,          /* Center LED */
   ELED,          /* East LED */
   WLED,
   NLED,
   SLED,
   /*********************************************/
   led_byte,         /* LED bank, 8 bits wide */
   /*********************************************/
   FLASH_A, /* 24 bit */
   FLASH_D, /* 16 bit */
   FLASH_WAIT,
   FPGA_FWE_B,
   FPGA_FOE_B,
   // FPGA_CCLK,
   PLATFLASH_L_B,
   FPGA_FCS_B,
   P30_CS_SEL
   );
   
   /* The basics */
   input wire sys_clk_n;
   input wire sys_clk_p;
   input wire sys_rst_pin;
   input wire CBUTTON;      /* These buttons are active-high */
   input wire EBUTTON;
   input wire NBUTTON;
   input wire SBUTTON;
   input wire WBUTTON;
   output wire CLED;
   output wire ELED;
   output wire NLED;
   output wire SLED;
   output wire WLED;
   output wire [7:0] led_byte;

   /* CY7C67300 */
   output wire 	sace_usb_oen;
   output wire 	sace_usb_wen;
   output wire 	usb_csn;
   input wire  	usb_hpi_int;
   output wire [1:0] sace_usb_a;
   inout wire [15:0] sace_usb_d;
   output wire 	usb_hpi_reset_n;

   output wire [23:0] FLASH_A; /* 24 bit */
   inout wire [15:0] FLASH_D; /* 16 bit */
   input wire FLASH_WAIT;
   output wire FPGA_FWE_B;
   output wire FPGA_FOE_B;
   // output wire FPGA_CCLK;
   output wire PLATFLASH_L_B;
   output wire FPGA_FCS_B;
   output wire P30_CS_SEL;

   wire [1:0]	usb_addr;

   wire         sys_clk;

   IBUFGDS IBUFGDS_inst(
    .I(sys_clk_p),
    .IB(sys_clk_n),
     .O(sys_clk)
    );

   assign sace_usb_a[1:0] = usb_addr[1:0];

   /* CY manual reset */
   wire 	usbreset = CBUTTON | sys_rst_pin; /* tie rst to main rst */
   // assign usb_hpi_reset_n = ~usbreset;

   /* Ideally, 16 MHz (x2) clock for HPI interface */
   wire 	hpi_clock;
   wire 	ram_clock;
   wire 	clkfb;


   /* A bit OC's, ok. */
   /*
   reg [1:0] 	clkdiv;
   always @(posedge sys_clk, posedge usbreset)
     if (usbreset)
       begin
   	  clkdiv <= 0;
       end
     else
       begin
   	  clkdiv <= clkdiv + 1;
       end
   assign hpi_clock = clkdiv[1];
   */

   MMCM_BASE #(
     .CLKFBOUT_MULT_F(5),
     .CLKOUT1_DIVIDE(128),
     .CLKOUT2_DIVIDE(32)
   )
   hpi_clock_mmcm (.CLKIN1(sys_clk),
   			   .CLKFBIN(clkfb),
   			   .CLKFBOUT(clkfb),
   			   .CLKOUT1(hpi_clock),
   			   .CLKOUT2(ram_clock),
    			   .RST(sys_rst_pin)
    			   );

   wire 	hpi_manual_test = EBUTTON; /* temporary manual toggle to run tester */
   wire 	usb_irq = usb_hpi_int; /* HPI IRQ is active-high */
   
   wire 	sbus_ready;
   wire 	sbus_rw;
   wire 	sbus_start_op;
   wire [40:0] 	sbus_address;
   wire [7:0] 	sbus_data;
   

   // assign led_byte = sbus_address[16:9];
   // assign led_byte = FLASH_D[7:0];
   assign led_byte = {go, bit_swapped[6:0]};

   
   stierlitz s(.clk(hpi_clock),
	       .reset(usbreset),
	       .enable(1'b1),
	       /* Control wiring */
	       .bus_ready(sbus_ready),
	       .bus_address(sbus_address),
	       .bus_data(sbus_data),
	       .bus_rw(sbus_rw),
	       .bus_start_op(sbus_start_op),
	       /* CY7C67300 connections */
	       .cy_hpi_address(usb_addr),
	       .cy_hpi_data(sace_usb_d),
	       .cy_hpi_oen(sace_usb_oen),
	       .cy_hpi_wen(sace_usb_wen),
	       .cy_hpi_csn(usb_csn),
	       .cy_hpi_irq(usb_hpi_int),
	       .cy_hpi_resetn(usb_hpi_reset_n)
	       );

   // reg [7:0] 	test;
   // wire [7:0] 	test;
   
   // assign sbus_data = sbus_rw ? test : 8'bz;

   // always @(posedge sys_clk)
   //   begin
   // 	case (sbus_address[1:0])
   // 	  2'b00:
   // 	    test <= sbus_address[16:9];
   // 	  2'b01:
   // 	    test <= sbus_address[24:17];
   // 	  2'b10:
   // 	    test <= sbus_address[32:25];
   // 	  2'b11:
   // 	    test <= sbus_address[40:33];
   // 	endcase // case (sbus_address[1:0])
   //   end

   reg          sbus_ready_out;
   assign       sbus_ready = sbus_ready_out;

   reg [7:0] 	sbus_data_out;
   assign sbus_data = sbus_rw ? sbus_data_out : 8'bz;

/*
   wire 	ram_we;
   wire 	ram_oe;
   assign ram_we = (~sbus_rw) & sbus_start_op;
   assign ram_oe = sbus_rw & sbus_start_op;
*/

   assign FLASH_A = sbus_address[24:1];

   reg        flash_read = 1'b1;
   reg [31:0] sbus_start_op_shift;
   reg [31:0] sbus_data_in_shift;

   wire [7:0] sbus_data_in_icap_mapped;
   assign     sbus_data_in_icap_mapped = {sbus_data[0], sbus_data[1], sbus_data[2], sbus_data[3], sbus_data[4], sbus_data[5], sbus_data[6], sbus_data[7]};

   wire [31:0] sbus_data_in_icap_shift_next;
   assign     sbus_data_in_icap_shift_next = { sbus_data_in_shift[23:0], sbus_data_in_icap_mapped };

   reg [31:0] icap_data_in;
   reg [7:0]  icap_ram0 [15:0]; 
   reg [7:0]  icap_ram1 [15:0]; 
   reg [7:0]  icap_ram2 [15:0]; 
   reg [7:0]  icap_ram3 [15:0]; 


   reg        go = 1'b0;
   reg        reboot = 1'b0;
   reg [3:0]  cnt_bitst  = 4'b0;
   reg        icap_cs = 1'b1;
   reg        icap_rw = 1'b1;
   reg [31:0] d = 32'hFFFFFFFF;
   wire [31:0] bit_swapped;

   always @(posedge hpi_clock)
   begin
	// icap_cs = 1'b0;

        if (sbus_start_op == 1'b0)
	begin
	   sbus_start_op_shift = 0;
	   sbus_ready_out = 1'b0;
	end else
	begin
   	   sbus_start_op_shift = { sbus_start_op_shift[30:0], sbus_start_op };
	end

	// start of op
	if ((sbus_start_op_shift[0]!=sbus_start_op_shift[1]) && (sbus_start_op_shift[0]==1'b1))
	begin
	   flash_read = sbus_rw;

	   // write to ICAP
	   if ((sbus_rw==1'b0) && (sbus_address[28] == 1'b1))
	   begin
	      go = 1'b1;
	      // icap_ram[0] = 8'hAA;
/*
              if (sbus_address[23:3]==21'b0)
	      begin
	        icap_ram[sbus_address[2:0]] = sbus_data;
	      end
*/
	      if (sbus_address[1:0] == 2'b11)
	      begin
	        icap_data_in = sbus_data_in_icap_shift_next;
		// icap_cs = 1'b1;
	      end
	      else
	      begin
   	        sbus_data_in_shift = sbus_data_in_icap_shift_next;
	      end
	   end
	end

        // READ
	if ((sbus_rw==1'b1) && (sbus_start_op_shift[10]!=sbus_start_op_shift[11]) && (sbus_start_op_shift[10]==1'b1))
	begin
	   if (sbus_address[28] == 1'b1)
	   begin
              if (sbus_address[23:6]==18'b0)
	      begin
	        // sbus_data_out = icap_ram0[sbus_address[3:0]];
		
	        case (sbus_address[1:0])
		2'b00: sbus_data_out = icap_ram0[sbus_address[5:2]]; // 8'hcc;
		2'b01: sbus_data_out = icap_ram1[sbus_address[5:2]]; // 8'hcc;
		2'b10: sbus_data_out = icap_ram2[sbus_address[5:2]]; // 8'hcc;
		2'b11: sbus_data_out = icap_ram3[sbus_address[5:2]]; // 8'hcc;
		endcase;
		
	      end else
	      begin
	        sbus_data_out = 8'hcc;
	      end
	   end
	   else
	   begin
	      sbus_data_out = sbus_address[0]?FLASH_D[15:8] : FLASH_D[7:0];
	   end
	   sbus_ready_out = 1'b1;
	end

        // WRITE
	if ((sbus_rw==1'b0) && (sbus_start_op_shift[10]!=sbus_start_op_shift[11]) && (sbus_start_op_shift[10]==1'b1))
	begin
	   sbus_ready_out = 1'b1;
	end
   end

   // on write -- assume sequential -- remember the previous 8 bit value to form 16 bit BPI write
   // OE constant to 1 and WE to 0

   assign CLED = CBUTTON;
   assign ELED = EBUTTON;
   assign NLED = NBUTTON;
   assign SLED = SBUTTON;
   assign WLED = WBUTTON;

   // output FLASH_WAIT;
   assign FPGA_FWE_B = flash_read; // 1'b1; // WE# // read-only
   assign FPGA_FOE_B = 1'b0;  // Output enable active-low
   // assign FPGA_CCLK = 1'b0; // X
   assign FPGA_FCS_B = 1'b0;
   assign PLATFLASH_L_B = 1'b0;
   assign P30_CS_SEL = 1'b1;

        ICAP_VIRTEX6 
	#(
          .ICAP_WIDTH("X32")                  // Specifies the input and output data width to be used with the
                                              // ICAP_VIRTEX6.
       )
       ICAP_VIRTEX6_inst (
          .BUSY(),                                                           // 1-bit output: Busy/Ready output
          .O(),                                                              // 32-bit output: Configuration data output bus
          .CLK(hpi_clock),                                                   // 1-bit input: Clock Input
          .CSB(icap_cs),                                                    // 1-bit input: Active-Low ICAP input Enable
          .I(bit_swapped),                                              // 32-bit input: Configuration data input bus
          .RDWRB(icap_rw)                                                       // as of now the write operation is 0
                                                                             // 1-bit input: Read/Write Select input
       );

   always @(posedge hpi_clock)
   begin
      if (go == 1'b1) 
      begin
        reboot = 1'b1;
      end
     
      if (reboot == 1'b0)
      begin
        icap_cs  = 1'b1;
        icap_rw  = 1'b1;
        cnt_bitst = 4'h0;
      end else
      begin
        case(cnt_bitst)
            4'd0: begin
		   d = 32'hFFFFFFFF; // Dummy Word
	           icap_cs = 1'b0;
		   icap_rw = 1'b0;
		  end
            // using registers for now
            4'd1: d = 32'hFFFFFFFF; // Dummy Word
            4'd2: d = 32'hAA995566; // Sync Word
            4'd3: d = 32'h20000000; // Type 1 NO OP
            4'd4: d = 32'h30020001; // Type 1 Write 1 Word to WBSTAR
            4'd5: d = 32'h00000000; // Warm Boot Start Address
            4'd6: d = 32'h20000000; // Type 1 NO OP
            4'd7: d = 32'h30008001; // Type 1 Write 1 Words to CMD
            4'd8: d = 32'h0000000F; // IPROG Command
            4'd9: d = 32'h20000000; // Type 1 NO OP
            4'd10: d = 32'hFFFFFFFF; // Dummy Word
            // Bye, bye
            default: begin
	               icap_cs = 1'b1;
		       icap_rw = 1'b1;
		       d = 32'h20000000; // Type 1 NO OP
		     end
          endcase;

          if (cnt_bitst<11)
	  begin
	     icap_ram0[cnt_bitst] = d[31:24];
	     icap_ram1[cnt_bitst] = d[23:16];
	     icap_ram2[cnt_bitst] = d[15:8];
	     icap_ram3[cnt_bitst] = d[7:0];
	  end

         if(cnt_bitst != 4'ha)
	 begin
            cnt_bitst = cnt_bitst + 1;
         end

        end;  // if go
   end;  // always

   assign bit_swapped[31:24] = { d[24],d[25],d[26],d[27],d[28],d[29],d[30],d[31]};
   assign bit_swapped[23:16] = { d[16],d[17],d[18],d[19],d[20],d[21],d[22],d[23]};
   assign bit_swapped[15:8]  = { d[8],d[9],d[10],d[11],d[12],d[13],d[14],d[15]};
   assign bit_swapped[7:0]   = { d[0],d[1],d[2],d[3],d[4],d[5],d[6],d[7]};

/*     
   infer_sram #(17, 8, 131072)
   ram(.clk(ram_clock),
       .we(ram_we),
       .oe(ram_oe),
       .address(sbus_address[16:0]),
       .data(sbus_data)
       );
 */     
endmodule
