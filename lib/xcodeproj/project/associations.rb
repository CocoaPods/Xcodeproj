require 'xcodeproj/project/association_reflection'

module Xcodeproj
  class Project
    module Object

      class AbstractPBXObject
        class Association
          attr_reader :owner, :reflection

          def initialize(owner, reflection, &block)
            @owner, @reflection, @block = owner, reflection, block
          end

          class HasMany < Association
            def get
              if @reflection.inverse?
                scoped = @owner.project.objects.select_by_class(@reflection.klass).select do |object|
                  object.send(@reflection.inverse.uuid_getter) == @owner.uuid
                end
                PBXObjectList.new(@reflection.klass, @owner.project, scoped) do |new_object|
                  new_object.send(@reflection.inverse.uuid_setter, @owner.uuid)
                end
              else
                uuids = @owner.send(reflection.uuids_getter)
                if @block
                  # Evaluate the block, which was specified at the class level, in
                  # the instance’s context.
                  @owner.list_by_class(uuids, reflection.klass) do |new_object|
                    @owner.instance_exec(new_object, &@block)
                  end
                else
                  @owner.list_by_class(uuids, @reflection.klass)
                end
              end
            end

            # @todo Currently this does not call the @block, which means that
            #       in theory (like with a group's children) the object stays
            #       asociated with its old group.
            def set(list)
              @owner.send(@reflection.uuids_setter, list.map(&:uuid))
            end
          end

          # @todo Does this need 'new object'-callback support too?
          class HasOne < Association
            def get
              if @reflection.inverse?
                # Loop over all objects of the class and find the one that includes
                # this object in the specified uuid list.
                @owner.project.objects.select_by_class(@reflection.klass).find do |object|
                  object.send(@reflection.inverse.uuids_getter).include?(@owner.uuid)
                end
              else
                @owner.project.objects[@owner.send(@reflection.uuid_getter)]
              end
            end

            def set(object)
              if @reflection.inverse?
                # Remove this object from the uuid list of the target
                # that this object was associated to.
                if previous = @owner.send(@reflection.name)
                  previous.send(@reflection.inverse.uuids_getter).delete(@owner.uuid)
                end
                # Now assign this object to the new object
                object.send(@reflection.inverse.uuids_getter) << @owner.uuid if object
              else
                @owner.send(@reflection.uuid_setter, object.uuid)
              end
            end
          end
        end

        def self.has_many(plural_attr_name, options = {}, &block)
          reflection = create_reflection(plural_attr_name, options)
          unless reflection.inverse?
            attribute(reflection.name, :as => reflection.uuids_getter)
          end
          define_method(reflection.name) do
            Association::HasMany.new(self, reflection, &block).get
          end
          define_method(reflection.plural_setter) do |new_list|
            Association::HasMany.new(self, reflection, &block).set(new_list)
          end
        end

        def self.has_one(singular_attr_name, options = {})
          reflection = create_reflection(singular_attr_name, options)
          unless reflection.inverse?
            attribute(reflection.uuid_attribute, :as => reflection.uuid_getter)
          end
          define_method(reflection.name) do
            Association::HasOne.new(self, reflection).get
          end
          define_method(reflection.singular_setter) do |new_object|
            Association::HasOne.new(self, reflection).set(new_object)
          end
        end
      end

    end
  end
end
