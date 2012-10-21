module SpecHelper
  module Project
    def self.extended(context)
      context.before do
        @project = Xcodeproj::Project.new
        # add_disable_raise_feature_to_project!
        # @target = @project.targets.new_static_library(:ios, 'Pods')
      end
    end
    
    def settings(*keys)
      settings = Xcodeproj::Constants::COMMON_BUILD_SETTINGS.values_at(*keys)
      settings.inject({}) { |hash, h| hash.merge(h) }
    end
    
  end
end

module ProjectSpecs
  # Bring the Object classes into the namespace in which the project specs
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
