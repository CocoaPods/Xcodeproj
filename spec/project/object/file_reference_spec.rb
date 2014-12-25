require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::PBXFileReference do
    before do
      @file = @project.new_file('File.m')
    end

    it 'returns the parent' do
      @file.parent.should == @project.main_group
    end

    it 'returns the parents' do
      @file.parents.should == [@project.main_group]
    end

    it 'returns the representation of the group hierarchy' do
      @file.hierarchy_path.should == '/File.m'
    end

    it 'can be moved to a new parent' do
      new_parent = @project.new_group('New Parent')
      @file.move(new_parent)
      @file.parent.should == new_parent
    end

    it 'returns the real path' do
      @file.real_path.should == Pathname.new('/project_dir/File.m')
    end

    it 'sets the source tree' do
      @file.source_tree = '<group>'
      @file.set_source_tree(:absolute)
      @file.source_tree.should == '<absolute>'
    end

    it 'sets the path according to the source tree' do
      @file.source_tree = '<group>'
      @file.set_path('/project_dir/File.m')
      @file.path.should == 'File.m'
    end

    it 'sets its last known file type' do
      @file.last_known_file_type = nil
      @file.set_last_known_file_type('custom')
      @file.last_known_file_type.should == 'custom'
    end

    it 'sets its last known file type according to the extension of the path' do
      @file.last_known_file_type = nil
      @file.set_last_known_file_type
      @file.last_known_file_type.should == 'sourcecode.c.objc'
    end

    it 'sets its explicit file type' do
      @file.explicit_file_type = nil
      @file.set_explicit_file_type('custom')
      @file.explicit_file_type.should == 'custom'
      @file.last_known_file_type.should.be.nil
    end

    it 'sets its explicit file type according to the extension of the path' do
      @file.explicit_file_type = nil
      @file.set_explicit_file_type
      @file.explicit_file_type.should == 'sourcecode.c.objc'
      @file.last_known_file_type.should.be.nil
    end

    it 'can have associated comments, but these are no longer used by Xcode' do
      @file.comments = 'This file was automatically generated.'
      @file.comments.should == 'This file was automatically generated.'
    end

    describe 'concerning proxies' do
      it 'returns that it is not a proxy' do
        @file.should.not.be.a.proxy
      end

      it 'returns no proxies' do
        @file.file_reference_proxies.should.be.empty
      end

      before do
        @file_container = @project.new(PBXContainerItemProxy)
        @file_container.container_portal = @file.uuid
        @file_proxy = @project.new(PBXReferenceProxy)
        @project.main_group.children << @file_proxy
        @file_proxy.remote_ref = @file_container

        @target_container = @project.new(PBXContainerItemProxy)
        @target_container.container_portal = @file.uuid
        @target_dependency = @project.new(PBXTargetDependency)
        @target = @project.new_target(:static_library, 'Pods', :ios)
        @target.dependencies << @target_dependency
        @target_dependency.target_proxy = @target_container

        @group = @project.main_group.new_group('Products')
        @project_reference = Xcodeproj::Project::ObjectDictionary.new(@project.root_object.references_by_keys_attributes.first, @project.root_object)
        @project_reference['ProjectRef'] = @file
        @project_reference['ProductGroup'] = @group
        @project.root_object.project_references << @project_reference
      end

      it 'returns the project reference metadata' do
        @file.project_reference_metadata.should == @project_reference
      end

      it 'returns the proxy containers that are contained in this external project' do
        @file.proxy_containers.should == [@file_container, @target_container]
      end

      it 'returns the file reference proxies' do
        @file.file_reference_proxies.should == [@file_proxy]
      end

      it 'returns the target dependencies that depend on targets in this Xcode project file reference' do
        @file.target_dependency_proxies.should == [@target_dependency]
      end

      it 'removes the proxy related objects when removing the file reference' do
        @file.remove_from_project
        @project.objects_by_uuid[@file_proxy.uuid].should.nil?
        @project.objects_by_uuid[@file_container.uuid].should.nil?
        @project.objects_by_uuid[@target_container.uuid].should.nil?
        @project.objects_by_uuid[@target_dependency.uuid].should.nil?
        @project.objects_by_uuid[@group.uuid].should.nil?
        @project.root_object.project_references.should.not.include @project_reference
        @target.dependencies.should.be.empty
      end
    end
  end
end
