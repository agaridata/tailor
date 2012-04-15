require 'text-table'
require 'pathname'

class Tailor
  module Formatter
    class Text
      def initialize
        @pwd = Pathname(Dir.pwd)
      end

      def line(length=79)
        "##{'-' * length}\n"
      end

      def file_header(file)
        file = Pathname(file)
        message = ""
        message << if defined? Term::ANSIColor
          "# #{'File:'.underscore}\n"
        else
          "# File:\n"
        end

        message << "#   #{file.relative_path_from(@pwd)}\n"
        message << "#\n"

        message
      end

      def file_set_header(file_set)
        message = ""
        message << if defined? Term::ANSIColor
          "# #{'File Set:'.underscore}\n"
        else
          "# File Set:\n"
        end

        message << "#   #{file_set}\n"
        message << "#\n"

        message
      end

      def problems_header(problem_list)
        message = ""
        message << if defined? Term::ANSIColor
          "# #{'Problems:'.underscore}\n"
        else
          "# Problems:\n"
        end

        problem_list.each_with_index do |problem, i|
          position = if problem[:line] == '<EOF>'
            '<EOF>'
          else
            if defined? Term::ANSIColor
              msg = "#{problem[:line].to_s.red.bold}:"
              msg << "#{problem[:column].to_s.red.bold}"
              msg
            else
              "#{problem[:line]}:#{problem[:column]}"
            end
          end

          message << if defined? Term::ANSIColor
            %Q{#  #{(i + 1).to_s.bold}.
#    * position:  #{position}
#    * type:      #{problem[:type].to_s.red}
#    * message:   #{problem[:message].red}
}
          else
            %Q{#  #{(i + 1)}.
#    * position:  #{position}
#    * type:      #{problem[:type]}
#    * message:   #{problem[:message]}
}
          end
        end

        message
      end

      # Prints the report on the file that just got checked.
      #
      # @param [Hash] problems Value should be the file name; keys should be
      #   problems with the file.
      def file_report(problems, file_set_label)
        return if problems.values.first.empty?

        file = problems.keys.first
        problem_list = problems.values.first
        message = line
        message << file_header(file)
        message << file_set_header(file_set_label)
        message << problems_header(problem_list)

        message << <<-MSG
#
#-------------------------------------------------------------------------------
        MSG

        puts message
      end

      # Prints the report on all of the files that just got checked.
      #
      # @param [Hash] problems Values are filenames; keys are problems for each
      #   of those files.
      def summary_report(problems)
        if problems.empty?
          puts "Your files are in style."
        else
          summary_table = ::Text::Table.new
          summary_table.head = [{ value: "Tailor Summary", colspan: 2 }]
          summary_table.rows << [{ value: "File", align: :center },
            { value: "Total Problems", align: :center }]
          summary_table.rows << :separator

          problems.each do |file, problem_list|
            file = Pathname(file)
            summary_table.rows << [
              file.relative_path_from(@pwd), problem_list.size
            ]
          end

          summary_table.rows << :separator
          summary_table.rows << ['TOTAL', problems.values.
            map { |v| v.size }.inject(:+)]

          puts summary_table
        end
      end
    end
  end
end
