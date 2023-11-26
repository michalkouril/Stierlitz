ASM = qtasm/qtasm.exe
WINE = wine
BURNER = /usr/local/bin/ezotgdbg
BIN = stierlitz

all :	$(BIN)

stierlitz : $(BIN).asm
	$(WINE) $(ASM) -r $(BIN).asm build/$(BIN)

burn :
	$(BURNER) -w build/$(BIN).bin

burn2 :
	echo "Mount cy16 as /mnt/s (don't forget -o sync)"
	tools/writeover/writeover -i build/stierlitz.bin -o /mnt/s/I2C.BIN

clean :
	rm -f *.bin *.dat *.fix *.lst *.obj *.sym build/*.*
