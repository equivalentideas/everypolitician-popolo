require 'everypolitician/popolo/version'

module Everypolitician
  module Popolo
    class Error < StandardError; end

    class JSON
      attr_reader :popolo

      def initialize(popolo)
        @popolo = popolo
      end

      def persons
        People.new(popolo[:persons])
      end
    end

    class People
      include Enumerable

      attr_reader :documents

      def initialize(documents)
        @documents = documents.map { |p| Person.new(p) }
      end

      def each(&block)
        documents.each(&block)
      end
    end

    class Person
      attr_reader :document

      def initialize(document)
        @document = document
      end

      def [](key)
        document[key]
      end

      def key?(key)
        document.key?(key)
      end

      def twitter
        if key?(:contact_details)
          if twitter_contact = self[:contact_details].find { |d| d[:type] == 'twitter' }
            return standardised_twitter(twitter_contact[:value].strip)
          end
        end

        if key?(:links)
          if twitter_link = self[:links].find { |d| d[:note][/twitter/i] }
            return standardised_twitter(twitter_link[:url].strip)
          end
        end
      end

      def standardised_twitter(t)
        return if t.to_s.empty?
        return $1 if t.match /^\@(\w+)$/
        return $1 if t.match /^(\w+)$/
        return $1 if t.match %r{(?:www.)?twitter.com/@?(\w+)$}i

        # Odd special cases
        return $1 if t.match %r{twitter.com/search\?q=%23(\w+)}i
        return $1 if t.match %r{twitter.com/#!/https://twitter.com/(\w+)}i
        return $1 if t.match %r{(?:www.)?twitter.com/#!/(\w+)[/\?]?}i
        return $1 if t.match %r{(?:www.)?twitter.com/@?(\w+)[/\/]?}i
        raise Error, "Unknown twitter handle: #{t.to_s}"
      end
    end
  end
end

EveryPolitician = Everypolitician
