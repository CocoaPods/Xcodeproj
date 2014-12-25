require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::ObjectList do
    describe 'In general' do
      before do
        @list = @project.main_group.children
      end

      it 'returns the attribute that generated the list' do
        @list.attribute.name.should == :children
      end

      it 'return the owner of the list' do
        @list.owner.should == @project.main_group
      end

      it 'returns the UUIDs of the objects referenced by the list' do
        @list.uuids.should.include?(@project.frameworks_group.uuid)
      end

      it 'informs an object that is has been added to the list' do
        f = @project.new(PBXFileReference)
        f.referrers.count.should == 0
        @list << f
        f.referrers.should.include?(@project.main_group)
      end

      it 'can insert an object at the given index' do
        f = @project.new(PBXFileReference)
        f.referrers.count.should == 0
        @list.insert(0, f)
        @list[0].should == f
        f.referrers.count.should == 1
      end

      it 'informs an object that is has been removed from the list' do
        before_count = @list.count
        f = @project.new(PBXFileReference)
        @list << f
        f.referrers.count.should == 1
        f.referrers.should.include?(@project.main_group)
        @list.delete(f)
        f.referrers.count.should == 0
        @list.count.should == before_count
      end

      it 'can delete the object at the given index' do
        @list.clear
        f = @project.new(PBXFileReference)
        @list << f
        @list.delete_at(0)
        f.referrers.count.should == 0
      end

      it 'clears itself informing objects that they have been removed from the list' do
        before_ref_counts = {}
        objects = @list.objects
        objects.each { |obj| before_ref_counts[obj] = obj.referrers.count }

        f = @project.new(PBXFileReference)
        @list << f
        f.referrers.count.should == 1
        f.referrers.should.include?(@project.main_group)
        @list.clear
        objects.each { |obj| obj.referrers.count.should == before_ref_counts[obj] - 1 }
        @list.count.should == 0
      end

      it 'can move the object at the given index to a new position' do
        @list.clear
        f_1 = @project.new(PBXFileReference)
        f_2 = @project.new(PBXFileReference)
        @list << f_1
        @list << f_2
        @list.move_from(1, 0)
        @list.objects.should == [f_2, f_1]
        f_1.referrers.count.should == 1
        f_2.referrers.count.should == 1
      end

      it 'can move the given object to a new position' do
        @list.clear
        f_1 = @project.new(PBXFileReference)
        f_1.name = 'f_1'
        f_2 = @project.new(PBXFileReference)
        f_1.name = 'f_2'
        @list << f_1
        @list << f_2
        @list.objects.should == [f_1, f_2]
        @list.move(f_2, 0)
        @list.objects.should == [f_2, f_1]
        f_1.referrers.count.should == 1
        f_2.referrers.count.should == 1
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Notification enabled methods' do
      before do
        @sut = @project.main_group.children
        @sut << @project.new(PBXFileReference)
      end

      it 'supports #unshift' do
        ref = @project.new(PBXFileReference)
        @sut.unshift(ref)
        ref.referrers.count.should == 1
        ref.referrers.should.include?(@project.main_group)
      end
    end

    #-------------------------------------------------------------------------#
  end
end
