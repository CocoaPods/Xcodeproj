require File.expand_path('../../../spec_helper', __FILE__)

module ProjectSpecs
  describe "Xcodeproj::Project::Object::PBXFileReference" do
    it "sets a default file type" do
      framework, library, xcconfig = %w[framework a xcconfig].map { |n| @project.new_file("Rockin.#{n}") }
      
      framework.last_known_file_type.should == 'wrapper.framework'
      framework.explicit_file_type.should == nil

      library.last_known_file_type.should == 'archive.ar'
      library.explicit_file_type.should == nil

      xcconfig.last_known_file_type.should == 'text.xcconfig'
      xcconfig.explicit_file_type.should == nil
    end
  end
end
