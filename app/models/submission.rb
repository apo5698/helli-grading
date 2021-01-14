# frozen_string_literal: true

# A Submission corresponds to one ActiveStorage::Attachment.
class Submission < ApplicationRecord
  #############
  # Constants #
  #############

  # RegExp for directory name inside a Moodle submissions zip file.
  #
  #   match[0]: itself
  #   match[1]: first name
  #   match[2]: last name
  #   match[3]: email username
  #   match[4]: email domain
  #   match[5]: identifier
  MOODLE_DIR_REGEXP = /([A-z]+)\s([A-z]+)__(.+)AT(.+)__(\d+)_assignsubmission_file_/.freeze

  ################
  # Associations #
  ################

  belongs_to :participant

  ###############
  # Attachments #
  ###############

  has_one_attached :attachment

  #############
  # Callbacks #
  #############

  # Also save changes to ActiveStorage::Blob
  after_save -> { attachment.blob.save! }, unless: -> { attachment.blob.nil? }

  ###############
  # Delegations #
  ###############

  # Delegates missing methods to ActiveStorage::Attachment.
  delegate_missing_to :attachment

  class << self
    # Extracts a moodle submissions zip file, attaches enclosed files to the corresponding submission
    # of the participant. Temporary files will be deleted after uploading.
    #
    # @param [String] filename filename
    def upload(filename, assignment_id)
      Dir.mktmpdir do
        Zip::File.open(filename) do |zip|
          # noinspection RubyNilAnalysis, SpellCheckingInspection
          zip.each do |entry|
            entry_name = entry.name
            # For example:
            #   dirname = Hello World__hworldATncsu.edu__123456_assignsubmission_file_
            #   matches = ['Hello', 'World', 'hworld', 'ncsu.edu', '123456']
            matches = Pathname(entry_name).each_filename
                                          .first
                                          .match(MOODLE_DIR_REGEXP)
            # email = email_username @ email_domain
            email = "#{matches[3]}@#{matches[4]}"
            identifier = matches[5].to_i

            # Attaches to Submission model
            # Zip::InputStream does not have #size method, so we need wrap it to a StringIO object
            participant = Participant.find_by(
              assignment_id: assignment_id,
              identifier: identifier,
              email_address: email
            )
            # Submit a wrong zip, maybe
            raise Helli::StudentNotParticipated, [identifier, email] if participant.nil?

            participant.submissions
                       .create!
                       .attachment
                       .attach(io: StringIO.new(entry.get_input_stream.read),
                               filename: File.basename(entry_name))
          end
        end
      end
    end
  end

  # Delegates attributes to ActiveStorage::Blob.
  %i[filename content_type byte_size checksum].each do |column|
    define_method(column) do
      attachment.blob.send(column)
    end
  end

  alias size byte_size

  def filename=(filename)
    attachment.blob.filename = filename
  end
end
