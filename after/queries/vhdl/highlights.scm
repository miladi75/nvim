; extends
;
; Managed by setup_vhdl_colors.py — do not edit by hand.
;
; Only @function.vhdl carries a hardcoded color (defined in lua/chadrc.lua
; under base46.hl_add). Every other rule reuses a native capture so it follows
; the active colorscheme:
;
;   s_*, v_*, g_*, c_*, enums    -> @number       (theme's number color)
;   t_*, sl/slv, to_*, *_lib     -> @type.builtin (theme's std_logic color)
;   port *_i/*_o, local signals  -> not captured  (theme's identifier color)

; ── Custom-colored prefixes (priority 120) ──

; Functions and procedures: f_*, pd_*
((identifier) @function.vhdl
  (#match? @function.vhdl "\\c\\v^(f|pd)_")
  (#set! priority 120))

; ── Native type color: same as std_logic / std_logic_vector (priority 115) ──

; User-defined types: t_*
((identifier) @type.builtin
  (#match? @type.builtin "\\c^t_")
  (#set! priority 115))

; Type aliases sl, slv and to_* conversions (to_slv, to_unsigned, to_int, ...)
((identifier) @type.builtin
  (#match? @type.builtin "\\c\\v^(sl|slv|to_\\w+)$")
  (#set! priority 115))

; ...and again as library_function: the parser heuristically reclassifies
; to_* call names, so to_slv(x) is not an (identifier) node at all. Without
; this it falls through to the parser's own @function.builtin.
((library_function) @type.builtin
  (#match? @type.builtin "\\c\\v^(sl|slv|to_\\w+)$")
  (#set! priority 115))

; Library references: common_lib, work_lib, ...
((identifier) @type.builtin
  (#match? @type.builtin "\\c_lib$")
  (#set! priority 115))

; ...and the unit selected off one: common_lib.thing
; @_lib is a helper capture (leading underscore = not highlighted), it only
; constrains the match to names whose first part is a library.
((name
   (identifier) @_lib
   (selection
     (identifier) @type.builtin))
  (#match? @_lib "\\c_lib$")
  (#set! priority 115))

; ...and the package in a use clause: use common_lib.common_pkg.all
((selected_name
   library: (identifier) @_lib
   package: (identifier) @type.builtin)
  (#match? @_lib "\\c_lib$")
  (#set! priority 115))

; ── Native number color: same as 1024 / '0' / true (priority 115) ──

; State machines s_*, variables v_*, generics g_*, constants c_*
((identifier) @number
  (#match? @number "\\c\\v^(s|v|g|c)_")
  (#set! priority 115))

; Enum literals: type t_state is (UNDEF, SOF, ...)
((enumeration_type_definition
   (enumeration_literal
     (identifier) @number))
  (#set! priority 110))
