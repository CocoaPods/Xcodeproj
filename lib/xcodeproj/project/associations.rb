require 'xcodeproj/project/association_reflection'

module Xcodeproj
  class Project
    module Object

      class AbstractPBXObject
        def self.has_many(plural_attr_name, options = {}, &block)
          reflection = create_reflection(plural_attr_name, options)
          if reflection.inverse?
            define_method(reflection.name) do
              scoped = @project.objects.select_by_class(reflection.klass).select do |object|
                object.send(reflection.inverse.uuid_getter) == self.uuid
              end
              PBXObjectList.new(reflection.klass, @project, scoped) do |object|
                object.send(reflection.inverse.uuid_setter, self.uuid)
              end
            end
          else
            attribute(reflection.name, :as => reflection.uuids_getter)
            define_method(reflection.name) do
              uuids = send(reflection.uuids_getter)
              if block
                # Evaluate the block, which was specified at the class level, in
                # the instance’s context.
                list_by_class(uuids, reflection.klass) do |object|
                  instance_exec(object, &block)
                end
              else
                list_by_class(uuids, reflection.klass)
              end
            end
            define_method(reflection.plural_setter) do |objects|
              send(reflection.uuids_setter, objects.map(&:uuid))
            end
          end
        end

        def self.has_one(singular_attr_name, options = {})
          reflection = create_reflection(singular_attr_name, options)
          if reflection.inverse?
            define_method(reflection.name) do
              # Loop over all objects of the class and find the one that includes
              # this object in the specified uuid list.
              @project.objects.select_by_class(reflection.klass).find do |object|
                object.send(reflection.inverse.uuids_getter).include?(self.uuid)
              end
            end
            define_method(reflection.singular_setter) do |object|
              # Remove this object from the uuid list of the target
              # that this object was associated to.
              if previous = send(reflection.name)
                previous.send(reflection.inverse.uuids_getter).delete(self.uuid)
              end
              # Now assign this object to the new object
              object.send(reflection.inverse.uuids_getter) << self.uuid if object
            end
          else
            attribute(reflection.uuid_attribute, :as => reflection.uuid_getter)
            define_method(reflection.name) do
              @project.objects[send(reflection.uuid_getter)]
            end
            define_method(reflection.singular_setter) do |object|
              send(reflection.uuid_setter, object.uuid)
            end
          end
        end
      end

    end
  end
end
