module Exercism
  class ToolingJob
    require 'aws-sdk-s3'
    require 'redis'

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

      redis = Exercism.redis_tooling_client
      redis.multi do
        redis.set(
          "job:#{job_id}",
          data.to_json
        )
        redis.rpush(key_for_queued, job_id)
        redis.set("submission:#{submission_uuid}:#{type}", job_id)
      end
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

    def method_missing(meth)
      super unless respond_to_missing?(meth)

      data[meth]
    end

    def locked!
      redis = Exercism.redis_tooling_client
      redis.multi do
        redis.lrem(key_for_queued, 1, id)
        redis.rpush(key_for_locked, id)
      end
    end

    def executed!(status, output)
      redis = Exercism.redis_tooling_client
      redis.multi do
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
    end

    def processed!
      redis = Exercism.redis_tooling_client
      redis.multi do
        redis.lrem(key_for_executed, 1, id)
        redis.rpush(key_for_processed, id)
      end
    end

    def cancelled!
      redis = Exercism.redis_tooling_client
      redis.multi do
        redis.lrem(key_for_queued, 1, id)
        redis.rpush(key_for_cancelled, id)
      end
    end

    def ==(other)
      id == other.id
    end

    def stderr
      read_s3_file('stderr')
    end

    def stdout
      read_s3_file('stdout')
    end

    private
    attr_reader :data

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

    %w[queued locked executed processed cancelled].each do |key|
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
