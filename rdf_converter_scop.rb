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

    @@fa_doms = {}
    @@sf_doms = {}
    @@rels = {}
    @@descs = {}

    def self.rdf(file_class, file_desc, prefixes = false)
      File.open(file_desc) do |f|
        while line = f.gets
          /^(\d+)\s(.+)$/ =~ line
          @@descs[$1] = $2
        end
      end
      File.open(file_class) do |f|
        SCOP.prefixes if $prefixes
        while line = f.gets
          unless /^#/ =~ line
            ary = parse(line)
            @@fa_doms.key?(ary[0]) ? @@fa_doms[ary[0]] << ary[1..4] + [ary[10]] : @@fa_doms[ary[0]] = [ary[1..4] + [ary[10]]]
            @@sf_doms.key?(ary[5]) ? @@sf_doms[ary[5]] << ary[6..10] : @@sf_doms[ary[5]] = [ary[6..10]]
          end
        end
      end
      construct_turtle
    end

    def self.parse(line)
      ary = []
      if /^#/ =~ line
      elsif /^\d/ =~ line
        ary = line.split(" ")
        scopcla = Hash[*ary[-1].split(",")
                               .map{|e| e.split("=").map{|e2| e2.to_sym}}
                               .flatten]
        construct_scop_tree(scopcla)
      else
        raise "Unknown format.\n"
      end
      ary
    end

    def self.construct_scop_tree(h)
      h.to_a.each do |k, v|
        case k
        when :TP
          @@rels.key?(v) ? @@rels[v] << h[:CL] : @@rels[v] = [h[:CL]]
        when :CL
          @@rels.key?(v) ? @@rels[v] << h[:CF] : @@rels[v] = [h[:CF]]
        when :CF
          @@rels.key?(v) ? @@rels[v] << h[:SF] : @@rels[v] = [h[:SF]]
        end
      end 
    end

    def self.construct_turtle
      @@fa_doms.each do |e|
        p e
      end
    end
#        Hash[*scopcla.split(",").map{|e| e.split("=")}.flatten]

    def construct_turtle(fa_domid, fa_pdbid, fa_pdbreg, fa_uniid, fa_unireg,
                         sf_domid, sf_pdbid, sf_pdbreg, sf_uniid, sf_unireg,
                         scopcla)



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

SCOP::StructuralClass.rdf(params["class"], params["description"]) if params["class"] && params["description"]
SCOP::StructuralClass.rdf(params["c"], params["d"])     if params["c"] && params["d"]


