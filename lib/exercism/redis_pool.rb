module Exercism
  # A registry of pooled Redis clients, keyed by name.
  #
  # Clients used to be built per call, which turned out to be expensive rather
  # than merely wasteful. Redis::Cluster is eager: RedisClient::Cluster#initialize
  # builds its router inline, and the router does topology discovery and opens
  # node connections there and then. Because nothing held a reference to the
  # client afterwards, every command paid a connect plus a full slot-map fetch
  # and then threw the connection away - putting a handshake on the critical
  # path of every tooling job state transition, and (because the orchestrator
  # does the same on each idle poll) accounting for ~96% of our ElastiCache
  # ECPU bill.
  #
  # A single shared client would fix the churn, but Redis serialises every
  # command through an internal Monitor, so sharing one across the
  # orchestrator's and Sidekiq's threads would trade connection cost for
  # contention. Hence a pool.
  module RedisPool
    DEFAULT_SIZE = 5
    DEFAULT_TIMEOUT = 5

    @mutex = Mutex.new
    @pools = {}
    @pid = nil

    # Returns the pool for +key+, building it from the block on first use.
    # The returned object quacks like a Redis client: ConnectionPool::Wrapper
    # checks a connection out for the duration of each method call.
    def self.for(key, &)
      require 'connection_pool'

      @mutex.synchronize do
        reset_after_fork!

        @pools[key] ||= ConnectionPool::Wrapper.new(size:, timeout: DEFAULT_TIMEOUT, &)
      end
    end

    def self.size
      Integer(ENV.fetch('EXERCISM_REDIS_POOL_SIZE', DEFAULT_SIZE))
    end

    # A pool must never be shared across a fork - parent and child would write
    # down each other's sockets - so pools are scoped to the pid and rebuilt
    # from scratch in the child.
    def self.reset_after_fork!
      return if @pid == Process.pid

      @pools = {}
      @pid = Process.pid
    end
    private_class_method :reset_after_fork!
  end
end
