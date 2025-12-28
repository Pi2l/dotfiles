# Compiler and flags
CXX      := g++
CXXFLAGS := -O2 -Wall -Wextra -std=c++17

# Project layout
TARGET   := get-cpu-energy
SRCS     := main.cc src/read_energy.cc
OBJS     := $(SRCS:.cc=.o)

# Install paths
PREFIX   ?= $(HOME)/.local
BINDIR   := $(PREFIX)/bin

.PHONY: all clean install uninstall

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^

%.o: %.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

install: $(TARGET)
	mkdir -p $(BINDIR)
	cp $(TARGET) $(BINDIR)/$(TARGET)
	sudo chown root $(BINDIR)/$(TARGET)
	sudo chmod u+s $(BINDIR)/$(TARGET)

uninstall:
	rm -f $(BINDIR)/$(TARGET)

clean:
	rm -f $(TARGET) $(OBJS)
