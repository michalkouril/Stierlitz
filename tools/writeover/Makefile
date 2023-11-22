CFLAGS = -O2
BIN = writeover

all :	$(BIN)

main : $(BIN).c
	$(CC) $(CFLAGS) -o $(BIN) $(BIN).c

clean :
	rm -f nul core *.o $(BIN) *~

check-syntax:
	$(CC) -o nul -Wall -S $(CHK_SOURCES)
