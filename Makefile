INSTALL_PREFIX=/usr/local/openresty

PREFIX ?=          /usr/local/openresty
LUA_LIB_DIR ?=     $(PREFIX)/lualib
INSTALL ?= install

.PHONY: all install

all: ;

install: all
	$(INSTALL) -d $(LUA_LIB_DIR)/hawk
	$(INSTALL) lib/*.lua $(LUA_LIB_DIR)/hawk

