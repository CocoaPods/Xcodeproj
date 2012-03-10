module Xcodeproj
  class Project
    module Object
      class Association

        # @todo Does this need 'new object'-callback support too?
        class HasOne < Association
          def direct_get
            @owner.project.objects[@owner.send(@reflection.attribute_getter)]
          end

          def inverse_get
            # Loop over all objects of the class and find the one that includes
            # this object in the specified uuid list.
            @owner.project.objects.select_by_class(@reflection.klass).find do |object|
              object.send(@reflection.inverse.attribute_getter).include?(@owner.uuid)
            end
          end

          def direct_set(object)
            @owner.send(@reflection.attribute_setter, object.uuid)
          end

          def inverse_set(object)
            # Remove this object from the uuid list of the target
            # that this object was associated to.
            if previous = @owner.send(@reflection.name)
              previous.send(@reflection.inverse.attribute_getter).delete(@owner.uuid)
            end
            # Now assign this object to the new object
            object.send(@reflection.inverse.attribute_getter) << @owner.uuid if object
          end
        end

      end
    end
  end
end

