module Xcodeproj
  class Project

    # In case `scoped` is an Array the list's order is maintained.
    class PBXObjectList
      include Enumerable

      def initialize(represented_class, project)
        @represented_class = represented_class
        @project           = project
        @callbacks         = {}

        yield self if block_given?
      end

      # Specify callbacks for:
      # * :uuid_scope  Returns the list of UUIDs to scope this list to.
      # * :push        When an object is added to the list.
      def let(callback_name, &block)
        raise ArgumentError, "Incorrect callback `#{callback_name}'." unless [:uuid_scope, :push].include?(callback_name)
        @callbacks[callback_name] = block
      end

      def uuid_scope
        @callbacks[:uuid_scope].call
      end

      def empty?
        uuid_scope.empty?
      end

      def [](uuid)
        if uuid_scope.include?(uuid) && hash = @project.objects_hash[uuid]
          Object.const_get(hash['isa']).new(@project, uuid, hash)
        end
      end

      def add(klass, hash = {})
        object = klass.new(@project, nil, hash)
        self << object
        object
      end

      def new(hash = {})
        add(@represented_class, hash)
      end

      # Run Ruby in debug mode to receive warnings about calls to :push when a
      # list does not have a callback registered for :push.
      def push(object)
        if @callbacks[:push]
          @callbacks[:push].call(object)
        else
          if $DEBUG
            warn "Pushed object onto a PBXObjectList that does not have a :push callback from: #{caller.first}"
          end
        end
        self
      end
      alias_method :<<, :push

      def each
        uuid_scope.each do |uuid|
          yield self[uuid]
        end
      end

      def ==(other)
        self.to_a == other.to_a
      end

      def size
        uuid_scope.size
      end

      # Since order can't always be guaranteed, these might need to move to an order specific subclass.
      def first
        to_a.first
      end
      def last
        to_a.last
      end

      def inspect
        "<PBXObjectList: #{map(&:inspect).join(', ')}>"
      end

      def where(attributes)
        find { |o| o.matches_attributes?(attributes) }
      end

      # @todo is it really necessary to have an extra method for this?
      def object_named(name)
        where :name => name
      end

      # Returns a PBXObjectList instance of objects in the list.
      #
      # By default this list will scope the list by objects matching the
      # specified class and add objects, pushed onto the list, to the parent
      # list
      #
      # If a block is given the list instance is yielded so that the default
      # callbacks can be overridden.
      #
      # @param  [AbstractPBXObject] klass  The AbstractPBXObject subclass to
      #                                    which the list should be scoped.
      #
      # @yield  [PBXObjectList]            The list instance, allowing you to
      #                                    easily override the callbacks.
      #
      # @return [PBXObjectList<klass>]     The list of matching objects.
      def list_by_class(klass)
        parent = self
        PBXObjectList.new(klass, @project) do |list|
          list.let(:push) do |object|
            # Objects added to the subselection should still use the same
            # callback as this list.
            parent << object
          end
          list.let(:uuid_scope) do
            parent.uuid_scope.select do |uuid|
              @project.objects_hash[uuid]['isa'] == klass.isa
            end
          end
          yield list if block_given?
        end
      end

      # This only makes sense on those with a specific represented class. Not the main objects list.
      def method_missing(name, *args, &block)
        if @represented_class.respond_to?(name)
          object = @represented_class.send(name, @project, *args)
          # The callbacks are only for AbstractPBXObject instances instantiated
          # from the class method that we forwarded the message to.
          self << object if object.is_a?(Object::AbstractPBXObject)
          object
        else
          super
        end
      end

    end

  end
end
