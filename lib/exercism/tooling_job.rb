module Exercism
  class ToolingJob
    require 'aws-sdk-s3'

    extend Mandate::Memoize

    def self.git_cache_key(repo, sha, dir, filepath)
      "#{repo}:#{sha}:#{dir}/#{filepath}"
    end

    def self.create!(
      job_id, type, submission_uuid, efs_dir, language, exercise,
      run_in_background: false,
      **data
    )
      data.merge!(
        id: job_id,
        type:,
        submission_uuid:,
        efs_dir:,
        language:,
        exercise:,
        created_at: Time.now.utc.to_i
      )

      queue_key = run_in_background ? key_for_queued_for_background_processing : key_for_queued
      redis = Exercism.redis_tooling_client
      redis.set("job:#{job_id}", data.to_json)
      redis.set("submission:#{submission_uuid}:#{type}", job_id)
      redis.rpush(queue_key, job_id)

      new(job_id, data)
    end

    def self.find(id)
      json = Exercism.redis_tooling_client.get("job:#{id}")
      new(id, JSON.parse(json))
    end

    def self.find_for_submission_uuid_and_type(submission_uuid, type)
      redis = Exercism.redis_tooling_client
      job_id = redis.get("submission:#{submission_uuid}:#{type}")
      json = redis.get("job:#{job_id}")
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
      redis = Exercism.redis_tooling_client
      redis.lrem(key_for_queued, 1, id)
      redis.rpush(key_for_locked, id)
    end

    def executed!(status, output)
      redis = Exercism.redis_tooling_client
      redis.lrem(key_for_queued, 1, id)
      redis.lrem(key_for_locked, 1, id)
      redis.rpush(key_for_executed, id)

      redis.set(
        "job:#{id}",
        data.merge(
          execution_status: status,
          execution_output: output
        ).to_json
      )
    end

    def processed!
      redis = Exercism.redis_tooling_client
      redis.lrem(key_for_executed, 1, id)
      redis.del("job:#{id}")
      redis.del("submission:#{data[:submission_uuid]}:#{data[:type]}")
    end

    def cancelled!
      redis = Exercism.redis_tooling_client
      redis.lrem(key_for_queued, 1, id)
      redis.rpush(key_for_cancelled, id)
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
    def s3_folder = "#{Exercism.env}/#{id}"

    memoize
    def s3_bucket_name = Exercism.config.aws_tooling_jobs_bucket

    %w[queued queued_for_background_processing locked executed cancelled].each do |key|
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
