require 'sinatra'
require 'json'

module Xcodeproj
  class Project
    module Object
      class AbstractPBXObject
        def to_json(generator = nil)
          to_hash.to_json
        end

        def to_hash
          { 'id' => uuid, 'name' => name }
        end
      end

      class PBXGroup
        def to_hash
          hash = super
          hash['type'] = 'Group'
          hash
        end
      end

      class PBXFileReference
        def to_hash
          hash = super
          hash['type'] = 'file'
          hash
        end
      end
    end

    class PBXObjectList
      def to_json(generator = nil)
        to_a.to_json
      end
    end
  end

  class Server < Sinatra::Application
    class << self
      attr_accessor :project_path

      # TODO currently here for convenience while testing
      def project
        @project ||= Xcodeproj::Project.new(project_path)
      end

      def reset!
        @project = nil
      end
    end

    set :root, File.dirname(__FILE__) + "/server"

    # Serves the app
    #
    get '/app' do
      send_file File.join(settings.public_folder, 'index.html')
    end

    # Returns the main groups of the project
    #
    get '/' do
      content_type :json
      project.main_group.children.to_json
    end

    # Returns information about a specific node identifyed by id.
    #
    # If the node is a group it returns its chlidern.
    #
    # @example
    #
    # ```json
    # {
    #   "type":"Group",
    #   "id":"F8E469B71395759C00DB05C8",
    #   "name":"Networking Extensions",
    # }
    # ```
    #
    get '/nodes/:id' do
      content_type :json
      if node = project.objects[params[:id]]
        if node.is_a? Project::Object::PBXGroup
          hash = node.to_hash
          hash['children'] = node.children
          hash.to_json
        else
          node.to_json
        end
      else
        raise "Oh noes!"
      end
    end

    # Returns the project information
    #
    get '/groups' do
      content_type :json
      project.main_group.children.to_json
    end

    get '/targets' do
      content_type :json
      project.targets.to_json
    end

    get '/build_settings' do
      content_type :json
      result = {}
      project.build_configurations.each{|bc| result[bc.name] = project.build_settings(bc.name)}
      result.to_json
    end

    # Experimental unsed

    get '/files' do
      content_type :json
      project.files.to_json
    end

    get '/files/:id' do
      if file = project.files[params[:id]]
        (Pathname.new(self.class.project_path.gsub(/\/*.xcodeproj/,'')) + file.pathname).to_s
      else
        raise "Oh noes!"
      end
    end

    get '/files/:id/raw' do
      <<-SAMPLE
  static VALUE
  cfstr_to_str(const void *cfstr) {
    CFDataRef data = CFStringCreateExternalRepresentation(NULL, cfstr, kCFStringEncodingUTF8, 0);
    assert(data != NULL);
    long len = (long)CFDataGetLength(data);
    char *buf = (char *)malloc(len+1);
    assert(buf != NULL);
    CFDataGetBytes(data, CFRangeMake(0, len), buf);

    register VALUE str = rb_str_new(buf, len);
    free(buf);

    // force UTF-8 encoding in Ruby 1.9+
    ID forceEncodingId = rb_intern("force_encoding");
    if (rb_respond_to(str, forceEncodingId)) {
      rb_funcall(str, forceEncodingId, 1, rb_str_new("UTF-8", 5));
    }

    return str;
  }
      SAMPLE
    end


    private

    def project
      self.class.project
    end
  end
end
