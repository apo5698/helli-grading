# frozen_string_literal: true

require 'zip'

module Helli
  module Generator
    module File
      class << self
        # Generates a random moodle submissions zip file.
        #
        # @param [String] filename output filename
        # @param [Array<Hash>] worksheet parsed moodle grade worksheet data
        def moodle_zip(filename, worksheet)
          stringio = Zip::OutputStream.write_buffer do |io|
            worksheet.each do |participant|
              full_name = participant[:full_name].split(' ')
              # Swaps first and last name
              full_name[0], full_name[1] = full_name[1], full_name[0]
              full_name = full_name.join(' ')
              # noinspection SpellCheckingInspection
              dirname = "#{[full_name,
                            participant[:email_address].sub('@', 'AT'),
                            participant[:identifier]].join('__')}_assignsubmission_file_"

              # Generates java code
              code =
                "public class Main {\n"\
                "    public static void main(String[] args) {\n"\
                "        System.out.println('My name is #{full_name}');\n"\
                "    }\n"\
                "}\n"

              # Writes the iostream
              io.put_next_entry(::File.join(dirname, 'Main.java'))
              io.write(code)
            end
          end

          # Writes data to zip file
          ::File.new(filename, 'wb').write(stringio.string)
        end
      end
    end
  end
end
