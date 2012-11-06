require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project::Object::PBXFileReference do
    it "sets a default file type" do
      framework, library, xcconfig = %w[framework a xcconfig].map { |n| @project.new_file("Rockin.#{n}") }

      framework.last_known_file_type.should == 'wrapper.framework'
      framework.explicit_file_type.should == nil

      library.last_known_file_type.should == 'archive.ar'
      library.explicit_file_type.should == nil

      xcconfig.last_known_file_type.should == 'text.xcconfig'
      xcconfig.explicit_file_type.should == nil
    end

    it "returns whether it is a proxy" do
      @project.new_file('Test').proxy?.should == false
    end

    it "can have associated comments, but these are no longer used by Xcode" do
      file = @project.new_file('GeneratedFile')
      file.comments.should == nil
      file.comments = 'This file was automatically generated.'
      file.comments.should == 'This file was automatically generated.'
    end
  end
end
