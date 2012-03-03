# encoding: utf-8

# This is part of ActiveSupport, which is available under the MIT license>
#
# Copyright (c) 2005-2010 David Heinemeier Hansson
#
# From files:
# * https://raw.github.com/rails/rails/2-3-stable/activesupport/lib/active_support/inflector.rb
# * https://raw.github.com/rails/rails/2-3-stable/activesupport/lib/active_support/inflections.rb
# * https://raw.github.com/rails/rails/2-3-stable/activesupport/lib/active_support/core_ext/string/inflections.rb

require 'singleton'

module Xcodeproj
  module ActiveSupport
    # The Inflector transforms words from singular to plural, class names to table names, modularized class names to ones without,
    # and class names to foreign keys. The default inflections for pluralization, singularization, and uncountable words are kept
    # in inflections.rb.
    #
    # The Rails core team has stated patches for the inflections library will not be accepted
    # in order to avoid breaking legacy applications which may be relying on errant inflections.
    # If you discover an incorrect inflection and require it for your application, you'll need
    # to correct it yourself (explained below).
    module Inflector
      extend self

      # A singleton instance of this class is yielded by Inflector.inflections, which can then be used to specify additional
      # inflection rules. Examples:
      #
      #   ActiveSupport::Inflector.inflections do |inflect|
      #     inflect.plural /^(ox)$/i, '\1\2en'
      #     inflect.singular /^(ox)en/i, '\1'
      #
      #     inflect.irregular 'octopus', 'octopi'
      #
      #     inflect.uncountable "equipment"
      #   end
      #
      # New rules are added at the top. So in the example above, the irregular rule for octopus will now be the first of the
      # pluralization and singularization rules that is runs. This guarantees that your rules run before any of the rules that may
      # already have been loaded.
      class Inflections
        include Singleton

        attr_reader :plurals, :singulars, :uncountables, :humans

        def initialize
          @plurals, @singulars, @uncountables, @humans = [], [], [], []
        end

        # Specifies a new pluralization rule and its replacement. The rule can either be a string or a regular expression.
        # The replacement should always be a string that may include references to the matched data from the rule.
        def plural(rule, replacement)
          @uncountables.delete(rule) if rule.is_a?(String)
          @uncountables.delete(replacement)
          @plurals.insert(0, [rule, replacement])
        end

        # Specifies a new singularization rule and its replacement. The rule can either be a string or a regular expression.
        # The replacement should always be a string that may include references to the matched data from the rule.
        def singular(rule, replacement)
          @uncountables.delete(rule) if rule.is_a?(String)
          @uncountables.delete(replacement)
          @singulars.insert(0, [rule, replacement])
        end

        # Specifies a new irregular that applies to both pluralization and singularization at the same time. This can only be used
        # for strings, not regular expressions. You simply pass the irregular in singular and plural form.
        #
        # Examples:
        #   irregular 'octopus', 'octopi'
        #   irregular 'person', 'people'
        def irregular(singular, plural)
          @uncountables.delete(singular)
          @uncountables.delete(plural)
          if singular[0,1].upcase == plural[0,1].upcase
            plural(Regexp.new("(#{singular[0,1]})#{singular[1..-1]}$", "i"), '\1' + plural[1..-1])
            singular(Regexp.new("(#{plural[0,1]})#{plural[1..-1]}$", "i"), '\1' + singular[1..-1])
          else
            plural(Regexp.new("#{singular[0,1].upcase}(?i)#{singular[1..-1]}$"), plural[0,1].upcase + plural[1..-1])
            plural(Regexp.new("#{singular[0,1].downcase}(?i)#{singular[1..-1]}$"), plural[0,1].downcase + plural[1..-1])
            singular(Regexp.new("#{plural[0,1].upcase}(?i)#{plural[1..-1]}$"), singular[0,1].upcase + singular[1..-1])
            singular(Regexp.new("#{plural[0,1].downcase}(?i)#{plural[1..-1]}$"), singular[0,1].downcase + singular[1..-1])
          end
        end

        # Add uncountable words that shouldn't be attempted inflected.
        #
        # Examples:
        #   uncountable "money"
        #   uncountable "money", "information"
        #   uncountable %w( money information rice )
        def uncountable(*words)
          (@uncountables << words).flatten!
        end

        # Specifies a humanized form of a string by a regular expression rule or by a string mapping.
        # When using a regular expression based replacement, the normal humanize formatting is called after the replacement.
        # When a string is used, the human form should be specified as desired (example: 'The name', not 'the_name')
        #
        # Examples:
        #   human /_cnt$/i, '\1_count'
        #   human "legacy_col_person_name", "Name"
        def human(rule, replacement)
          @humans.insert(0, [rule, replacement])
        end

        # Clears the loaded inflections within a given scope (default is <tt>:all</tt>).
        # Give the scope as a symbol of the inflection type, the options are: <tt>:plurals</tt>,
        # <tt>:singulars</tt>, <tt>:uncountables</tt>, <tt>:humans</tt>.
        #
        # Examples:
        #   clear :all
        #   clear :plurals
        def clear(scope = :all)
          case scope
            when :all
              @plurals, @singulars, @uncountables = [], [], []
            else
              instance_variable_set "@#{scope}", []
          end
        end
      end

      # Yields a singleton instance of Inflector::Inflections so you can specify additional
      # inflector rules.
      #
      # Example:
      #   ActiveSupport::Inflector.inflections do |inflect|
      #     inflect.uncountable "rails"
      #   end
      def inflections
        if block_given?
          yield Inflections.instance
        else
          Inflections.instance
        end
      end

      # Returns the plural form of the word in the string.
      #
      # Examples:
      #   "post".pluralize             # => "posts"
      #   "octopus".pluralize          # => "octopi"
      #   "sheep".pluralize            # => "sheep"
      #   "words".pluralize            # => "words"
      #   "CamelOctopus".pluralize     # => "CamelOctopi"
      def pluralize(word)
        result = word.to_s.dup

        if word.empty? || inflections.uncountables.include?(result.downcase)
          result
        else
          inflections.plurals.each { |(rule, replacement)| break if result.gsub!(rule, replacement) }
          result
        end
      end

      # The reverse of +pluralize+, returns the singular form of a word in a string.
      #
      # Examples:
      #   "posts".singularize            # => "post"
      #   "octopi".singularize           # => "octopus"
      #   "sheep".singluarize            # => "sheep"
      #   "word".singularize             # => "word"
      #   "CamelOctopi".singularize      # => "CamelOctopus"
      def singularize(word)
        result = word.to_s.dup

        if inflections.uncountables.any? { |inflection| result =~ /#{inflection}\Z/i }
          result
        else
          inflections.singulars.each { |(rule, replacement)| break if result.gsub!(rule, replacement) }
          result
        end
      end

      # By default, +camelize+ converts strings to UpperCamelCase. If the argument to +camelize+
      # is set to <tt>:lower</tt> then +camelize+ produces lowerCamelCase.
      #
      # +camelize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
      #
      # Examples:
      #   "active_record".camelize                # => "ActiveRecord"
      #   "active_record".camelize(:lower)        # => "activeRecord"
      #   "active_record/errors".camelize         # => "ActiveRecord::Errors"
      #   "active_record/errors".camelize(:lower) # => "activeRecord::Errors"
      def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
        if first_letter_in_uppercase
          lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
        else
          lower_case_and_underscored_word[0,1].downcase + camelize(lower_case_and_underscored_word)[1..-1]
        end
      end

      # Capitalizes all the words and replaces some characters in the string to create
      # a nicer looking title. +titleize+ is meant for creating pretty output. It is not
      # used in the Rails internals.
      #
      # +titleize+ is also aliased as as +titlecase+.
      #
      # Examples:
      #   "man from the boondocks".titleize # => "Man From The Boondocks"
      #   "x-men: the last stand".titleize  # => "X Men: The Last Stand"
      def titleize(word)
        humanize(underscore(word)).gsub(/\b('?[a-z])/) { $1.capitalize }
      end

      # The reverse of +camelize+. Makes an underscored, lowercase form from the expression in the string.
      #
      # Changes '::' to '/' to convert namespaces to paths.
      #
      # Examples:
      #   "ActiveRecord".underscore         # => "active_record"
      #   "ActiveRecord::Errors".underscore # => active_record/errors
      def underscore(camel_cased_word)
        camel_cased_word.to_s.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end

      # Replaces underscores with dashes in the string.
      #
      # Example:
      #   "puni_puni" # => "puni-puni"
      def dasherize(underscored_word)
        underscored_word.gsub(/_/, '-')
      end

      # Capitalizes the first word and turns underscores into spaces and strips a
      # trailing "_id", if any. Like +titleize+, this is meant for creating pretty output.
      #
      # Examples:
      #   "employee_salary" # => "Employee salary"
      #   "author_id"       # => "Author"
      def humanize(lower_case_and_underscored_word)
        result = lower_case_and_underscored_word.to_s.dup

        inflections.humans.each { |(rule, replacement)| break if result.gsub!(rule, replacement) }
        result.gsub(/_id$/, "").gsub(/_/, " ").capitalize
      end

      # Removes the module part from the expression in the string.
      #
      # Examples:
      #   "ActiveRecord::CoreExtensions::String::Inflections".demodulize # => "Inflections"
      #   "Inflections".demodulize                                       # => "Inflections"
      def demodulize(class_name_in_module)
        class_name_in_module.to_s.gsub(/^.*::/, '')
      end

      # Create a class name from a plural table name like Rails does for table names to models.
      # Note that this returns a string and not a Class. (To convert to an actual class
      # follow +classify+ with +constantize+.)
      #
      # Examples:
      #   "egg_and_hams".classify # => "EggAndHam"
      #   "posts".classify        # => "Post"
      #
      # Singular names are not handled correctly:
      #   "business".classify     # => "Busines"
      def classify(table_name)
        # strip out any leading schema name
        camelize(singularize(table_name.to_s.sub(/.*\./, '')))
      end

      # Turns a number into an ordinal string used to denote the position in an
      # ordered sequence such as 1st, 2nd, 3rd, 4th.
      #
      # Examples:
      #   ordinalize(1)     # => "1st"
      #   ordinalize(2)     # => "2nd"
      #   ordinalize(1002)  # => "1002nd"
      #   ordinalize(1003)  # => "1003rd"
      def ordinalize(number)
        if (11..13).include?(number.to_i % 100)
          "#{number}th"
        else
          case number.to_i % 10
            when 1; "#{number}st"
            when 2; "#{number}nd"
            when 3; "#{number}rd"
            else    "#{number}th"
          end
        end
      end
    end

    Inflector.inflections do |inflect|
      inflect.plural(/$/, 's')
      inflect.plural(/s$/i, 's')
      inflect.plural(/(ax|test)is$/i, '\1es')
      inflect.plural(/(octop|vir)us$/i, '\1i')
      inflect.plural(/(alias|status)$/i, '\1es')
      inflect.plural(/(bu)s$/i, '\1ses')
      inflect.plural(/(buffal|tomat)o$/i, '\1oes')
      inflect.plural(/([ti])um$/i, '\1a')
      inflect.plural(/sis$/i, 'ses')
      inflect.plural(/(?:([^f])fe|([lr])f)$/i, '\1\2ves')
      inflect.plural(/(hive)$/i, '\1s')
      inflect.plural(/([^aeiouy]|qu)y$/i, '\1ies')
      inflect.plural(/(x|ch|ss|sh)$/i, '\1es')
      inflect.plural(/(matr|vert|ind)(?:ix|ex)$/i, '\1ices')
      inflect.plural(/([m|l])ouse$/i, '\1ice')
      inflect.plural(/^(ox)$/i, '\1en')
      inflect.plural(/(quiz)$/i, '\1zes')

      inflect.singular(/s$/i, '')
      inflect.singular(/(n)ews$/i, '\1ews')
      inflect.singular(/([ti])a$/i, '\1um')
      inflect.singular(/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, '\1\2sis')
      inflect.singular(/(^analy)ses$/i, '\1sis')
      inflect.singular(/([^f])ves$/i, '\1fe')
      inflect.singular(/(hive)s$/i, '\1')
      inflect.singular(/(tive)s$/i, '\1')
      inflect.singular(/([lr])ves$/i, '\1f')
      inflect.singular(/([^aeiouy]|qu)ies$/i, '\1y')
      inflect.singular(/(s)eries$/i, '\1eries')
      inflect.singular(/(m)ovies$/i, '\1ovie')
      inflect.singular(/(x|ch|ss|sh)es$/i, '\1')
      inflect.singular(/([m|l])ice$/i, '\1ouse')
      inflect.singular(/(bus)es$/i, '\1')
      inflect.singular(/(o)es$/i, '\1')
      inflect.singular(/(shoe)s$/i, '\1')
      inflect.singular(/(cris|ax|test)es$/i, '\1is')
      inflect.singular(/(octop|vir)i$/i, '\1us')
      inflect.singular(/(alias|status)es$/i, '\1')
      inflect.singular(/^(ox)en/i, '\1')
      inflect.singular(/(vert|ind)ices$/i, '\1ex')
      inflect.singular(/(matr)ices$/i, '\1ix')
      inflect.singular(/(quiz)zes$/i, '\1')
      inflect.singular(/(database)s$/i, '\1')

      inflect.irregular('person', 'people')
      inflect.irregular('man', 'men')
      inflect.irregular('child', 'children')
      inflect.irregular('sex', 'sexes')
      inflect.irregular('move', 'moves')
      inflect.irregular('cow', 'kine')

      inflect.uncountable(%w(equipment information rice money species series fish sheep jeans))
    end
  end
end

# String inflections define new methods on the String class to transform names for different purposes.
class String
  include Xcodeproj::ActiveSupport

  # Returns the plural form of the word in the string.
  #
  #   "post".pluralize             # => "posts"
  #   "octopus".pluralize          # => "octopi"
  #   "sheep".pluralize            # => "sheep"
  #   "words".pluralize            # => "words"
  #   "the blue mailman".pluralize # => "the blue mailmen"
  #   "CamelOctopus".pluralize     # => "CamelOctopi"
  def pluralize
    Inflector.pluralize(self)
  end

  # The reverse of +pluralize+, returns the singular form of a word in a string.
  #
  #   "posts".singularize            # => "post"
  #   "octopi".singularize           # => "octopus"
  #   "sheep".singularize            # => "sheep"
  #   "word".singularize             # => "word"
  #   "the blue mailmen".singularize # => "the blue mailman"
  #   "CamelOctopi".singularize      # => "CamelOctopus"
  def singularize
    Inflector.singularize(self)
  end

  # By default, +camelize+ converts strings to UpperCamelCase. If the argument to camelize
  # is set to <tt>:lower</tt> then camelize produces lowerCamelCase.
  #
  # +camelize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
  #
  #   "active_record".camelize                # => "ActiveRecord"
  #   "active_record".camelize(:lower)        # => "activeRecord"
  #   "active_record/errors".camelize         # => "ActiveRecord::Errors"
  #   "active_record/errors".camelize(:lower) # => "activeRecord::Errors"
  def camelize(first_letter = :upper)
    case first_letter
      when :upper then Inflector.camelize(self, true)
      when :lower then Inflector.camelize(self, false)
    end
  end
  alias_method :camelcase, :camelize

  # Capitalizes all the words and replaces some characters in the string to create
  # a nicer looking title. +titleize+ is meant for creating pretty output. It is not
  # used in the Rails internals.
  #
  # +titleize+ is also aliased as +titlecase+.
  #
  #   "man from the boondocks".titleize # => "Man From The Boondocks"
  #   "x-men: the last stand".titleize  # => "X Men: The Last Stand"
  def titleize
    Inflector.titleize(self)
  end
  alias_method :titlecase, :titleize

  # The reverse of +camelize+. Makes an underscored, lowercase form from the expression in the string.
  # 
  # +underscore+ will also change '::' to '/' to convert namespaces to paths.
  #
  #   "ActiveRecord".underscore         # => "active_record"
  #   "ActiveRecord::Errors".underscore # => active_record/errors
  def underscore
    Inflector.underscore(self)
  end

  # Replaces underscores with dashes in the string.
  #
  #   "puni_puni" # => "puni-puni"
  def dasherize
    Inflector.dasherize(self)
  end

  # Removes the module part from the constant expression in the string.
  #
  #   "ActiveRecord::CoreExtensions::String::Inflections".demodulize # => "Inflections"
  #   "Inflections".demodulize                                       # => "Inflections"
  def demodulize
    Inflector.demodulize(self)
  end

  # Create a class name from a plural table name like Rails does for table names to models.
  # Note that this returns a string and not a class. (To convert to an actual class
  # follow +classify+ with +constantize+.)
  #
  #   "egg_and_hams".classify # => "EggAndHam"
  #   "posts".classify        # => "Post"
  #
  # Singular names are not handled correctly.
  #
  #   "business".classify # => "Busines"
  def classify
    Inflector.classify(self)
  end
  
  # Capitalizes the first word, turns underscores into spaces, and strips '_id'.
  # Like +titleize+, this is meant for creating pretty output.
  #
  #   "employee_salary" # => "Employee salary" 
  #   "author_id"       # => "Author"
  def humanize
    Inflector.humanize(self)
  end
end
