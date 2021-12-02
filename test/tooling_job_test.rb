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

    def test_methods
      # Symbols
      job = ToolingJob.new(1, foo: 'bar-1')
      assert_equal 'bar-1', job.foo

      # Strings
      job = ToolingJob.new(2, 'foo' => 'bar-2')
      assert_equal 'bar-2', job.foo
    end

    def test_queues_job
      redis = Exercism.redis_tooling_client
      submission_uuid = SecureRandom.uuid
      type = :test_runner

      job = ToolingJob.create!(type, submission_uuid, :ruby, "two-fer")

      assert redis.get("submission:#{submission_uuid}:#{type}")
      assert redis.get("job:#{job.id}")
      assert_equal job.id, redis.lpop(ToolingJob.key_for_queued)
    end

    def test_queues_job_in_background
      redis = Exercism.redis_tooling_client
      submission_uuid = SecureRandom.uuid
      type = :test_runner

      job = ToolingJob.create!(type, submission_uuid, :ruby, "two-fer", run_in_background: true)

      assert redis.get("submission:#{submission_uuid}:#{type}")
      assert redis.get("job:#{job.id}")
      assert_equal job.id, redis.lpop(ToolingJob.key_for_queued_for_background_processing)
    end

    def test_cancels_test_runner_job
      redis = Exercism.redis_tooling_client
      submission_uuid = SecureRandom.uuid

      job = ToolingJob.create!(:test_runner, submission_uuid, :ruby, "two-fer")
      job.cancelled!

      assert_nil redis.lindex(ToolingJob.key_for_queued, 0)
      assert_equal job.id, redis.lindex(ToolingJob.key_for_cancelled, 0)
    end

    def test_locks_job
      redis = Exercism.redis_tooling_client
      submission_uuid = SecureRandom.uuid

      job = ToolingJob.create!(:test_runner, submission_uuid, :ruby, "two-fer")
      job.locked!

      assert_nil redis.lindex(ToolingJob.key_for_queued, 0)
      assert_equal job.id, redis.lindex(ToolingJob.key_for_locked, 0)
    end

    def test_marks_job_as_executed
      redis = Exercism.redis_tooling_client
      submission_uuid = SecureRandom.uuid
      status = "foobar"
      output = "say what now"

      job = ToolingJob.create!(:test_runner, submission_uuid, :ruby, "two-fer")
      job.locked!
      job.executed!(status, output)

      assert_nil redis.lindex(ToolingJob.key_for_queued, 0)
      assert_nil redis.lindex(ToolingJob.key_for_locked, 0)
      assert_equal job.id, redis.lindex(ToolingJob.key_for_executed, 0)

      job = ToolingJob.find(job.id)
      assert_equal status, job.execution_status
      assert_equal output, job.execution_output
    end

    def test_marks_job_as_processed
      redis = Exercism.redis_tooling_client
      submission_uuid = SecureRandom.uuid
      type = :test_runner

      job = ToolingJob.create!(type, submission_uuid, :ruby, "two-fer")

      assert redis.get("submission:#{submission_uuid}:#{type}")
      assert redis.get("job:#{job.id}")
      job.locked!
      job.executed!(nil, nil)
      job.processed!

      assert_nil redis.lindex(ToolingJob.key_for_queued, 0)
      assert_nil redis.lindex(ToolingJob.key_for_locked, 0)
      assert_nil redis.lindex(ToolingJob.key_for_executed, 0)

      assert_nil redis.get("submission:#{submission_uuid}:#{type}")
      assert_nil redis.get("job:#{job.id}")
    end

    def test_stores_and_retrieves_stdout
      stdout = "Some scary stdout"
      id = SecureRandom.hex
      job = ToolingJob.new(id, {})
      job.store_stdout!(stdout)
      assert_equal stdout, job.stdout
    end

    def test_stores_and_retrieves_stderr
      stderr = "Some scary stdout"
      id = SecureRandom.hex
      job = ToolingJob.new(id, {})
      job.store_stderr!(stderr)
      assert_equal stderr, job.stderr
    end

    def test_stores_and_retrieves_metadata
      metadata = { 'foo' => { "bar" => ['cat', 1] } }
      id = SecureRandom.hex
      job = ToolingJob.new(id, {})
      job.store_metadata!(metadata)
      assert_equal metadata, job.metadata
    end
  end
end
