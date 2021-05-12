require 'test_helper'

module Exercism
  class ToolingJobTest < Minitest::Test
    def setup
      super

      Exercism.stubs(env: ExercismConfig::Environment.new(:test))

      redis = Exercism.redis_tooling_client
      keys = redis.keys("test:*")
      redis.del(*keys) unless keys.empty?
    end

    def test_retrieves_metadata_from_s3
      job_id = SecureRandom.uuid
      stdout = "Some output"
      stderr = "Some errors"

      bucket = Exercism.config.aws_tooling_jobs_bucket
      folder = "#{Exercism.env}/#{job_id}"
      upload_to_s3(bucket, "#{folder}/stdout", stdout)
      upload_to_s3(bucket, "#{folder}/stderr", stderr)

      job = ToolingJob.new(job_id, {})
      assert_equal stdout, job.stdout
      assert_equal stderr, job.stderr
    end

    def test_cancels_test_runner_job
      redis = Exercism.redis_tooling_client
      submission_uuid = SecureRandom.uuid

      id = ToolingJob.create!(submission_uuid, :test_runner, :ruby, "two-fer")
      ToolingJob.find(id).cancelled!

      assert_nil redis.lindex(ToolingJob.key_for_queued, 0)
      assert_equal id, redis.lindex(ToolingJob.key_for_cancelled, 0)
    end

    def test_locks_job
      redis = Exercism.redis_tooling_client
      submission_uuid = SecureRandom.uuid

      id = ToolingJob.create!(submission_uuid, :test_runner, :ruby, "two-fer")
      ToolingJob.find(id).locked!

      assert_nil redis.lindex(ToolingJob.key_for_queued, 0)
      assert_equal id, redis.lindex(ToolingJob.key_for_locked, 0)
    end

    def test_marks_job_as_executed
      redis = Exercism.redis_tooling_client
      submission_uuid = SecureRandom.uuid
      status = "foobar"
      output = "say what now"

      id = ToolingJob.create!(submission_uuid, :test_runner, :ruby, "two-fer")
      ToolingJob.find(id).locked!
      ToolingJob.find(id).executed!(status, output)

      assert_nil redis.lindex(ToolingJob.key_for_queued, 0)
      assert_nil redis.lindex(ToolingJob.key_for_locked, 0)
      assert_equal id, redis.lindex(ToolingJob.key_for_executed, 0)

      assert_equal status, ToolingJob.find(id).execution_status
      assert_equal output, ToolingJob.find(id).execution_output
    end

    def test_marks_job_as_processed
      redis = Exercism.redis_tooling_client
      submission_uuid = SecureRandom.uuid

      id = ToolingJob.create!(submission_uuid, :test_runner, :ruby, "two-fer")
      ToolingJob.find(id).locked!
      ToolingJob.find(id).executed!(nil, nil)
      ToolingJob.find(id).processed!

      assert_nil redis.lindex(ToolingJob.key_for_queued, 0)
      assert_nil redis.lindex(ToolingJob.key_for_locked, 0)
      assert_nil redis.lindex(ToolingJob.key_for_executed, 0)
      assert_equal id, redis.lindex(ToolingJob.key_for_processed, 0)
    end
  end
end
