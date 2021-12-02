=begin

CREATE TABLE `tooling_jobs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(40) NOT NULL,
  `status` varchar(20) NOT NULL,
  `priority` varchar(20) NOT NULL,
  `data` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tooling_jobs_on_uuid` (`uuid`),
  KEY `index_tooling_jobs_priority_status` (`priority`, `status`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci

=end

module Exercism
  class ToolingJobMysql
    require 'aws-sdk-s3'
    require 'mysql2'
    require 'sequel'

    extend Mandate::Memoize

    def self.create!(type, submission_uuid, language, exercise, extra = {})
      job_id = SecureRandom.uuid.tr('-', '')
      data = extra.merge(
        id: job_id,
        submission_uuid: submission_uuid,
        type: type,
        language: language,
        exercise: exercise,
        created_at: Time.now.utc.to_i
      )

      mysql = Exercism.mysql_tooling_client
      mysql.
      mysql.multi do
        mysql.set(
          "job:#{job_id}",
          data.to_json
        )
        mysql.rpush(key_for_queued, job_id)
        mysql.set("submission:#{submission_uuid}:#{type}", job_id)
      end
      new(job_id, data)
    end

    def self.find(id)
      json = Exercism.mysql_tooling_client.get("job:#{id}")
      new(id, JSON.parse(json))
    end

    def self.find_for_submission_uuid_and_type(submission_uuid, type)
      mysql = Exercism.mysql_tooling_client
      job_id = mysql.get("submission:#{submission_uuid}:#{type}")
      json = mysql.get("job:#{job_id}")
      new(job_id, JSON.parse(json))
    end

    attr_reader :id

    def initialize(id, data)
      @id = id
      @data = data.transform_keys(&:to_sym).freeze
    end

    def to_h
      data.to_h
    end

    def respond_to_missing?(meth, include_all = true)
      data.key?(meth) || super
    end

    def method_missing(meth, *args)
      super unless respond_to_missing?(meth)

      data[meth]
    end

    def locked!
      mysql = Exercism.mysql_tooling_client
      mysql.multi do
        mysql.lrem(key_for_queued, 1, id)
        mysql.rpush(key_for_locked, id)
      end
    end

    def executed!(status, output)
      mysql = Exercism.mysql_tooling_client
      mysql.multi do
        mysql.lrem(key_for_queued, 1, id)
        mysql.lrem(key_for_locked, 1, id)
        mysql.rpush(key_for_executed, id)

        mysql.set(
          "job:#{id}",
          data.merge(
            execution_status: status,
            execution_output: output
          ).to_json
        )
      end
    end

    def processed!
      mysql = Exercism.mysql_tooling_client
      mysql.multi do
        mysql.lrem(key_for_executed, 1, id)
        mysql.del("job:#{id}")
        mysql.del("submission:#{data[:submission_uuid]}:#{data[:type]}")
      end
    end

    def cancelled!
      mysql = Exercism.mysql_tooling_client
      mysql.multi do
        mysql.lrem(key_for_queued, 1, id)
        mysql.rpush(key_for_cancelled, id)
      end
    end

    def ==(other)
      id == other.id
    end

    def store_stdout!(content)
      write_s3_file!(:stdout, content)
    end

    def store_stderr!(content)
      write_s3_file!(:stderr, content)
    end

    def store_metadata!(content)
      write_s3_file!('metadata.json', content.to_json)
    end

    def stdout
      read_s3_file(:stdout)
    end

    def stderr
      read_s3_file(:stderr)
    end

    def metadata
      JSON.parse(read_s3_file('metadata.json'))
    rescue JSON::ParserError
      {}
    end

    private
    attr_reader :data

    def write_s3_file!(name, content)
      Exercism.s3_client.put_object(
        bucket: s3_bucket_name,
        key: "#{s3_folder}/#{name}",
        body: content,
        acl: 'private'
      )
    end

    def read_s3_file(name)
      Exercism.s3_client.get_object(
        bucket: s3_bucket_name,
        key: "#{s3_folder}/#{name}"
      ).body.read
    rescue StandardError
      ""
    end

    memoize
    def s3_folder
      "#{Exercism.env}/#{id}"
    end

    memoize
    def s3_bucket_name
      Exercism.config.aws_tooling_jobs_bucket
    end

    %w[
      queued queued_for_background_processing 
      locked executed cancelled
    ].each do |key|
      ToolingJob.singleton_class.class_eval do
        define_method "key_for_#{key}" do
          Exercism.env.production? ? key : "#{Exercism.env}:#{key}"
        end
      end

      define_method "key_for_#{key}" do
        self.class.send("key_for_#{key}")
      end
    end
  end
end

