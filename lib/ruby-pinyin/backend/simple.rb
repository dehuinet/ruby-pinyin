# -*- coding: utf-8 -*-

module PinYin
  module Backend
    class Simple

      def initialize(override_files=[])
        @override_files = override_files
      end

      def romanize(str, tone=nil, include_punctuations=false, data_hash={})
        res = []
        return res unless str && !str.empty?
        
        word_hash = {}
        data_hash.each do|key, value|
          t = key.unpack('U*').first
          code = sprintf('%x',t).upcase
          word_hash.store(code, value)
        end

        str.unpack('U*').each_with_index do |t,idx|
          code = sprintf('%x',t).upcase
          readings = codes[code]

          index = word_hash.fetch(code) if word_hash.member?(code)
          if readings
            res << Value.new(format(readings, tone, index), false)
          else
            val = [t].pack('U*')
            if val =~ /^[_0-9a-zA-Z\s]*$/ # 复原，去除特殊字符,如全角符号等。
              if res.last && res.last.english?
                res.last << Value.new(val, true)
              elsif val != ' '
                res << Value.new(val, true)
              end
            elsif include_punctuations
              val = [Punctuation[code]].pack('H*') if Punctuation.include?(code)
              (res.last ? res.last : res) << Value.new(val, false)
            end
          end
        end

        res.map {|phrase| phrase.split(/\s+/)}.flatten
      end

      private

      def codes
        return @codes if @codes

        @codes = {}
        src = File.expand_path('../../data/Mandarin.dat', __FILE__)
        @override_files.unshift(src).each do |file|
          load_codes_from(file)
        end
        @codes
      end

      def load_codes_from(file)
        File.readlines(file).map do |line|
          code, readings = line.split(' ')
          @codes[code] = readings.split(',')
        end
      end

      def format(readings, tone, index=0)
        index = 0 unless index
        index = 0 if index >= readings.size
        case tone
        when :unicode
          readings[index]
        when :ascii, true
          PinYin::Util.to_ascii(readings[index])
        else
          PinYin::Util.to_ascii(readings[index], false)
        end
      end

    end
  end
end
