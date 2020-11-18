require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXBuildFile do
    before do
      @build_file = @project.new(PBXBuildFile)
    end

    describe 'In general' do
      it "doesn't provide default file settings" do
        @build_file.settings.should.be.nil
      end

      it 'returns the file reference' do
        @build_file.file_ref = @project.new(PBXFileReference)
        @build_file.file_ref.class.should == PBXFileReference
      end

      it 'accepts a group as a reference' do
        lambda { @build_file.file_ref = @project.new(PBXGroup) }.should.not.raise
      end

      it 'accepts a variant group and a version group as a reference' do
        lambda { @build_file.file_ref = @project.new(PBXVariantGroup) }.should.not.raise
        lambda { @build_file.file_ref = @project.new(XCVersionGroup) }.should.not.raise
      end
    end

    #-------------------------------------------------------------------------#

    describe 'AbstractObject Hooks' do
      it 'returns the display name of the Swift package if one is available' do
        product_ref = @project.new(XCSwiftPackageProductDependency)
        product_ref.product_name = 'SwiftPackage'
        @build_file.product_ref = product_ref
        @build_file.display_name.should == 'SwiftPackage'
      end

      it 'returns the display name of the file reference if one is available and Swift Package is not set' do
        file_ref = @project.new_file('Class.m')
        @build_file.file_ref = file_ref
        @build_file.display_name.should == 'Class.m'
      end

      it 'returns the class name as the display name if no file reference is associated' do
        @build_file.display_name.should == 'BuildFile'
      end

      it 'returns the pretty print representation' do
        @build_file.file_ref = @project.new_file('Class.m')
        @build_file.settings = {}
        @build_file.settings['COMPILER_FLAGS'] = '-Wno-format'
        @build_file.pretty_print.should == {
          'Class.m' => { 'COMPILER_FLAGS' => '-Wno-format' },
        }
      end
    end

    #-------------------------------------------------------------------------#
  end
end
