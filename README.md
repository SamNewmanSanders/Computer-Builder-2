# Computer Builder 2

A second attempt at a logic-gate simulator for building a computer from the ground up, starting from basic gates and working towards a CPU that can run real instructions.

## The previous implementation

The first version is at [SamNewmanSanders/Computer-Builder](https://github.com/SamNewmanSanders/Computer-Builder). I wrote it in September 2025 in C++20, with SFML 3 for graphics and TGUI for the buttons and menus. I've got substantially better at computer science since then, and this project is a chance to redo it properly.

### What it simulated

- Three primitive gates: **AND**, **OR** and **NOT**.
- Each wire carried a single bit. I planned to add tri-state logic but never got further than defining the types (`DISCONNECTED` and `ERROR` alongside `ON` and `OFF`). I haven't yet decided whether to add it in this version; it depends on how much it would complicate things.
- Every gate had a delay of one simulation step, and the circuit was updated one step at a time from a double-buffered vector of wire values.
- **Hierarchy:** a finished circuit could be saved and then placed inside another circuit as a reusable component, nested to any depth.

### What it could do

- Place gates, input ports and output ports on a snapping grid.
- Draw wires with corners between pins, and cancel a part-way placement.
- Toggle inputs by clicking, or by dragging across several at once.
- Step the simulation manually or let it run continuously, with wires coloured by their value.
- Save a circuit to a JSON file and load it back through a dropdown as a subcircuit.

With this I built NAND, NOR, XOR, half and full adders, a 4-bit adder, an SR latch, a D latch, a D flip-flop, 1-bit and 4-bit registers, 2-to-1 and 4-to-1 multiplexers, a delay line, and finally a small "ALU + registers" circuit. That circuit fed two 4-bit registers through an adder and a multiplexer so it could add and increment numbers.

### What it was missing

- Deleting or moving anything once it had been placed.
- Opening a component to see or edit what's inside. Saved files stored only the logic, not the layout, so a saved circuit couldn't be reopened for editing.
- Refreshing the component dropdown after saving. The program had to be restarted to see new components.
- Multi-bit wires (buses), tri-state buffers, and any way for several components to share one wire. This is why the multiplexers grew so large.
- Panning, zooming, or any number displays (hex, 7-segment, two's complement).
- A portable build. The CMake file and font path were hard-coded to my Windows setup. This time I'm building for Linux, developing on both an Arch laptop and an Ubuntu laptop.

### Scaling was the real problem

The simulator worked, but it didn't scale. I never simulated anything bigger than the adder-with-registers circuit above. The main reasons:

- **Linear lookups everywhere.** To find each component's inputs, every step scanned the full list of connections. Finding where a component's outputs were stored meant summing over all the components before it. Together this made each step roughly quadratic in circuit size.
- **Unnecessary copying.** Some helper functions took the whole circuit by value. The renderer called one of them for every wire on every frame, so the entire circuit, including every nested subcircuit, was copied hundreds of times per frame.
- **Recursive subcircuits.** Each subcircuit instance kept its own copy of its definition and state, re-read its JSON file when loaded, and was stepped recursively every tick.
- **Simulation tied to rendering.** The simulation advanced one step per drawn frame. A signal could only travel through about 60 gates per second, far too slow for anything CPU-sized.

## Plans for this version

Some initial ideas for what I want to improve:

1. **Efficient data structures and algorithms.** Use what I've learnt since to avoid linear lookups and repeated work: precompute indices, use the right containers, and stop allocating and copying in the hot loop.
2. **Architectural speed-ups.** For example, only simulate gates whose inputs have changed (event-driven simulation), and do preprocessing such as flattening the component hierarchy into one flat list of gates before running, so the simulation loop itself is as cheap as possible.
3. **Storing data between runs.** The previous version used JSON files. I want to look at the options here, including how to store layout as well as logic so circuits can be reopened and edited.
4. **A much better-looking GUI, built with AI help.** Let AI do most of the work on the frontend so it looks far better, while I focus on the more interesting part: the backend simulation.
5. **A hand-written Makefile instead of CMake.** I want experience with Make itself. The project only targets Linux, so CMake's cross-platform support isn't needed, and libraries such as SFML can be found with `pkg-config` on both Arch and Ubuntu.

The long-term goal is to add buses (possibly with tri-state logic), then registers, memory and a control unit, and eventually simulate a simple instruction set.
