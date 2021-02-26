#!/usr/bin/env ruby

require 'optparse'

module SCOP

  Prefixes = {
    "rdf" => "<http://www.w3.org/1999/02/22-rdf-syntax-ns#>",
    "rdfs" => "<http://www.w3.org/2000/01/rdf-schema#>",
    "skos" => "<http://www.w3.org/2004/02/skos/core#>",
    "prov" => "<http://www.w3.org/ns/prov#>",
    "pav" => "<http://purl.org/pav/>",
    "obo" => "<http://purl.obolibrary.org/obo/>",
    "mesh" => "<http://id.nlm.nih.gov/mesh/>",
    "dct" => "<http://purl.org/dc/terms/>",
    "pubmedid" => "<http://identifiers.org/pubmed/>",
    "pubmed" => "<http://rdf.ncbi.nlm.nih.gov/pubmed/>",
    "scop" => "http://scop.mrc-lmb.cam.ac.uk/term/8045338",
    "scop_idorg" => "http://identifiers.org/scop/"
  }

  def prefixes
    Prefixes.each do |pfx, uri|
      print "@prefix #{pfx}: #{uri} .\n"
    end
    puts "\n"
  end

  module_function :prefixes

  class StructuralClass

    def self.rdf(file, prefixes = false)
      File.open(file) do |f|
         
        f.gets
        SCOP.prefixes if $prefixes
        while line = f.gets
          ary = parse(line)
          puts ary
        end
      end
    end

    def self.parse(line)
      if /^#/ =~ line
      elsif /^\d/ =~ line
        line
      else
        raise "Unknown format.\n"
      end
    end
  end
end

params = ARGV.getopts('hpc:d:', 'help', 'prefixes', 'description', 'class')

if params["help"] || params["h"]
  help
  exit
end

$prefixes = true if params["prefixes"]
$prefixes = true if params["p"]

SCOP::StructuralClass.rdf(params["class"]) if params["class"]
SCOP::StructuralClass.rdf(params["c"])     if params["c"]


