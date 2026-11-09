CXX 	:= g++
# Enable compiler warnings and debugging information
CXXFLAGS := -std=c++20 -Wall -Wextra -g 

build/computer-builder: src/main.cpp 
	mkdir -p  build 				 	# Make parent directories if they don't exist
	$(CXX) $(CXXFLAGS) src/main.cpp -o build/computer-builder


run: build/computer-builder
	./build/computer-builder

clean:
	rm -rf build						# Recursive, force

# .PHONY is a rule of its own: its prerequisites are targets that aren't real files,
# so they always run. Must be on its own line, not merged into another rule.
.PHONY: run clean