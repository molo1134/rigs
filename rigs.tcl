
bind pub - !rig rig_pub
bind msg - !rig rig_msg

set rigscsv "rigs.csv"

proc rig_msg {nick uhand handle input} {
  set rig [sanitize_string [string trim ${input}]]
  set rig [encoding convertfrom utf-8 ${rig}]
  putlog "rig msg: $nick $uhand $handle $rig"
  set output [getrig $rig]
  set output [split $output "\n"]

  foreach line $output {
    if { [string match -nocase "*potato*" $line] } {
      # this is a hack to work around tcl's lack of support for unicode above
      # U+FFFF.
      putmsg $nick "$line"
    } else {
      putmsg $nick [encoding convertto utf-8 "$line"]
    }
  }
}

proc rig_pub { nick host hand chan text } {
  set rig [sanitize_string [string trim ${text}]]
  set rig [encoding convertfrom utf-8 ${rig}]
  putlog "rig pub: $nick $host $hand $chan $rig"
  set output [getrig $rig]
  set output [split $output "\n"]

  foreach line $output {
    if { [string match -nocase "*potato*" $line] } {
      # this is a hack to work around tcl's lack of support for unicode above
      # U+FFFF.
      putchan $chan "$line"
    } else {
      putchan $chan [encoding convertto utf-8 "$line"]
    }
  }
}

proc getrig {rig} {
  global rigscsv

  if { ![file exists $rigscsv] } {
    return ""
  }

  set csvfile [open $rigscsv r]
  while {![eof $csvfile]} {

    set line [gets $csvfile]

    if { ( [string match -nocase "*potato*" $line] == 0) } {
      # this is a hack to work around tcl's lack of support for unicode above
      # U+FFFF.
      set line [encoding convertfrom utf-8 $line]
    }

    if {[regexp -- {^#} $line]} {
      continue;
    }

    if {[regexp -- {^\s*$} $line]} {
      continue;
    }

    set fields [split $line ","]

    set rxp [lindex $fields 0]
    set manuf [lindex $fields 1]
    set model [lindex $fields 2]
    set link [lindex $fields 3]
    set manualpdf [lindex $fields 4]

    set re {^[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,\"([^\"]*)\"$}
    regexp $re $line -> desc

    if {[string match -nocase "*${rig}*" $model]} {
      close $csvfile
      return "$manuf $model: $desc"
    }

    if {[regexp -nocase -- $rxp $rig]} {
      close $csvfile
      return "$manuf $model: $desc"
    }
  }
  close $csvfile
  return "not found; pull requests accepted: http://github.com/molo1134/rigs/"
}
