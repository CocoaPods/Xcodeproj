require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXProject do
    before do
      @project.new_target(:static, 'Pods', :ios)
      @root_object = @project.root_object
    end

    it 'returns the targets' do
      @root_object.targets.map(&:name).should == ['Pods']
    end

    it 'returns the attributes' do
      @root_object.attributes['LastUpgradeCheck'].should.not.be.nil
    end

    it 'returns the build configuration list' do
      @root_object.build_configuration_list.class.should == XCConfigurationList
    end

    it 'returns the compatibility version' do
      @root_object.compatibility_version.should.include('Xcode')
    end

    it 'returns the development region' do
      @root_object.development_region.should == 'en'
    end

    it 'returns whether has scanned for encodings' do
      @root_object.has_scanned_for_encodings.should == '0'
    end

    it 'returns the known regions' do
      @root_object.known_regions.should == %w(en Base)
    end

    it 'returns the main group' do
      @root_object.main_group.class.should == PBXGroup
    end

    it 'returns the products group' do
      @root_object.product_ref_group.class.should == PBXGroup
    end

    it 'returns the project dir path' do
      @root_object.project_dir_path = 'some/path'
      @root_object.project_dir_path.should == 'some/path'
    end

    it 'returns the project root' do
      @root_object.project_root = 'some/path'
      @root_object.project_root.should == 'some/path'
    end
  end
end
