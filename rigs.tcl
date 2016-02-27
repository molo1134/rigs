
bind pub - !rig rig_pub
bind msg - !rig rig_msg

set rigscsv "rigs.csv"

proc rig_msg {nick uhand handle input} {
  set rig [sanitize_string [string trim ${input}]]
  putlog "rig msg: $nick $uhand $handle $rig"
  set output [getrig $rig]
  set output [split $output "\n"]

  foreach line $output {
    putmsg $nick "$line"
  }
}

proc rig_pub { nick host hand chan text } {
  set rig [sanitize_string [string trim ${text}]]
  putlog "rig pub: $nick $host $hand $chan $rig"
  set output [getrig $rig]
  set output [split $output "\n"]

  foreach line $output {
    putchan $chan "$line"
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

    if {[regexp -- {^#} $line]} {
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

    if {[regexp -nocase -- $rxp $rig]} {
      close $csvfile
      return "$manuf $model: $desc"
    }
  }
  close $csvfile
  return "not found"
}
