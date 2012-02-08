require 'fileutils'
require 'rexml/document'

module Xcodeproj
  class Workspace
    def initialize(*projpaths)
      @projpaths = projpaths
    end

    def self.new_from_xcworkspace(path)
      begin
        from_s(File.read(File.join(path, 'contents.xcworkspacedata')))
      rescue Errno::ENOENT
        new
      end
    end

    def self.from_s(xml)
      document = REXML::Document.new(xml)
      projpaths = document.get_elements("/Workspace/FileRef").map do |node|
        node.attribute("location").to_s.sub(/^group:/, '')
      end
      new(*projpaths)
    end

    attr_reader :projpaths

    def <<(projpath)
      @projpaths << projpath
    end

    def include?(projpath)
      @projpaths.include?(projpath)
    end

    TEMPLATE = %q[<?xml version="1.0" encoding="UTF-8"?><Workspace version="1.0"></Workspace>]

    def to_s
      REXML::Document.new(TEMPLATE).tap do |document|
        @projpaths.each do |projpath|
          document.root << REXML::Element.new("FileRef").tap do |el|
            el.attributes['location'] = "group:#{projpath}"
          end
        end
      end.to_s
    end

    def save_as(path)
      FileUtils.mkdir_p(path)
      File.open(File.join(path, 'contents.xcworkspacedata'), 'w') do |out|
        out << to_s
      end
    end
  end
end
