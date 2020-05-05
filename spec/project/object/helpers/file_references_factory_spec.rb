require File.expand_path('../../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::FileReferencesFactory do
    before do
      @factory = FileReferencesFactory
      @group = @project.new_group('Classes')
    end

    #-------------------------------------------------------------------------#

    describe '::new_reference' do
      it 'creates a new reference and adds it to the given group' do
        ref = @factory.new_reference(@group, 'Classes/File.m', :group)
        @group.children.should.include?(ref)
      end

      it 'handles Core Data models' do
        ref = @group.new_reference('Model.xcdatamodeld')
        @group.children.should.include?(ref)
      end

      it 'configures the reference to match Xcode behaviour' do
        ref = @factory.new_reference(@group, 'Frameworks/Awesome.framework', :group)
        ref.name.should == 'Awesome.framework'
        ref.include_in_index.should.be.nil
      end
    end

    #-------------------------------------------------------------------------#

    describe '::new_static_library' do
      before do
        @ref = @factory.new_product_ref_for_target(@group, 'Pods', :static_library)
      end

      it 'creates a new static library' do
        @ref.isa.should == 'PBXFileReference'
        @ref.parent.should == @group
        @group.children.should.include?(@ref)
      end

      it 'configures the paths relative to the built products dir' do
        @ref.path.should == 'libPods.a'
        @ref.source_tree.should == 'BUILT_PRODUCTS_DIR'
      end

      it "doesn't set the name" do
        @ref.name.should.be.nil
      end

      it 'sets the reference to be not included in the index' do
        @ref.include_in_index.should == '0'
      end

      it 'sets the explicit file type' do
        @ref.last_known_file_type.should.be.nil
        @ref.explicit_file_type.should == 'archive.ar'
      end
    end

    #-------------------------------------------------------------------------#

    describe '::new_bundle' do
      it 'creates a new resources bundle' do
        ref = @factory.new_bundle(@group, 'Resources')
        ref.isa.should == 'PBXFileReference'
        ref.parent.should == @group
        @group.children.should.include?(ref)
      end

      it 'configures the paths relative to the built products dir' do
        ref = @factory.new_bundle(@group, 'Resources')
        ref.path.should == 'Resources.bundle'
        ref.source_tree.should == 'BUILT_PRODUCTS_DIR'
      end

      it "doesn't set the name" do
        ref = @factory.new_bundle(@group, 'Resources')
        ref.name.should.be.nil
      end

      it 'sets the reference to be not included in the index' do
        ref = @factory.new_bundle(@group, 'Resources')
        ref.include_in_index.should == '0'
      end

      it 'sets the explicit file type' do
        ref = @factory.new_bundle(@group, 'Resources')
        ref.last_known_file_type.should.be.nil
        ref.explicit_file_type.should == 'wrapper.cfbundle'
      end
    end

    #-------------------------------------------------------------------------#

    describe '::new_file_reference' do
      it 'creates a new file reference and adds it to the given group' do
        ref = @factory.send(:new_file_reference, @group, 'Classes/File.m', :group)
        ref.isa.should == 'PBXFileReference'
        ref.parent.should == @group
        @group.children.should.include?(ref)
      end

      it 'configures the path according to the source tree' do
        @group.path = 'Classes'
        ref = @factory.send(:new_file_reference, @group, '/project_dir/Classes/File.m', :group)
        ref.source_tree.should == '<group>'
        ref.path.should == 'File.m'
      end

      it 'sets the last know file type' do
        ref = @factory.send(:new_file_reference, @group, '/project_dir/File.m', :group)
        ref.last_known_file_type.should == 'sourcecode.c.objc'
      end
    end

    #-------------------------------------------------------------------------#

    describe '::new_xcdatamodeld' do
      it 'creates a new XCVersionGroup and adds it to the given group' do
        ref = @factory.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.isa.should == 'XCVersionGroup'
        ref.parent.should == @group
        @group.children.should.include?(ref)
      end

      it 'configures the path according to the source tree' do
        @group.path = 'Classes'
        ref = @factory.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.source_tree.should == '<group>'
        ref.path.should == 'Model.xcdatamodeld'
      end

      it 'sets the version group type' do
        ref = @factory.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.version_group_type.should == 'wrapper.xcdatamodel'
      end

      it "doesn't populate the children if the given path doesn't exist" do
        ref = @factory.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.children.count.should == 0
      end

      it 'populates the children if the given path exists' do
        Pathname.any_instance.stubs(:exist?).returns(true)
        Pathname.any_instance.stubs(:children).returns([Pathname.new('Model.xcdatamodel'), Pathname.new('Model 2.xcdatamodel')])
        ref = @factory.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.children.count.should == 2
        ref.children.map(&:path).should == ['Model.xcdatamodel', 'Model 2.xcdatamodel']
        ref.children.map(&:isa).uniq.should == ['PBXFileReference']
        ref.children.map(&:last_known_file_type).uniq.should == ['wrapper.xcdatamodel']
      end

      it 'sets the group as the source tree of the children' do
        Pathname.any_instance.stubs(:exist?).returns(true)
        Pathname.any_instance.stubs(:children).returns([Pathname.new('Model.xcdatamodel'), Pathname.new('Model 2.xcdatamodel')])
        ref = @factory.send(:new_xcdatamodeld, @group, 'Model.xcdatamodeld', :group)
        ref.children.map(&:source_tree).uniq.should == ['<group>']
        ref.children.map(&:path).should == ['Model.xcdatamodel', 'Model 2.xcdatamodel']
      end

      it 'sets the current version according to the xccurrentversion file' do
        path = fixture_path('CoreData/VersionedModel.xcdatamodeld')
        ref = @factory.send(:new_xcdatamodeld, @group, path, :group)

        ref.current_version.isa.should == 'PBXFileReference'
        ref.current_version.path.should.include 'VersionedModel 2.xcdatamodel'
        ref.current_version.last_known_file_type.should == 'wrapper.xcdatamodel'
        ref.current_version.source_tree.should == '<group>'
        @group.children.should.include(ref)
      end

      it 'resolves path to models in subfolders' do
        group_path = fixture_path('CoreData')
        group = @group.new_group('CoreData', group_path)

        path = 'VersionedModel.xcdatamodeld'
        ref = @factory.send(:new_xcdatamodeld, group, path, :group)

        ref.current_version.isa.should == 'PBXFileReference'
        ref.current_version.path.should.include 'VersionedModel 2.xcdatamodel'
        ref.current_version.last_known_file_type.should == 'wrapper.xcdatamodel'
        ref.current_version.source_tree.should == '<group>'
        group.children.should.include(ref)
      end
    end

    #-------------------------------------------------------------------------#

    describe 'Xcode Projects' do
      before do
        @path = fixture_path('Sample Project/ReferencedProject/ReferencedProject.xcodeproj')
        @ref = FileReferencesFactory.new_reference(@project.main_group, @path, :group)
      end

      it 'creates a new file reference and sets is ' do
        @ref.isa.should == 'PBXFileReference'
        @project.main_group.children.should.include?(@ref)
      end

      it "doesn't include the reference in index" do
        @ref.include_in_index.should.be.nil
      end

      it 'sets the project reference in the parent project' do
        project_references = @project.root_object.project_references
        project_references.count.should == 1
        project_reference = project_references.first
        project_reference[:project_ref].should == @ref
        project_reference[:product_group].isa.should == 'PBXGroup'
      end

      it 'configures the product group of the project' do
        project_reference = @project.root_object.project_references.first
        group = project_reference[:product_group]
        group.name.should == 'Products'
        group.source_tree.should == '<group>'
      end

      it 'creates a reference proxy for each target' do
        project_reference = @project.root_object.project_references.first
        reference_proxies = project_reference[:product_group].children

        reference_proxies.uniq.count.should == 3
        reference_proxies.map(&:isa).uniq.should == ['PBXReferenceProxy']
        reference_proxies.map(&:source_tree).uniq.should == ['BUILT_PRODUCTS_DIR']

        reference_proxy = reference_proxies.first
        reference_proxy.file_type.should == 'wrapper.application'
        reference_proxy.path.should == 'ReferencedProject.app'
        reference_proxy.remote_ref.isa.should == 'PBXContainerItemProxy'
      end

      it 'creates a container proxy for each target' do
        project_reference = @project.root_object.project_references.first
        reference_proxies = project_reference[:product_group].children
        container_proxies = reference_proxies.map(&:remote_ref)

        container_proxies.uniq.count.should == 3
        container_proxies.map(&:container_portal).uniq.should == [@ref.uuid]
        container_proxies.map(&:proxy_type).uniq.should == ['2']
        container_proxies.map(&:remote_info).uniq.should == ['Subproject']

        container_proxy = container_proxies.first
        container_proxy.remote_global_id_string.should == 'E5FBB2E51635ED34009E96B0'
      end

      it "doesn't create duplicate 'Products' groups" do
        subproject_path = fixture_path('Sample Project/ReferencedProject/ReferencedProject.xcodeproj')
        @subproject = Xcodeproj::Project.open(subproject_path)
        @project.main_group.new_reference(@subproject.path)
        @project.objects.select { |o| o.display_name == 'Products' }.count.should == 1
        @subproject.objects.select { |o| o.display_name == 'Products' }.count.should == 1
      end
    end

    #-------------------------------------------------------------------------#

    describe '::configure_defaults_for_file_reference' do
      it "doesn't set the name if its path relative to the source tree doesn't include directories" do
        ref = @project.new(PBXFileReference)
        ref.path = 'File.m'
        @factory.send(:configure_defaults_for_file_reference, ref)
        ref.name.should.be.nil
      end

      it 'sets the name if its path relative to the source tree includes directories' do
        ref = @project.new(PBXFileReference)
        ref.path = 'File/File.m'
        @factory.send(:configure_defaults_for_file_reference, ref)
        ref.name.should == 'File.m'
      end

      it 'sets configures frameworks not to be included in the index' do
        ref = @project.new(PBXFileReference)
        ref.path = 'File.framework'
        @factory.send(:configure_defaults_for_file_reference, ref)
        ref.include_in_index.should.be.nil
      end
    end

    #-------------------------------------------------------------------------#

    describe '::new_product_ref_for_target' do
      it 'adds extension for target types that have extensions' do
        ref = @factory.new_product_ref_for_target(@group, 'Pods', :static_library)
        ref.path.should == 'libPods.a'
      end

      it 'does not add trailing dot for target types that do not have extensions' do
        ref = @factory.new_product_ref_for_target(@group, 'mytool', :command_line_tool)
        ref.path.should == 'mytool'
      end
    end

    #-------------------------------------------------------------------------#
  end
end
