require 'sinatra'
require 'json'

module Xcodeproj
  class Project
    module Object
      class AbstractPBXObject
        def to_json(generator = nil)
          # TODO move to subclasses? e.g. #json_type
          type = case self
          when PBXGroup         then 'group'
          when PBXFileReference then 'file'
          else
            raise "Oh noes!"
          end
          { 'id' => uuid, 'type' => type, 'name' => name }.to_json
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

    post '/groups/:id/groups' do
      if group = project.objects[params[:id]]
        new_group = group.groups.new(JSON.parse(params[:group]))
        new_group.to_json
      else
        raise "Oh noes!"
      end
    end

    private

    def project
      self.class.project
    end
  end
end
