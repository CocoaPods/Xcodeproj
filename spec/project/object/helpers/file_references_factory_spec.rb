require File.expand_path('../../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::FileReferencesFactory do

    before do
      @sut = FileReferencesFactory
      @group = @project.new_group('Classes')
    end

    #-------------------------------------------------------------------------#

    describe '::new_reference' do

      it "creates a new reference and adds it to the given group" do
        ref = @sut.new_reference(@group, 'Classes/File.m', :group)
        @group.children.should.include?(ref)
      end

      it "handles Core Data models" do
        ref = @group.new_reference('Model.xcdatamodeld')
        @group.children.should.include?(ref)
      end

      it "configures the reference to match Xcode behaviour" do
       ref = @sut.new_reference(@group, 'Frameworks/Awesome.framework', :group)
       ref.name.should == 'Awesome.framework'
       ref.include_in_index.should.be.nil
      end

    end

    #-------------------------------------------------------------------------#

    describe '::new_static_library' do

      it "creates a new static library" do
        ref = @sut.new_static_library(@group, 'Pods')
        ref.isa.should == 'PBXFileReference'
        ref.parent.should == @group
        @group.children.should.include?(ref)
      end

      it "configures the paths relative to the built products dir" do
        ref = @sut.new_static_library(@group, 'Pods')
        ref.path.should == 'libPods.a'
        ref.source_tree.should == 'BUILT_PRODUCTS_DIR'
      end

      it "doesn't set the name" do
        ref = @sut.new_static_library(@group, 'Pods')
        ref.name.should.be.nil
      end

      it "sets the reference to be not included in the index" do
        ref = @sut.new_static_library(@group, 'Pods')
        ref.include_in_index.should == '0'
      end

      it "sets the explicit file type" do
        ref = @sut.new_static_library(@group, 'Pods')
        ref.last_known_file_type.should.be.nil
        ref.explicit_file_type.should == 'archive.ar'
      end

    end

    #-------------------------------------------------------------------------#

    describe '::new_bundle' do

      it "creates a new resources bundle" do
        ref = @sut.new_bundle(@group, 'Resources')
        ref.isa.should == 'PBXFileReference'
        ref.parent.should == @group
        @group.children.should.include?(ref)
      end

      it "configures the paths relative to the built products dir" do
        ref = @sut.new_bundle(@group, 'Resources')
        ref.path.should == 'Resources.bundle'
        ref.source_tree.should == 'BUILT_PRODUCTS_DIR'
      end

      it "doesn't set the name" do
        ref = @sut.new_bundle(@group, 'Resources')
        ref.name.should.be.nil
      end

      it "sets the reference to be not included in the index" do
        ref = @sut.new_bundle(@group, 'Resources')
        ref.include_in_index.should == '0'
      end

      it "sets the explicit file type" do
        ref = @sut.new_bundle(@group, 'Resources')
        ref.last_known_file_type.should.be.nil
        ref.explicit_file_type.should == 'wrapper.cfbundle'
      end
    end

    #-------------------------------------------------------------------------#

    describe '::new_file_reference' do

      it "creates a new file reference and adds it to the given group" do
        ref = @sut.send(:new_file_reference, @group, 'Classes/File.m', :group)
        ref.isa.should == 'PBXFileReference'
        ref.parent.should == @group
        @group.children.should.include?(ref)
      end

      it "configures the path according to the source tree" do
        @group.path = 'Classes'
        ref = @sut.send(:new_file_reference, @group, 'project_dir/Classes/File.m', :group)
        ref.source_tree.should == '<group>'
        ref.path.should == 'File.m'
      end

      it "sets the last know file type" do
        ref = @sut.send(:new_file_reference, @group, 'project_dir/File.m', :group)
        ref.last_known_file_type.should == 'sourcecode.c.objc'
      end


    end

    #-------------------------------------------------------------------------#

    describe '::new_xcdatamodeld' do

      it "creates a new XCVersionGroup and adds it to the given group" do
        ref = @sut.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.isa.should == 'XCVersionGroup'
        ref.parent.should == @group
        @group.children.should.include?(ref)
      end

      it "configures the path according to the source tree" do
        @group.path = 'Classes'
        ref = @sut.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.source_tree.should == '<group>'
        ref.path.should == 'Model.xcdatamodeld'
      end

      it "sets the version group type" do
        ref = @sut.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.version_group_type.should == 'wrapper.xcdatamodel'
      end

      it "doesn't populate the children if the given path doesn't exist" do
        ref = @sut.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.children.count.should == 0
      end

      it "populates the children if the given path exists" do
        Pathname.any_instance.stubs(:exist?).returns(true)
        Pathname.any_instance.stubs(:children).returns([Pathname.new('Model.xcdatamodel'), Pathname.new('Model 2.xcdatamodel'),])
        ref = @sut.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.children.count.should == 2
        ref.children.map(&:path).should == ['Model.xcdatamodel', 'Model 2.xcdatamodel']
        ref.children.map(&:isa).uniq.should == ['PBXFileReference']
        ref.children.map(&:last_known_file_type).uniq.should == ['wrapper.xcdatamodel']
      end

      it "sets the group as the source tree of the children" do
        Pathname.any_instance.stubs(:exist?).returns(true)
        Pathname.any_instance.stubs(:children).returns([Pathname.new('Model.xcdatamodel'), Pathname.new('Model 2.xcdatamodel'),])
        ref = @sut.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.children.map(&:source_tree).uniq.should == ['<group>']
        ref.children.map(&:path).should == ["Model.xcdatamodel", "Model 2.xcdatamodel"]
      end

      xit "sets the current version to the last children in alphabetical order" do
        Pathname.any_instance.stubs(:exist?).returns(true)
        Pathname.any_instance.stubs(:children).returns([Pathname.new('Model.xcdatamodel'), Pathname.new('Model 2.xcdatamodel'),])
        ref = @sut.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.current_version.path.should == 'Model 2.xcdatamodel'
      end

    end

    #-------------------------------------------------------------------------#

    describe '::configure_defaults_for_file_reference' do

      it "doesn't set the name if its path relative to the source tree doesn't include directories" do
        ref = @project.new(PBXFileReference)
        ref.path = 'File.m'
        @sut.send(:configure_defaults_for_file_reference, ref)
        ref.name.should.be.nil
      end

      it "sets the name if its path relative to the source tree includes directories" do
        ref = @project.new(PBXFileReference)
        ref.path = 'File/File.m'
        @sut.send(:configure_defaults_for_file_reference, ref)
        ref.name.should == 'File.m'
      end

      it "sets configures frameworks not to be included in the index" do
        ref = @project.new(PBXFileReference)
        ref.path = 'File.framework'
        @sut.send(:configure_defaults_for_file_reference, ref)
        ref.include_in_index.should.be.nil
      end

    end

    #-------------------------------------------------------------------------#

  end
end

