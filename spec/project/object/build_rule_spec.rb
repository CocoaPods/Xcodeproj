require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe PBXBuildRule do
    before do
      @rule = @project.new(PBXBuildRule)
    end

    it 'returns the name' do
      @rule.name = 'myRule'
      @rule.name.should == 'myRule'
    end

    it 'returns the compiler spec' do
      @rule.compiler_spec = 'com.apple.compilers.proxy.script'
      @rule.compiler_spec.should == 'com.apple.compilers.proxy.script'
    end

    it 'returns the file type of the rule' do
      @rule.file_type = 'pattern.proxy'
      @rule.file_type.should == 'pattern.proxy'
    end

    it 'returns whether the rule is editable' do
      @rule.is_editable = '1'
      @rule.is_editable.should == '1'
    end

    it 'returns the output files of the rule' do
      f = @project.new(PBXFileReference)
      @rule.output_files = []
      @rule.output_files << f
      @rule.output_files.count.should == 1
      @rule.output_files.should.include?(f)
    end

    it 'returns the script of the rule' do
      @rule.script = 'echo "BABY COOL"'
      @rule.script.should == 'echo "BABY COOL"'
    end
  end
end
