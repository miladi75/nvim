; extends

; ── Prefix patterns (highest priority) ──

; Functions: f_*
((identifier) @function.vhdl
  (#match? @function.vhdl "\\c^f_")
  (#set! priority 120))

; Functions: pd_*
((identifier) @function.vhdl
  (#match? @function.vhdl "\\c^pd_")
  (#set! priority 120))

; Constants: c_*
((identifier) @constant.vhdl
  (#match? @constant.vhdl "\\c^c_")
  (#set! priority 120))

; Variables: v_*
((identifier) @vprefix.vhdl
  (#match? @vprefix.vhdl "\\c^v_")
  (#set! priority 120))

; Generics: g_*
((identifier) @generic.vhdl
  (#match? @generic.vhdl "\\c^g_")
  (#set! priority 120))

; State-machine names/signals: s_*
((identifier) @state.vhdl
  (#match? @state.vhdl "\\c^s_")
  (#set! priority 120))

; User-defined types: t_*  → capture as @type.builtin so they render in the
; exact same color as native types (std_logic, std_logic_vector, ...).
((identifier) @type.builtin
  (#match? @type.builtin "\\c^t_")
  (#set! priority 120))

; ── Port signals: identifiers ending with _i or _o (everywhere) ──
((identifier) @port_signal.vhdl
  (#match? @port_signal.vhdl "\\c_[io]$")
  (#set! priority 110))

; ── Broad catch-all: every identifier that isn't prefixed or a port ──
; Priority 105 beats base @variable (100); prefix rules (120) and
; port rule (110) still win where they match.
((identifier) @local_signal.vhdl
  (#not-match? @local_signal.vhdl "\\c^(s_|v_|f_|pd_|c_|g_|t_)")
  (#not-match? @local_signal.vhdl "\\c_[io]$")
  (#set! priority 105))

; ── Local signals (non-_i/_o, various contexts) ──

; Signal declarations
((signal_declaration
   (identifier_list
     (identifier) @local_signal.vhdl))
  (#set! priority 100))

; Simple waveform assignment LHS
((simple_waveform_assignment
   (name
     (identifier) @local_signal.vhdl))
  (#set! priority 100))

; Concurrent simple signal assignment LHS
((concurrent_simple_signal_assignment
   (name
     (identifier) @local_signal.vhdl))
  (#set! priority 100))

; Port declarations inside entity (interface_declaration)
((interface_declaration
   (identifier_list
     (identifier) @local_signal.vhdl))
  (#set! priority 100))

((interface_signal_declaration
   (identifier_list
     (identifier) @local_signal.vhdl))
  (#set! priority 100))

; Entity instantiation port map – actual part (right of =>)
((port_map_aspect
   (association_list
     (association_element
       (conditional_expression
         (simple_expression
           (name
             (identifier) @local_signal.vhdl))))))
  (#set! priority 100))

; Generic map – actual part (right of =>)
((generic_map_aspect
   (association_list
     (association_element
       (conditional_expression
         (simple_expression
           (name
             (identifier) @local_signal.vhdl))))))
  (#set! priority 100))
