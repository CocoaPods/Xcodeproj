require File.expand_path('../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::ObjectList do

    describe "In general" do

      before do
        @list = @project.main_group.children
      end

      it "returns the attribute that generated the list" do
        @list.attribute.name.should == :children
      end

      it "return the owner of the list" do
        @list.owner.should == @project.main_group
      end

      it "returns the UUIDs of the objects referenced by the list" do
        @list.uuids.should.include?(@project.frameworks_group.uuid)
      end

      it "informs an object that is has been added to the list" do
        f = @project.new(PBXFileReference)
        f.referrers.count.should == 0
        @list << f
        f.referrers.should.include?(@project.main_group)
      end

      it "informs an object that is has been removed from the list" do
        before_count = @list.count
        f = @project.new(PBXFileReference)
        @list << f
        f.referrers.count.should == 1
        f.referrers.should.include?(@project.main_group)
        @list.delete(f)
        f.referrers.count.should == 0
        @list.count.should == before_count
      end

      it "clears itself informing objects that they have been removed from the list" do
        before_count = @list.count
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
    end

    #-------------------------------------------------------------------------#

    describe "Notification enabled methods" do

      before do
        @sut = @project.main_group.children
        @sut << @project.new(PBXFileReference)
      end

      it "supports #unshift" do
        ref = @project.new(PBXFileReference)
        @sut.unshift(ref)
        ref.referrers.count.should == 1
        ref.referrers.should.include?(@project.main_group)
      end
    end

    #-------------------------------------------------------------------------#

  end
end
