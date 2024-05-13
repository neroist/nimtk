import std/sequtils
import std/tables

import ../src/nimtk/widgets
import ../src/nimtk/wm
import ../src/nimtk

const
  countrynames = [
    "Argentina",
    "Australia",
    "Belgium",
    "Brazil",
    "Canada",
    "China",
    "Denmark",
    "Finland",
    "France",
    "Greece",
    "India",
    "Italy",
    "Japan",
    "Mexico",
    "Netherlands",
    "Norway",
    "Spain",
    "Sweden",
    "Switzerland"
  ]

  populations = {
    "ar": 41000000,
    "au": 21179211,
    "be": 10584534,
    "br": 185971537,
    "ca": 33148682,
    "cn": 1323128240,
    "dk": 5457415,
    "fi": 5302000,
    "fr": 64102140,
    "gr": 11147000,
    "in": 1131043000,
    "it": 59206382,
    "jp": 127718000,
    "mx": 106535000,
    "nl": 16402414,
    "no": 4738085,
    "es": 45116894,
    "se": 9174082,
    "ch": 7508700
  }.toTable()

  countrycodes = toSeq populations.keys

let
  tk = newTk()
  root = tk.getRoot()

  mainframe = root.newFrame()

root.title = "Country selector listbox example"
root.geometry(width=800, 600)

let
