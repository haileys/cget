require "thread"

module CGet
  class Sender
    attr_reader :file, :connections, :threads, :queue

    def initialize(file, connections)
      @file = file
      @connections = connections
      @threads = []
      @queue = SizedQueue.new(connections.count * 2)
    end

    def run
      spawn_threads

      until file.eof?
        pos = file.pos
        data = file.read(4096)
        queue << [pos].pack("Q>") + data
      end

      threads.each do
        queue << :kill
      end

      threads.each(&:join)
    end

    def spawn_threads
      @threads = connections.map { |connection|
        Thread.start do
          run_connection(connection)
        end
      }
    end

    def run_connection(connection)
      loop do
        message = queue.pop
        break if message == :kill
        connection.write(message)
      end
    end
  end
end
