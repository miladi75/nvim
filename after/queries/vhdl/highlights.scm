; extends

; Highlight user-defined VHDL subprogram names by prefix.
((identifier) @function.vhdl
  (#match? @function.vhdl "\\c^f_")
  (#set! priority 120))

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

; Signal identifiers (non-prefix rule): declarations and assignment LHS.
((signal_declaration
   (identifier_list
     (identifier) @signal.vhdl))
  (#set! priority 100))

((simple_waveform_assignment
   (name
     (identifier) @signal.vhdl))
  (#set! priority 100))

((concurrent_simple_signal_assignment
   (name
     (identifier) @signal.vhdl))
  (#set! priority 100))
