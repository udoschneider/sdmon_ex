# Bundled sdmon: https://github.com/Ognian/sdmon
# Pinned to master commit 8a70aed673f4b319972b3a2cfac043e3b171653a (2026-07-21),
# which is newer than the latest release v0.9.0.
VERSION_STRING ?= 0.9.0-8a70aed

CFLAGS  = -Wall -g -D_REENTRANT -DVERSION="\"$(VERSION_STRING)\"" -Ic_src -ffunction-sections
LDFLAGS = -lm -Wl,--gc-sections -static

PREFIX = $(MIX_APP_PATH)/priv

SRC = c_src/sdmon.c c_src/json.c c_src/json-builder.c
HDR = c_src/json.h c_src/json-builder.h
BIN = $(PREFIX)/sdmon

calling_from_make:
	mix compile

all: $(PREFIX) $(BIN)

$(PREFIX):
	mkdir -p $(PREFIX)

$(BIN): $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o $(BIN) $(SRC) $(LDFLAGS)

clean:
	rm -f $(BIN)
	-rmdir $(PREFIX) 2>/dev/null || true

.PHONY: all clean
