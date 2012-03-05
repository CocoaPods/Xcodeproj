module Xcodeproj
  class Project

    # In case `scoped` is an Array the list's order is maintained.
    class PBXObjectList
      include Enumerable

      def initialize(represented_class, project, scoped, &new_object_callback)
        @represented_class = represented_class
        @project           = project
        @scoped_hash       = scoped.is_a?(Array) ? scoped.inject({}) { |h, o| h[o.uuid] = o.attributes; h } : scoped
        @scoped_uuids      = scoped.map(&:uuid) if scoped.is_a?(Array)
        @callback          = new_object_callback
      end

      def empty?
        @scoped_hash.empty?
      end

      def scoped_uuids
        @scoped_uuids || @scoped_hash.keys
      end

      def [](uuid)
        if hash = @scoped_hash[uuid]
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
      
      def object_named(name)
        find { |o| o.name == name }
      end

      # Only makes sense on lists that contain mixed classes.
      def select_by_class(klass)
        scoped = Hash[*@scoped_hash.select { |_, attr| attr['isa'] == klass.isa }.flatten]
        PBXObjectList.new(klass, @project, scoped) do |object|
          # Objects added to the subselection should still use the same
          # callback as this list.
          self << object
        end
      end

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
        @scoped_uuids << object.uuid if @scoped_uuids
        @callback.call(object) if @callback
      end
    end

  end
end
