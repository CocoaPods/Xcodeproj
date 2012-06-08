require 'sinatra'
require 'json'

module Xcodeproj
  class Project
    module Object
      class AbstractPBXObject
        def to_json
          # TODO move to subclasses? e.g. #json_type
          type = case self
          when PBXGroup         then 'group'
          when PBXFileReference then 'file'
          else
            raise "Oh noes!"
          end
          { 'type' => type, 'name' => name }
        end
      end
    end

    class PBXObjectList
      def to_json
        inject({}) do |hash, object|
          hash[object.uuid] = object.to_json
          hash
        end.to_json
      end
    end
  end

  class Server < Sinatra::Application
    class << self
      attr_accessor :project_path

      # TODO currently here for convenience while testing
      def project
        Xcodeproj::Project.new(project_path)
      end
    end

    get '/' do
      project.main_group.children.to_json
    end

    get '/groups/:id' do
      if group = project.objects[params[:id]]
        group.children.to_json
      else
        raise "Oh noes!"
      end
    end

    private

    def project
      @project ||= self.class.project
    end
  end
end
