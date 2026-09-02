#html.link(rel: "stylesheet", href: "../css/style.css")
#html.link(rel: "stylesheet", href: "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css")

#html.elem("style")[figure { text-align: center; margin: 20px 0; } figure img { width: 70%; display: inline-block; }]

#html.elem("a", attrs: (href: "../index.html", style: "display:block;margin-bottom:20px;color:#8BE9FD;text-decoration:none;"))[← Back to home]

#html.elem("h1")[Reverse-Engineering an ASIC]

#html.elem("p", attrs: (style: "text-align:center;color:#6272A4;font-size:14px;"))[From a Binary GDS File to `(* TWO STARS *)`]
#figure(
  image("asic-puzzle/morse_3d.gif", width: 100%),
)

A complete walkthrough of the Jane Street ASIC puzzle using KLayout, z3, and Icarus Verilog.

#html.elem("div", attrs: (style: "border-left:2px solid #6272A4;padding-left:12px;margin:20px 0;"))[_TL;DR._ We took a binary layout file (`puzzle.gds`) with no schematic, extracted a full Verilog netlist from the geometry, simulated it to verify bit-exact match against a reference waveform, and then used a SAT solver (z3) to find the 122-bit input sequence that drives `success` high. The reward: the design prints `(* TWO STARS *)` — an OCaml-style comment congratulating the solver. My friend (#link("https://guangyuhu.me")[Guangyu Hu (Gary)]) shared some other easter eggs that I haven't found, hidden in the timestamps and constants of the problem statement; they are not covered in this writeup.]

#html.elem("h2")[Introduction]

Jane Street published an ASIC reverse-engineering puzzle (#link("https://blog.janestreet.com/can-you-reverse-engineer-an-asic/")[blog post]).

Task: Figure out what input bit sequence on `I` makes the `success` output pin go high and find as many easter eggs as you can.

#html.elem("h2")[The Approach]

#html.elem("h3")[Write in advance]

Before I started the puzzle, I opened the `puzzle.gds` file with KLayout, which could render zoomed versions of each part in detail and check each layer separately. At this stage, I found that the standard cells used are from `sky130_fd_sc_hd`. I had seen this library in the `test` folder of the OpenRoad project (which contains a LEF file), so I directly used this library later in the analysis. I also viewed the simulation results in `example_inputs.vcd` using GTKWave, but I don't think it really helps much... just for enjoying fancy waves.

I don't know much about physical design from my background, but the warmup example gives hints. As a newbie, my direct solution is very intuitive: I would like to identify all the cells first, then find their connections, and from the technology library we could know each cell's Boolean representation. At this stage, we should be able to write a netlist, which could be simulated, synthesized, etc.

Then we need to make sure every step mentioned above is "doable".

The final strategy in the solution has four phases:

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  [*Phase*], [*Operation*], [*Output*],
  [1. Extract], [Walk GDS geometry + LEF pin info to determine cell-to-cell wiring.], [Verilog netlist],
  [2. Verify], [Replay the sample VCD and compare outputs bit-for-bit.], [624/624 checks pass],
  [3. Solve], [Bounded model checking with z3 to find the winning input.], [122-bit sequence],
)

#html.elem("h2")[Phase 1: Extracting a netlist from the geometry]

#html.elem("h3")[Strategy]

Three operations reverse the place-and-route process:

