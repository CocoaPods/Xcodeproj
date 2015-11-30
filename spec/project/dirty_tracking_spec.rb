require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project do
    def each_attribute(blk)
      project = Xcodeproj::Project.open(fixture_path('Sample Project/Cocoa Application.xcodeproj'))
      raise 'should not be dirty' if project.dirty?
      attributes_method = AbstractObject.instance_method(:attributes)
      all_objects = project.objects_by_uuid.values
      all_objects.flat_map { |object| attributes_method.bind(object).call.map { |a| [a, object] } }.
        uniq(&:first).each do |attrb, object|
        blk[project, object, attrb]
      end
    end

    describe 'does not mark as dirty' do
      describe 'when assigning an equal value' do
        each_attribute -> (project, object, attrb) do
          next unless attrb.type == :simple || attrb.type == :to_one
          it "#{attrb.owner.name}##{attrb.name}=" do
            project.should.not.be.dirty
            object.send(:"#{attrb.name}=", object.send(attrb.name))
            project.should.not.be.dirty
          end
        end
      end
    end

    describe 'marks as dirty' do
      it 'when assigning an unequal value' do
        each_attribute -> (project, object, attrb) do
          next unless attrb.type == :simple || attrb.type == :to_one
          cls = attrb.classes.sample
          it "#{attrb.owner.name}##{attrb.name}=" do
            random = if cls < AbstractObject
                       project.new(Array(Xcodeproj::Constants::KNOWN_ISAS[cls.isa]).sample || cls)
                     else
                       cls.new
                     end
            random = nil if random == attrb.get_value(object)
            project.expects(:mark_dirty!).at_least(1)
            object.send(:"#{attrb.name}=", random)
          end
        end
      end
    end
  end
end
