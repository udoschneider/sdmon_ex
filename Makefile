CFLAGS  = -Wall -g -D_REENTRANT -DVERSION="\"$(VERSION_STRING)\"" -static
LDFLAGS =

PREFIX = $(MIX_APP_PATH)/priv

SRC = c_src/sdmon.c
OBJ = sdmon.o
BIN = $(PREFIX)/sdmon

calling_from_make:
	mix compile

all: $(PREFIX) $(BIN)

$(PREFIX):
	mkdir -p $(PREFIX)

$(BIN): $(SRC)
	$(CC) $(CFLAGS) -o $(BIN) $^ $(LDFLAGS)	

clean:
	rm -f $(BIN)

.PHONY: all clean
