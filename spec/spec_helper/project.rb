module SpecHelper
  module Project
    def self.extended(context)
      context.before do
        @project = Xcodeproj::Project.new('/project_dir/Project.xcodeproj')
      end
    end

    def settings(*keys)
      settings = Xcodeproj::Constants::COMMON_BUILD_SETTINGS.values_at(*keys)
      settings.reduce({}) { |hash, h| hash.merge(h) }
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

    Bacon::ErrorLog.gsub!(/^.*spec\/spec_helper.*\n/, '')
  end
end