+ _Identify the metal stack_ — determine which GDS `(layer, datatype)` pairs correspond to `li1`, `met1`, ..., `met5`, and which VIA cells connect adjacent layers.
+ _Build connected components per layer_ — for each metal layer, flatten all polygons (top-level routing + every cell's internal metal, transformed by its placement) and merge touching/overlapping ones via `Region.merge()`. Each resulting "blob" is one electrical net on that layer.
+ _Label blobs with cell pins via point-in-polygon_ — for each placed cell's each pin, transform the pin's LEF rectangle into world coordinates and find which merged blob contains the pin's center point (`Polygon.inside(Point)`).

Cross-layer connections are resolved by walking every VIA cell: each VIA's bottom-layer metal shape and top-layer metal shape identify two blobs that are actually the same net. A union-find data structure merges these into final net IDs.

#html.elem("h3")[Visualizing the extraction step by step]

The following figures (from the actual GDS geometry data in `json` format, rendered using `matplotlib`, data can be dumpped from KLayout directly, those fancy gifs are generated with the help of GLM 5.2) show what each operation sees. Throughout, the color scheme is:

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  [*Color*], [*Layer*], [*Role*],
  [#text(fill: rgb("ff6600"))[Orange]], [`li1`], [local interconnect wire layer inside cells],
  [#text(fill: rgb("0066ff"))[Blue]], [`met1`], [cell-internal routing + short connections],
  [#text(fill: rgb("00dd44"))[Green]], [`met2`], [the primary horizontal/vertical routing],
  [#text(fill: rgb("ff0066"))[Red]], [`met3`], [longer-distance routing],
  [#text(fill: rgb("ffdd00"))[Yellow]], [`met4`], [metal 4 — sparsely used (also used for via dots in the vias figure)],
  [#text(fill: rgb("ff00ff"))[Magenta]], [`met5`], [metal 5 — top metal, the power grid],
)

#figure(
  image("asic-puzzle/gif1_layer_buildup.gif", width: 100%),
  caption: [All six metal layers overlaid: orange `li1` at the bottom of the stack, blue `met1`, green `met2`, red `met3`, yellow `met4`, and magenta `met5`. The dense central band is the placed standard cells; the thin horizontal magenta stripes at regular intervals are the `met5` power grid.],
)

At this zoom level, the design looks like a solid block, you can see overall structure (the power grid stripes, the main core area, the INTERNAL-cell row below) but cannot distinguish individual cells, pins, or wires. The next figures peel back layers to reveal how the routing is constructed.

#figure(
  image("asic-puzzle/phase1_2_met1.png", width: 60%),
  caption: [Metal 1 only. Each small blue rectangle is a piece of `met1`, either inside a standard cell (connecting transistors to pins) or a short routing segment between adjacent cells. The thin horizontal bands are the `VPWR` and `VGND` power rails that every cell abuts to.],
)

`met1` is the lowest real metal. It carries the power rails (the wide horizontal stripes at the top and bottom of each cell row) and the shortest routing connections. When we merge all touching `met1` shapes, the power rails form one giant connected blob, which is why power-net matching must be excluded from signal extraction.

#figure(
  image("asic-puzzle/phase1_3_met2.png", width: 60%),
  caption: [Metal 2 only. Green stripes running horizontally and vertically are the `met2` routing, this is the workhorse layer for signal connections between cells that are not adjacent. Each green segment is a wire; where two segments touch, they are the same electrical net. The vertical green stripes on the right edge connect to the `O[7:0]` output pins. And also on the bottom left of this layer, there's a JS logo...],
)

#figure(
  image("asic-puzzle/phase1_4_routing.png", width: 60%),
  caption: [Three routing layers overlaid: blue `met1`, green `met2`, red `met3`. Wherever two colors overlap, a via connects them. The interleaving of colors shows how signals travel: short hops on `met1`, longer runs on `met2` (green), and the longest distances on `met3` (red).],
)

#figure(
  image("asic-puzzle/phase1_5_zoom.png", width: 60%),
  caption: [A 20 × 20 µm zoom near the center of the chip, showing `li1` (orange), `met1` (blue), and `met2` (green). At this scale, individual standard cells are visible as clusters of orange `li1` rectangles. The wider blue and green shapes are routing wires. The tiny points where orange meets blue are pin-access points, exactly where the extractor's point-in-polygon test runs.],
)

This is the scale at which the extraction algorithm operates. The LEF gives us the exact `(x, y)` position of each pin. After transforming by the cell's placement, we search for the merged blob whose polygon contains that pin's center — linking the pin to its electrical net.

#figure(
  image("asic-puzzle/phase1_6_merged.png", width: 60%),
  caption: [`met1` after `Region.merge(True, 0)`: all touching blue shapes have been fused into connected blobs. Each blob is one electrical net on this layer. The large blob spanning the full width is the `VGND` power rail; similarly for `VPWR`. Signal nets are the smaller isolated blobs.],
)

#figure(
  image("asic-puzzle/phase1_7_vias.png", width: 60%),
  caption: [Blue `met1` shapes with yellow via1 cuts overlaid, plus green `met2` on top. Each yellow dot is a via — a physical plug that electrically connects a `met1` blob to the `met2` blob directly above it.],
)

#figure(
  image("asic-puzzle/layer_stack_3d.gif", width: 60%),
  caption: [A 3D visualization showing how vias connect layers.],
)

#html.elem("h2")[Phase 2: Verifying the extracted netlist]

#html.elem("h3")[Generating the cell library from Liberty]

Now we have connected all standard cells and formed a netlist. To do the simulation, the last thing we need to do is to "mark" all standard cells with their function. This is where the technology library gets involved. Every cell has a clearly defined Boolean function; we just need to extract it.

`gen_cell_lib.py` reads the `function:` field from `sky130hd_tt.lib` for every cell used in the netlist and emits one Verilog `assign` per cell:

From
```
cell (sky130_fd_sc_hd__o22a_2) {
    function : "(A1&B1) | (A2&B1) | (A1&B2) | (A2&B2)";
}
```
to
```verilog
module sky130_fd_sc_hd__o22a_2 (input A1, input A2, input B1, input B2, output X);
  assign X = (A1&B1) | (A2&B1) | (A1&B2) | (A2&B2);
endmodule
```

