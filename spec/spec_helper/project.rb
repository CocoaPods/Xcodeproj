module SpecHelper
  module Project
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
