module SpecHelper
  module Project
    module Stubbing
      def new_instance(klass, attributes, uuid = nil)
        @project.disable_raise = true
        object = klass.new(@project, uuid, attributes)
        @project.disable_raise = false
        object
      end

      def add_disable_raise_feature_to_project!
        class << @project; attr_accessor :disable_raise; end
        def @project.raise(*args)
          super unless @disable_raise && args.first == ArgumentError
        end
      end
    end

    include Stubbing

    def find_objects(conditions)
      @project.objects_hash.select do |_, object|
        object.keys == conditions.keys && object == conditions
      end
    end

    def find_object(conditions)
      find_objects(conditions).first
    end

    def self.extended(context)
      context.before do
        @project = Xcodeproj::Project.new
        add_disable_raise_feature_to_project!
        @target = @project.targets.new_static_library('Pods')
      end
    end
  end
end

module ProjectSpecs
  # Bring the PBXObject classes into the namespace in which the project specs
  # are defined. This is better than into the global namespace, which could
  # influence the behavior of other specs.
  include Xcodeproj::Project::Object

  # Extend each context with SpecHelper::Project.
  def self.describe(description, &block)
    super description do
      extend SpecHelper::Project
      instance_eval(&block)
    end
  end
end
