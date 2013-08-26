# encoding: UTF-8

require File.expand_path('../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::Project do

    describe "In general" do
      it "return the objects by UUID hash" do
        @project.objects_by_uuid.should.not.be.nil
      end

      it "returns the root object" do
        @project.root_object.class.should == PBXProject
      end
    end

    describe "Concerning initialization from scratch" do
      it "initializes to the last known archive version" do
        @project.archive_version.should == Xcodeproj::Constants::LAST_KNOWN_ARCHIVE_VERSION.to_s
      end

      it "initializes to the classes to the empty hash" do
        @project.classes.should == {}
      end

      it "initializes to the last known archive version" do
        @project.object_version.should == Xcodeproj::Constants::LAST_KNOWN_OBJECT_VERSION.to_s
      end
      it "sets itself as the owner of the root object" do
        @project.root_object.referrers.should == [@project]
      end

      it "includes the root object in the objects by UUID hash" do
        uuid = @project.root_object.uuid
        @project.objects_by_uuid[uuid].should.not.be.nil
      end

      it "initializes the root object main group" do
        @project.root_object.main_group.class.should == PBXGroup
      end

      it "initializes the root object products group" do
        product_ref_group = @project.root_object.product_ref_group
        product_ref_group.class.should == PBXGroup
        @project.root_object.main_group.children.should.include?(product_ref_group)
      end

      it "initializes the root object configuration list" do
        list = @project.root_object.build_configuration_list
        list.class.should == XCConfigurationList
        list.default_configuration_name.should == 'Release'
        list.default_configuration_is_visible.should == '0'

        configurations = list.build_configurations
        configurations.map(&:name).sort.should == %w| Debug Release |
        list.build_settings('Debug').should == {}
        list.build_settings('Release').should == {}
      end

      it "initializes the default Debug and Release configurations plus the extra App Store and Test configurations" do
        @project = Xcodeproj::Project.new('Project.xcodeproj', { 'App Store' => :release, 'Test' => :debug })
        @project.build_configurations.map(&:name).sort.should == [ 'App Store', 'Debug', 'Release', 'Test' ]
      end

      it "adds the frameworks group" do
        @project['Frameworks'].class.should == PBXGroup
      end

      it "it should have DNS_BLOCK_ASSERTIONS=1 flag in Release configuration" do
        target = @project.new_target(:static_library, 'Pods', :ios)
        target.build_configuration_list.should.not.be.nil

        # Release
        build_settings = target.build_configuration_list.build_settings('Release')
        build_settings['OTHER_CFLAGS'].should.include('-DNS_BLOCK_ASSERTIONS=1')
        build_settings['OTHER_CPLUSPLUSFLAGS'].should.include('-DNS_BLOCK_ASSERTIONS=1')

        # Debug
        build_settings = target.build_configuration_list.build_settings('Debug')
        if !build_settings['OTHER_CFLAGS'].nil?
          build_settings['OTHER_CFLAGS'].should.not.include('-DNS_BLOCK_ASSERTIONS=1')
        end
        if !build_settings['OTHER_CPLUSPLUSFLAGS'].nil?
          build_settings['OTHER_CPLUSPLUSFLAGS'].should.not.include('-DNS_BLOCK_ASSERTIONS=1')
        end

      end
    end

    describe "Concerning plist initialization & serialization" do
      before do
        @project = Xcodeproj::Project.open(fixture_path("Sample Project/Cocoa Application.xcodeproj"))
      end

      it "sets itself as the owner of the root object" do
        # The root object might be referenced by other objects like
        # the PBXContainerItemProxy
        @project.root_object.referrers.should.include?(@project)
      end

      # It implicitly checks that all the attributes for the known isas.
      # Therefore, If a new isa or attribute is found it should added to the
      # sample project.
      #
      it "can be loaded from a plist" do
        @project.root_object.should.not == nil
        @project.main_group.should.not == nil
        @project["Cocoa Application"].should.not.be.nil
      end

      # This ensures that there is no loss (or modification) of information by
      # going to the object tree and serializing it back to a plist.
      #
      it "can regenerate the EXACT plist that initialized it" do
        plist = Xcodeproj.read_plist(fixture_path("Sample Project/Cocoa Application.xcodeproj/project.pbxproj"))
        generated = @project.to_hash
        diff = Xcodeproj::Differ.diff(generated, plist)
        diff.should.be.nil
      end

      it "doesn't add default attributes to objects generated from a plist" do
        uuid = "UUID"
        expected = { "isa" => "PBXFileReference", "sourceTree" => "SOURCE_ROOT" }
        objects_by_uuid_plist = {}
        objects_by_uuid_plist[uuid] = expected
        obj = @project.new_from_plist(uuid, objects_by_uuid_plist)
        attrb = PBXFileReference.simple_attributes.find { |a| a.name == :include_in_index }
        attrb.default_value.should == '1'
        obj.to_hash.should == expected
      end

      extend SpecHelper::TemporaryDirectory
      it "can open a project and save it without altering any information" do
        plist = Xcodeproj.read_plist(fixture_path("Sample Project/Cocoa Application.xcodeproj/project.pbxproj"))
        @project.save_as(File.join(temporary_directory, 'Pods.xcodeproj'))
        project_file = (temporary_directory + 'Pods.xcodeproj/project.pbxproj')
        Xcodeproj.read_plist(project_file.to_s).should == plist
      end

      it "escapes non ASCII characters in the project" do
        @project = Xcodeproj::Project.new('Project.xcodeproj')
        file_ref = @project.new_file('わくわく')
        file_ref.name = 'わくわく'
        file_ref = @project.new_file('Cédric')
        file_ref.name = 'Cédric'
        projpath = File.join(temporary_directory, 'Pods.xcodeproj')
        @project.save_as(projpath)
        file = File.join(projpath, 'project.pbxproj')
        contents = File.read(file)
        contents.should.not.include('わくわく')
        contents.should.include('&#12431;&#12367;&#12431;&#12367;')
        contents.should.not.include('Cédric')
        contents.should.include('C&#233;dric')
      end
    end

    describe "Concerning object creation" do
      it "creates a new object" do
        @project.new(PBXFileReference).class.should == PBXFileReference
      end

      it "doesn't add an object to the objects tree until an object references it" do
        obj = @project.new(PBXFileReference)
        obj.path = 'some/file.m'
        @project.objects_by_uuid[obj.uuid].should == nil
      end

      it "adds an object to the objects tree once an object references it" do
        obj = @project.new(PBXFileReference)
        @project.main_group << obj
        @project.objects_by_uuid[obj.uuid].should == obj
      end

      it "initializes new objects (not created form a plist) with the default values" do
        obj = @project.new(PBXFileReference)
        expected = {
          "isa"            => "PBXFileReference",
          "sourceTree"     => "SOURCE_ROOT",
          "includeInIndex" => "1"
        }
        obj.to_hash.should == expected
      end

      it "generates new UUIDs" do
        @project.generate_uuid.length.should == 24
      end

      it "generates a given number of unique UUIDs" do
        before_count = @project.generated_uuids.count.should
        @project.generate_available_uuid_list(100)
        # Checking against 75 instead of 100 to prevent this test for failing
        # for bad luck. Not sure what is the statical likelihood of 25
        # collision out of 100.
        @project.generated_uuids.count.should >= (before_count + 75)
      end

      it "keeps track of the known UUIDs even if objects are not in the objects hash" do
        obj = @project.new(PBXFileReference)
        @project.uuids.should.not.include?(obj.uuid)
        @project.generated_uuids.should.include?(obj.uuid)
      end
    end

    describe "Concerning helpers" do
      it "returns all the objects referred in the project" do
        expected = [
          "ConfigurationList",
          "Debug",
          "Frameworks",
          "Main Group",
          "Products",
          "Project",
          "Release"
        ]
        @project.objects.map(&:display_name).sort.should == expected
      end

      it "returns the UUIDs of all the objects referred in the project" do
        @project.uuids.count.should > 1
        @project.uuids.first.length.should == 24
      end

      it "lists the objects with a given class" do
        expected = ["Frameworks", "Main Group", "Products"]
        @project.list_by_class(PBXGroup).map(&:display_name).sort.should == expected
      end

      it "returns the main group" do
        @project.main_group.class.should == PBXGroup
        @project.main_group.referrers.should.include?(@project.root_object)
      end

      it "returns the groups of the main group" do
        expected = ["Products", "Frameworks"]
        @project.groups.map(&:display_name).should == expected
      end

      it "returns the group with the given path" do
        g = @project.new_group('libPusher', 'Pods')
        @project ['Pods/libPusher'].should == g
      end

      it "returns all the files of the project" do
        f = @project.products_group.new_static_library('Pods')
        @project.files.should.include?(f)
      end

      it "returns the targets" do
        target = @project.new_target(:static_library, 'Pods', :ios).product_reference
        @project.products.should.include?(target)
      end

      it "returns the products group" do
        g = @project.products_group
        g.class.should == PBXGroup
        g.referrers.should.include?(@project.main_group)
      end

      it "returns the products" do
        file = @project.new_target(:static_library, 'Pods', :ios).product_reference
        @project.products.should.include?(file)
      end

      it "returns the frameworks group" do
        g = @project.frameworks_group
        g.class.should == PBXGroup
        g.referrers.should.include?(@project.main_group)
        g.name.should == 'Frameworks'
      end

      it "returns the build configurations" do
        @project.build_configurations.map(&:name).sort.should == %w| Debug Release |
      end

      it "returns the build settings" do
        @project.build_settings('Debug').class.should == Hash
      end

      it "returns the top-level project configurations and build settings" do
        list = @project.root_object.build_configuration_list
        list.default_configuration_name.should == 'Release'
        list.default_configuration_is_visible.should == '0'

        @project.build_settings('Debug').should == {}
        @project.build_settings('Release').should == {}
      end

      it "returns a succinct diff representation of the project" do
        before_proj = @project.to_tree_hash
        @project.new_group('Pods')
        after_proj = @project.to_tree_hash
        diff = Xcodeproj::Differ.project_diff(before_proj, after_proj)

        diff.should == {
          "rootObject"=>{"mainGroup"=>{"children"=>{
            "project_2"=>[
              {"displayName"=>"Pods", "isa"=>"PBXGroup", "sourceTree"=>"<group>", "name"=>"Pods", "children"=>[]}
            ]
          }}}}
      end

      it "returns a pretty print representation" do
        pretty_print = @project.pretty_print
        pretty_print.should == {
          "File References" => [
            {"Products" => [] },
            {"Frameworks" => [] }
          ],
          "Targets" => [],
          "Build Configurations" => [
            { "Debug" => {"Build Settings" => {} } },
            { "Release" => {"Build Settings" => {} } }
          ]
        }
      end
    end

    #-------------------------------------------------------------------------#


    describe "Concerning helpers for creating new objects" do
      it "adds a new group" do
        group = @project.new_group('A new group', 'Cocoa Application')
        group.isa.should == 'PBXGroup'
        group.name.should == 'A new group'
        @project.objects_by_uuid[group.uuid].should.not.be.nil
        @project['Cocoa Application'].children.should.include group
      end

      it "adds a new file" do
        file = @project.new_file('Classes/Test.h', 'Cocoa Application')
        file.isa.should == 'PBXFileReference'
        file.display_name.should == 'Test.h'
        @project.objects_by_uuid[file.uuid].should.not.be.nil
        @project['Cocoa Application'].children.should.include file
      end

      before do
        Xcodeproj::XcodebuildHelper.any_instance.stubs(:last_ios_sdk).returns(Xcodeproj::Constants::LAST_KNOWN_IOS_SDK)
      end

      it "adds a file reference for a system framework, to the Frameworks group" do
        target = stub(:sdk => 'iphoneos5.0')
        file = @project.add_system_framework('QuartzCore', target)
        file.group.should == @project['Frameworks']
        file.name.should == 'QuartzCore.framework'
      end

      it "creates a new target" do
        target = @project.new_target(:static_library, 'Pods', :ios, '6.0')
        target.name.should == 'Pods'
        target.product_type.should == 'com.apple.product-type.library.static'
      end

      it "creates a new resouces bundle" do
        target = @project.new_resources_bundle('Pods', :ios)
        target.name.should == 'Pods'
        target.product_type.should == 'com.apple.product-type.bundle'
      end
    end

    describe "Project schemes" do
      it "return project name as scheme if there are no shared schemes" do
        schemes = Xcodeproj::Project.schemes fixture_path('SharedSchemes/Pods/Pods.xcodeproj')
        schemes[0].should == "Pods"
      end

      it "return all project's shared schemes" do
        schemes = Xcodeproj::Project.schemes fixture_path('SharedSchemes/SharedSchemes.xcodeproj')
        schemes.sort.should == ['SharedSchemes', 'SharedSchemesForTest']
      end

    end
  end
end
