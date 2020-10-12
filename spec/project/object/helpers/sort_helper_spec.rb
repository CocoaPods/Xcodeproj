require File.expand_path('../../../../spec_helper', __FILE__)

module ProjectSpecs
  describe Xcodeproj::XcodeSortString do
    before do
      @helper = XcodeSortString
    end

    #-------------------------------------------------------------------------#

    describe 'In general' do
      it 'sorts names like Xcode' do
        # Let's note that Xcode 10.2 on macOS 10.14.5 does not have a strong ordering
        # when sorting unicode characters that transliterate to the same ascii characters
        # so our unicode tests can stay rudimentary until Xcode is fixed for that.
        # [rdar://50854433](http://www.openradar.me/radar?id=5012044621283328)
        unsorted_names = [
          # spaces comparison
          ' a', '  a', 'a ', 'a  b', 'a a',
          # dots comparison
          '.a', '..a', 'a.', '1.',
          # basic mix
          '1a', '2 a', 'a1', 'a 2',
          # pure integers
          '1', '2', '10', '01',
          # multi integers
          '0.1.1', '0.1.2', '0.1.10', '0.1.01',
          # multi equal integers
          'A1B001', 'A01B1',
          # case comparison
          'A', 'a'
        ]
        if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2.0')
          unsorted_names += [
            # unicode
            'ﬃ ', 'ffh ', 'ffj '
          ]
        end
        sorted = unsorted_names.sort_by { |s| @helper.new(s) }
        # order given by Xcode 10.2 "Sort by Name" on macOS 10.14.5 (ruby 2.3.7p456), English as primary language
        should = [
          '  a',
          ' a',
          '..a',
          '.a',
          '0.1.1',
          '0.1.01',
          '0.1.2',
          '0.1.10',
          '1',
          '01',
          '1.',
          '1a',
          '2',
          '2 a',
          '10',
          'a',
          'A',
          'a ',
          'a  b',
          'a 2',
          'a a',
          'a.',
          'a1',
          'A1B001',
          'A01B1',
        ]
        if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2.0')
          should += [
            'ffh ',
            'ﬃ ',
            'ffj ',
          ]
        end
        sorted.should == should
      end
    end

    #-------------------------------------------------------------------------#
  end
end
