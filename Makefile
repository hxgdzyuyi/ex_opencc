ERLANG_PATH:=$(shell erl -eval 'io:format("~s~n", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
OPENCC_PATH=priv/libopencc/src
DEPS_PATH=priv/libopencc/deps

CFLAGS=-g -fPIC -O3 -std=c++11
ERLANG_FLAGS=-I$(ERLANG_PATH)
OPENCC_FLAGS=-I$(OPENCC_PATH) \
	-I$(DEPS_PATH)/rapidjson-1.1.0 \
	-I$(DEPS_PATH)/marisa-0.2.6/include \
	-I$(DEPS_PATH)/darts-clone-0.32 \
	-I$(DEPS_PATH)/marisa-0.2.6/lib \
	-DPKGDATADIR=\"$(abspath priv/data)\"

CC?=clang
CXX?=clang++
EBIN_DIR=ebin

ifeq ($(shell uname),Darwin)
	OPTIONS=-dynamiclib -undefined dynamic_lookup -std=c++11
	ifeq ($(shell uname -m),arm64)
		OPTIONS+=-arch arm64
	endif
else
	OPTIONS=-lstdc++
endif

TARGET=priv/ex_opencc_nif.so
SRC=c_src/ex_opencc_nif.cpp

# Marisa library sources
MARISA_SRCS=$(DEPS_PATH)/marisa-0.2.6/lib/marisa/grimoire/io/mapper.cc \
	$(DEPS_PATH)/marisa-0.2.6/lib/marisa/grimoire/io/reader.cc \
	$(DEPS_PATH)/marisa-0.2.6/lib/marisa/grimoire/io/writer.cc \
	$(DEPS_PATH)/marisa-0.2.6/lib/marisa/grimoire/trie/louds-trie.cc \
	$(DEPS_PATH)/marisa-0.2.6/lib/marisa/grimoire/trie/tail.cc \
	$(DEPS_PATH)/marisa-0.2.6/lib/marisa/grimoire/vector/bit-vector.cc \
	$(DEPS_PATH)/marisa-0.2.6/lib/marisa/keyset.cc \
	$(DEPS_PATH)/marisa-0.2.6/lib/marisa/agent.cc \
	$(DEPS_PATH)/marisa-0.2.6/lib/marisa/trie.cc

# OpenCC source files that need to be compiled
OPENCC_SRCS=$(OPENCC_PATH)/Config.cpp \
	$(OPENCC_PATH)/Conversion.cpp \
	$(OPENCC_PATH)/ConversionChain.cpp \
	$(OPENCC_PATH)/Converter.cpp \
	$(OPENCC_PATH)/Dict.cpp \
	$(OPENCC_PATH)/DictConverter.cpp \
	$(OPENCC_PATH)/DictEntry.cpp \
	$(OPENCC_PATH)/DictGroup.cpp \
	$(OPENCC_PATH)/Lexicon.cpp \
	$(OPENCC_PATH)/MarisaDict.cpp \
	$(OPENCC_PATH)/MaxMatchSegmentation.cpp \
	$(OPENCC_PATH)/Segmentation.cpp \
	$(OPENCC_PATH)/SerializedValues.cpp \
	$(OPENCC_PATH)/TextDict.cpp \
	$(OPENCC_PATH)/UTF8Util.cpp

ALL_SRCS=$(SRC) $(OPENCC_SRCS) $(MARISA_SRCS)

all:
	mix compile

libopencc_src:
	git submodule update --init --recursive

ex_opencc: clean libopencc_src $(TARGET)

$(TARGET):
	mkdir -p priv && \
		$(CXX) $(CFLAGS) $(ERLANG_FLAGS) $(OPENCC_FLAGS) -shared  $(OPTIONS) -DLOGGER_LEVEL=LL_ERROR $(ALL_SRCS) -o $@

clean:
	rm -rf priv/ex_opencc_nif.*

.PHONY: all clean libopencc_src ex_opencc
