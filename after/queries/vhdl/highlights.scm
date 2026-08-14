; extends
;
; Managed by setup_vhdl_colors.py — do not edit by hand.
;
; Only @state.vhdl, @vprefix.vhdl and @function.vhdl carry a hardcoded color
; (defined in lua/chadrc.lua under base46.hl_add). Every other rule reuses a
; native capture so it follows the active colorscheme:
;
;   g_*, c_*, enum literals     -> @number       (theme's number color)
;   t_*, sl/slv/to_slv, *_lib   -> @type.builtin (theme's std_logic color)
;   port *_i/*_o, local signals -> not captured  (theme's identifier color)

; ── Custom-colored prefixes (priority 120) ──

; Functions: f_*
((identifier) @function.vhdl
  (#match? @function.vhdl "\\c^f_")
  (#set! priority 120))

; Functions: pd_*
((identifier) @function.vhdl
  (#match? @function.vhdl "\\c^pd_")
  (#set! priority 120))

; Variables: v_*
((identifier) @vprefix.vhdl
  (#match? @vprefix.vhdl "\\c^v_")
  (#set! priority 120))

; State machines: s_*  — priority 120 also wins inside enum literal lists,
; so s_idle keeps this color while UNDEF/SOF take the native number color.
((identifier) @state.vhdl
  (#match? @state.vhdl "\\c^s_")
  (#set! priority 120))

; ── Native type color: same as std_logic / std_logic_vector (priority 115) ──

; User-defined types: t_*
((identifier) @type.builtin
  (#match? @type.builtin "\\c^t_")
  (#set! priority 115))

; Type aliases: sl, slv, to_slv
((identifier) @type.builtin
  (#match? @type.builtin "\\c\\v^(sl|slv|to_slv)$")
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

; ── Native number color: same as 1024 / '0' / true (priority 115) ──

; Generics: g_*
((identifier) @number
  (#match? @number "\\c^g_")
  (#set! priority 115))

; Constants: c_*
((identifier) @number
  (#match? @number "\\c^c_")
  (#set! priority 115))

; Enum literals: type t_state is (UNDEF, SOF, ...)
; Priority 110 keeps this below the s_* rule above.
((enumeration_type_definition
   (enumeration_literal
     (identifier) @number))
  (#set! priority 110))