#html.elem("h3")[Building the replay testbench]

`vcd_to_tb.py` parses `example_inputs.vcd` and emits a Verilog testbench that drives `clk`, `rst_n`, `enable`, `I` to match the VCD exactly, then samples `O[7:0]` and `success` at every timestamp and compares against the recorded values.

#html.elem("h3")[Result: bit-exact match]

```
=== RESULT: 624/624 checks passed, 0 mismatches ===
*** ALL CHECKS PASSED ***
```

624 output samples across 3.1 µs of simulated time, all matching the reference VCD.

#html.elem("h3")[Output decodes as ASCII]

The recorded `O[7:0]` values spell a message (consecutive duplicates collapsed):

```
\0 T R Y   A G A I N \0 T R Y   A G A I N \0
```

The wrong-input message is literally _`TRY AGAIN`_ — confirming the extracted netlist is functionally identical to the original design.

#html.elem("h2")[Phase 3: Solving for the winning input]

#html.elem("h3")[Why brute force fails]

The design has 92 flip-flops (2#html.elem("sup")[92] states). Random sampling of 5,000 patterns × 150 cycles produced zero successes. The winning state requires a specific \~120-bit serial input.

#html.elem("h3")[Bounded model checking with z3]

`solve.py` unrolls the netlist for 150 cycles as a satisfiability problem:

+ Create one `z3.Bool` per net per cycle (739 × 151 ≈ 112k variables, where 739 is the number of wires).
+ Constrain every combinational cell output to its Liberty function at each cycle (including `conb_1` constants: `HI = 1`, `LO = 0`).
+ Constrain every DFF transition: `Q[t+1] = D[t]` when `rst_n = 1`, else reset value.
+ Fix `rst_n = 0` for cycles 0–2, `rst_n = 1` from cycle 3, `enable = 1` from cycle 4.
+ Leave `I[t]` as free variables (the search target).
+ Assert `success = 1` at some cycle in `[5, 150]`.

z3 returns `sat` in 7 seconds.

#html.elem("div", attrs: (style: "border-left:2px solid #8BE9FD;padding-left:12px;margin:20px 0;"))[_Key detail._ Every net must be constrained — including constants. The six `conb_1` cells (HI = 1, LO = 0) must be explicitly tied to fixed values at every cycle, or the solver can exploit them as free variables.]

#html.elem("h3")[Result]

The 122-bit winning input (cycles 4–125):

```
000000010101000010000000000001010101000000000000101000000100000100000010000010100001000000010000001000001001000101000000000
```

Verified in iverilog: `success` goes high at cycle 126, and the output changes from `TRY AGAIN` to:

```
(* TWO STARS *)
```

#html.elem("h2")[Easter eggs]

#html.elem("h3")[Four hidden output messages]

The output generator produces different messages depending on the input:

#table(
  columns: (1fr, auto, auto),
  align: (left, left, center),
  [*Input*], [*Output*], [*Discovery*],
  [All zeros (`I=0` every cycle)], [`EMPTY SKY`], [hidden],
  [All ones (`I=1` every cycle)], [`BIG BANG`], [hidden],
  [Any wrong random pattern], [`TRY AGAIN`], [in sample VCD],
  [The correct 122-bit input], [`(* TWO STARS *)`], [the answer],
)

Cosmic progression: _empty sky → big bang → try again → two stars._

`(* ... *)` is OCaml/SML block-comment syntax, Jane Street's house language.

#html.elem("h3")[Morse code in cell geometry]

36 empty placeholder cells (`INTERNAL_3`, `INTERNAL_7`) below the main core at `y = -53 µm` encode a Morse code message. The cell widths and gap sizes follow the standard 1:3:7 International Morse Code timing ratio:

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  [*Element*], [*Physical size*], [*Morse meaning*],
  [`INTERNAL_3`], [1.38 µm (3 sites)], [dot (`.`)],
  [`INTERNAL_7`], [4.14 µm (9 sites = 3×)], [dash (`-`)],
  [1.38 µm gap], [1× dot], [element gap],
  [4.14 µm gap], [3× dot], [letter gap],
  [9.66 µm gap], [7× dot], [word gap],
)

Decoded:

```
.--.  .  .-.   .-  .-.  .  -.  .-  --   .-  -..   .-  ...  -  .-.  .-
 P    E   R     A   R    E   N   A   M     A   D      A   S   T   R   A
```

#figure(
  image("asic-puzzle/morse_3d.gif", width: 100%),
  caption: [A 3D visualization of the encoded Morse code.],
)

#html.elem("p", attrs: (style: "font-weight:bold;text-align:center;color:#E6C079;margin-top:30px;"))[`(* TWO STARS *)`]
