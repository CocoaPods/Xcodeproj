module Xcodeproj
  class Project

    # In case `scoped` is an Array the list's order is maintained.
    class PBXObjectList
      include Enumerable

      def initialize(represented_class, project)
        @represented_class = represented_class
        @project           = project
      end

      def scope_uuids(&block)
        @scope_uuids_callback = block
      end

      def on_add_object(&block)
        @add_object_callback = block
      end

      def scoped_uuids
        @scope_uuids_callback.call
      end

      def empty?
        scoped_uuids.empty?
      end

      def [](uuid)
        if scoped_uuids.include?(uuid) && hash = @project.objects_hash[uuid]
          Object.const_get(hash['isa']).new(@project, uuid, hash)
        end
      end

      def add(klass, hash = {})
        object = klass.new(@project, nil, hash)
        add_object(object)
        object
      end

      def new(hash = {})
        add(@represented_class, hash)
      end

      def <<(object)
        add_object(object)
      end

      def each
        scoped_uuids.each do |uuid|
          yield self[uuid]
        end
      end

      def ==(other)
        self.to_a == other.to_a
      end

      def size
        scoped_uuids.size
      end

      def first
        to_a.first
      end

      def last
        to_a.last
      end

      def inspect
        "<PBXObjectList: #{map(&:inspect)}>"
      end

      def where(attributes)
        find { |o| o.matches_attributes?(attributes) }
      end

      # @todo is it really necessary to have an extra method for this?
      def object_named(name)
        where :name => name
      end

      # Only makes sense on lists that contain mixed classes. Only the main objects list?
      def list_by_class(klass, scoped_uuids = nil)
        parent = self
        PBXObjectList.new(klass, @project).tap do |list|
          list.on_add_object do |object|
            # Objects added to the subselection should still use the same
            # callback as this list.
            parent << object
          end
          if scoped_uuids
            list.scope_uuids(&scoped_uuids)
          else
            list.scope_uuids do
              parent.scoped_uuids.select do |uuid|
                @project.objects_hash[uuid]['isa'] == klass.isa
              end
            end
          end
        end
      end

      # This only makes sense on those with a specific represented class. Not the main objects list.
      def method_missing(name, *args, &block)
        if @represented_class.respond_to?(name)
          object = @represented_class.send(name, @project, *args)
          # The callbacks are only for AbstractPBXObject instances instantiated
          # from the class method that we forwarded the message to.
          add_object(object) if object.is_a?(Object::AbstractPBXObject)
          object
        else
          super
        end
      end

      private

      def add_object(object)
        @add_object_callback.call(object) if @add_object_callback
      end
    end

  end
end
