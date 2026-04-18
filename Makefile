SDK = $(shell xcrun --sdk iphoneos --show-sdk-path)

CFLAGS = -isysroot $(SDK) -arch arm64 -fobjc-arc -framework UIKit -framework Foundation -framework CoreGraphics

all: build/FloatingBubble.dylib

build/FloatingBubble.dylib: src/tweak.m | build
	clang $(CFLAGS) -dynamiclib src/tweak.m -o build/FloatingBubble.dylib

build:
	mkdir -p build

clean:
	rm -f build/FloatingBubble.dylib
